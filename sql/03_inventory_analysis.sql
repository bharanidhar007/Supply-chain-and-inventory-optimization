USE supply_chain_db;

-- Product revenue and units
SELECT p.product_id, p.product_name, SUM(s.quantity_sold) AS units_sold,
       ROUND(SUM(s.revenue),2) AS total_revenue
FROM products p JOIN sales s ON s.product_id=p.product_id
GROUP BY p.product_id,p.product_name ORDER BY total_revenue DESC;

-- Monthly sales
SELECT DATE_FORMAT(sale_date,'%Y-%m') AS sales_month,
       SUM(quantity_sold) AS units_sold, ROUND(SUM(revenue),2) AS revenue
FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m') ORDER BY sales_month;

-- Latest stock by product and warehouse
WITH ranked AS (
 SELECT i.*, ROW_NUMBER() OVER (
   PARTITION BY product_id,warehouse_id
   ORDER BY stock_date DESC,inventory_id DESC) AS rn
 FROM inventory i
)
SELECT p.product_name,r.warehouse_id,r.stock_date,r.closing_stock AS current_stock
FROM ranked r JOIN products p ON p.product_id=r.product_id
WHERE r.rn=1 ORDER BY current_stock;

-- Top 10 products by demand
SELECT p.product_id,p.product_name,SUM(s.quantity_sold) AS units_sold
FROM products p JOIN sales s ON s.product_id=p.product_id
GROUP BY p.product_id,p.product_name ORDER BY units_sold DESC LIMIT 10;

-- Products without sales
SELECT p.product_id,p.product_name
FROM products p LEFT JOIN sales s ON s.product_id=p.product_id
WHERE s.sale_id IS NULL;

-- Supplier on-time delivery rate (received orders only)
SELECT sp.supplier_name,COUNT(*) AS received_orders,
 SUM(CASE WHEN po.received_date<=po.expected_date THEN 1 ELSE 0 END) AS on_time_orders,
 ROUND(100.0*SUM(CASE WHEN po.received_date<=po.expected_date THEN 1 ELSE 0 END)
       /NULLIF(COUNT(*),0),2) AS on_time_delivery_pct
FROM purchase_orders po JOIN suppliers sp ON sp.supplier_id=po.supplier_id
WHERE po.received_date IS NOT NULL
GROUP BY sp.supplier_id,sp.supplier_name ORDER BY on_time_delivery_pct DESC;

-- Purchase order fulfillment by product
SELECT p.product_name,SUM(po.quantity_ordered) AS ordered_units,
 SUM(po.quantity_received) AS received_units,
 ROUND(100.0*SUM(po.quantity_received)/NULLIF(SUM(po.quantity_ordered),0),2) AS fulfillment_pct
FROM purchase_orders po JOIN products p ON p.product_id=po.product_id
GROUP BY p.product_id,p.product_name ORDER BY fulfillment_pct;
