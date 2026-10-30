# Power BI dashboard guide

## Model
Use dimensions `products`, `suppliers`, and a Date table. Use facts `sales`, `inventory`, and `purchase_orders`. Create one-to-many relationships from dimensions to facts; avoid directly joining fact tables. Relate the Date table to the relevant date in each fact table (use inactive relationships where appropriate).

## Starter measures
```dax
Total Revenue = SUM(sales[revenue])
Total Units Sold = SUM(sales[quantity_sold])
Product Count = DISTINCTCOUNT(products[product_id])
Ordered Units = SUM(purchase_orders[quantity_ordered])
Received Units = SUM(purchase_orders[quantity_received])
PO Fulfillment % = DIVIDE([Received Units], [Ordered Units], 0)
Received Orders =
CALCULATE(COUNTROWS(purchase_orders), NOT ISBLANK(purchase_orders[received_date]))
On-time Orders =
CALCULATE(COUNTROWS(purchase_orders),
 FILTER(purchase_orders,
   NOT ISBLANK(purchase_orders[received_date]) &&
   purchase_orders[received_date] <= purchase_orders[expected_date]))
On-time Delivery % = DIVIDE([On-time Orders], [Received Orders], 0)
```

## Report pages
1. Executive overview: revenue, units sold, product count, fulfillment, monthly revenue, category revenue.
2. Inventory health: latest stock by product/warehouse, low-stock table, inventory by category, stock trend.
3. Demand analysis: monthly demand, top products, seasonality, actual vs forecast from `forecast_holdout.csv`.
4. Supplier performance: on-time delivery, fulfillment, lead time, ordered vs received quantities.

## Important inventory warning
Do not sum all historical `closing_stock` records and call it current inventory. Filter to the latest snapshot date per product and warehouse (or selected as-of date). Define the snapshot logic explicitly in Power Query or DAX.

Suggested slicers: Date, category, product, warehouse, supplier.
