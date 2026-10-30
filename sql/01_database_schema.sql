CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

CREATE TABLE products (
 product_id INT PRIMARY KEY, product_name VARCHAR(150) NOT NULL,
 category VARCHAR(100), unit_cost DECIMAL(12,2) NOT NULL,
 selling_price DECIMAL(12,2) NOT NULL
);
CREATE TABLE suppliers (
 supplier_id INT PRIMARY KEY, supplier_name VARCHAR(150) NOT NULL,
 supplier_location VARCHAR(100), lead_time_days INT NOT NULL
);
CREATE TABLE sales (
 sale_id INT PRIMARY KEY, product_id INT NOT NULL, sale_date DATE NOT NULL,
 quantity_sold INT NOT NULL, revenue DECIMAL(12,2) NOT NULL,
 FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE inventory (
 inventory_id INT PRIMARY KEY, product_id INT NOT NULL,
 warehouse_id INT NOT NULL, stock_date DATE NOT NULL,
 opening_stock INT NOT NULL, closing_stock INT NOT NULL,
 FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE purchase_orders (
 purchase_id INT PRIMARY KEY, product_id INT NOT NULL, supplier_id INT NOT NULL,
 order_date DATE NOT NULL, expected_date DATE NOT NULL, received_date DATE NULL,
 quantity_ordered INT NOT NULL, quantity_received INT NOT NULL DEFAULT 0,
 order_status VARCHAR(50) NOT NULL,
 FOREIGN KEY (product_id) REFERENCES products(product_id),
 FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);
CREATE INDEX idx_sales_date_product ON sales(sale_date, product_id);
CREATE INDEX idx_inventory_date_product ON inventory(stock_date, product_id);
