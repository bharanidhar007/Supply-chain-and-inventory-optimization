from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'data'/'processed'
OUT=DATA/'charts'; OUT.mkdir(parents=True,exist_ok=True)
sales=pd.read_csv(DATA/'sales.csv',parse_dates=['sale_date'])
products=pd.read_csv(DATA/'products.csv')
monthly=(sales.set_index('sale_date').resample('MS')
         .agg(units_sold=('quantity_sold','sum'),revenue=('revenue','sum')).reset_index())
fig,ax=plt.subplots(figsize=(11,5))
ax.plot(monthly.sale_date,monthly.revenue,marker='o')
ax.set(title='Monthly Revenue',xlabel='Month',ylabel='Revenue')
fig.tight_layout(); fig.savefig(OUT/'monthly_revenue.png',dpi=150); plt.close(fig)
top=(sales.groupby('product_id',as_index=False).quantity_sold.sum()
     .merge(products[['product_id','product_name']],on='product_id')
     .nlargest(10,'quantity_sold'))
fig,ax=plt.subplots(figsize=(10,6))
ax.barh(top.product_name,top.quantity_sold); ax.invert_yaxis()
ax.set(title='Top 10 Products by Demand',xlabel='Units sold')
fig.tight_layout(); fig.savefig(OUT/'top_products.png',dpi=150); plt.close(fig)
monthly.to_csv(DATA/'monthly_sales_summary.csv',index=False)
top.to_csv(DATA/'top_products_summary.csv',index=False)
print('EDA complete; charts and summaries saved.')
