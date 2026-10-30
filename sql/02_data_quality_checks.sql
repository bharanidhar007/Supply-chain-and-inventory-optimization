USE supply_chain_db;

SELECT * FROM products
WHERE product_name IS NULL OR unit_cost < 0 OR selling_price < 0;
SELECT * FROM suppliers
WHERE supplier_name IS NULL OR lead_time_days < 0;
SELECT * FROM sales
WHERE quantity_sold <= 0 OR revenue < 0 OR sale_date IS NULL;
SELECT * FROM inventory
WHERE opening_stock < 0 OR closing_stock < 0 OR stock_date IS NULL;
SELECT * FROM purchase_orders
WHERE quantity_ordered <= 0 OR quantity_received < 0
   OR quantity_received > quantity_ordered OR expected_date < order_date;

-- Potential duplicate business transactions: investigate before deleting.
SELECT product_id, sale_date, quantity_sold, revenue, COUNT(*) AS duplicate_count
FROM sales
GROUP BY product_id, sale_date, quantity_sold, revenue
HAVING COUNT(*) > 1;
