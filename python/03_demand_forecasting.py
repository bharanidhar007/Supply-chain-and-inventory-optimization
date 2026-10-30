from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error,mean_squared_error

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'data'/'processed'; OUT=DATA/'forecast'; OUT.mkdir(parents=True,exist_ok=True)
sales=pd.read_csv(DATA/'sales.csv',parse_dates=['sale_date'])
monthly=sales.groupby(['product_id',pd.Grouper(key='sale_date',freq='MS')]).quantity_sold.sum().reset_index()
pid=monthly.groupby('product_id').quantity_sold.sum().idxmax()
series=(monthly[monthly.product_id==pid].set_index('sale_date').quantity_sold
        .asfreq('MS',fill_value=0).sort_index())
if len(series)<8: raise ValueError('At least 8 months of demand history are required.')
train,test=series.iloc[:-3],series.iloc[-3:]
history=list(train.astype(float)); preds=[]
for actual in test.astype(float):
    preds.append(float(np.mean(history[-3:])))
    history.append(actual)
mae=mean_absolute_error(test,preds)
rmse=np.sqrt(mean_squared_error(test,preds))
pd.DataFrame({'product_id':pid,'sale_date':test.index,'actual_demand':test.values,
              'forecast_demand':preds}).to_csv(OUT/'forecast_holdout.csv',index=False)
next_fc=float(series.tail(3).mean())
pd.DataFrame([{'product_id':pid,'forecast_month':series.index.max()+pd.offsets.MonthBegin(1),
               'forecast_demand':next_fc,'holdout_mae':mae,'holdout_rmse':rmse}]).to_csv(
               OUT/'next_month_forecast.csv',index=False)
plt.figure(figsize=(11,5))
plt.plot(train.index,train.values,label='Training actual')
plt.plot(test.index,test.values,marker='o',label='Test actual')
plt.plot(test.index,preds,marker='x',linestyle='--',label='Moving-average forecast')
plt.title(f'Demand Forecast - Product {pid}'); plt.xlabel('Month'); plt.ylabel('Units')
plt.legend(); plt.tight_layout(); plt.savefig(OUT/'forecast_chart.png',dpi=150); plt.close()
print(f'Product {pid} | MAE {mae:.2f} | RMSE {rmse:.2f} | Next month {next_fc:.2f}')
