USE supply_chain_db;

-- Month-over-month revenue growth
WITH monthly AS (
 SELECT DATE_FORMAT(sale_date,'%Y-%m') AS sales_month,SUM(revenue) AS revenue
 FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
), lagged AS (
 SELECT sales_month,revenue,LAG(revenue) OVER(ORDER BY sales_month) AS prev_revenue
 FROM monthly
)
SELECT sales_month,revenue,prev_revenue,
 ROUND(100.0*(revenue-prev_revenue)/NULLIF(prev_revenue,0),2) AS mom_growth_pct
FROM lagged ORDER BY sales_month;

-- Supplier lead-time bands
SELECT supplier_name,lead_time_days,
 CASE WHEN lead_time_days<=7 THEN 'Short'
      WHEN lead_time_days<=14 THEN 'Medium' ELSE 'Long' END AS lead_time_band
FROM suppliers ORDER BY lead_time_days DESC;

-- Latest stock snapshot
WITH latest AS (
 SELECT *,ROW_NUMBER() OVER(PARTITION BY product_id,warehouse_id
 ORDER BY stock_date DESC,inventory_id DESC) rn FROM inventory
)
SELECT product_id,warehouse_id,stock_date,closing_stock
FROM latest WHERE rn=1;

-- Reorder-point calculation requires a chosen supplier per product,
-- daily demand calendar, safety-stock policy, on-hand, incoming orders and backorders.
