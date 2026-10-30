from pathlib import Path
import pandas as pd

ROOT=Path(__file__).resolve().parents[1]
RAW,OUT=ROOT/'data'/'raw',ROOT/'data'/'processed'
OUT.mkdir(parents=True,exist_ok=True)
dates={'sales':['sale_date'],'inventory':['stock_date'],
       'purchase_orders':['order_date','expected_date','received_date']}
required={
 'products':['product_id','product_name','unit_cost','selling_price'],
 'suppliers':['supplier_id','supplier_name','lead_time_days'],
 'sales':['sale_id','product_id','sale_date','quantity_sold','revenue'],
 'inventory':['inventory_id','product_id','warehouse_id','stock_date','opening_stock','closing_stock'],
 'purchase_orders':['purchase_id','product_id','supplier_id','order_date','expected_date','quantity_ordered','quantity_received']}
numeric={
 'products':['unit_cost','selling_price'],'suppliers':['lead_time_days'],
 'sales':['quantity_sold','revenue'],'inventory':['opening_stock','closing_stock'],
 'purchase_orders':['quantity_ordered','quantity_received']}
for table in required:
    df=pd.read_csv(RAW/f'{table}.csv').drop_duplicates().copy()
    for col in dates.get(table,[]): df[col]=pd.to_datetime(df[col],errors='coerce')
    for col in numeric.get(table,[]): df[col]=pd.to_numeric(df[col],errors='coerce')
    df=df.dropna(subset=required[table])
    if table=='sales': df=df[(df.quantity_sold>0)&(df.revenue>=0)]
    if table=='inventory': df=df[(df.opening_stock>=0)&(df.closing_stock>=0)]
    if table=='purchase_orders':
        df=df[(df.quantity_ordered>0)&(df.quantity_received>=0)&
              (df.quantity_received<=df.quantity_ordered)]
    df.to_csv(OUT/f'{table}.csv',index=False,date_format='%Y-%m-%d')
    print(f'{table}: {len(df):,} rows')
print('Cleaned files saved to data/processed/')
