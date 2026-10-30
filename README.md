# Supply Chain & Inventory Optimization

End-to-end portfolio starter using MySQL 8+, Python (Pandas) and Power BI.

**Dataset note:** `data/raw/` contains synthetic demonstration CSVs generated for this project. Replace them with a real dataset before presenting findings as real-world results.

## Workflow
1. Run `sql/01_database_schema.sql` in MySQL Workbench.
2. Import CSVs from `data/raw/` into their matching tables using Table Data Import Wizard. Import `products` and `suppliers` first, then the fact tables.
3. Run SQL scripts `02` through `04`.
4. From this folder run:
   - `pip install -r requirements.txt`
   - `python python/01_data_cleaning.py`
   - `python python/02_eda.py`
   - `python python/03_demand_forecasting.py`
5. Import processed CSVs and query outputs into Power BI. See `powerbi/PowerBI_Guide.md`.

## Data files
- products.csv: product master and unit economics
- suppliers.csv: supplier master and lead times
- sales.csv: transaction-level sales
- inventory.csv: weekly product/warehouse stock snapshots
- purchase_orders.csv: procurement orders and receipt performance

## Analytical definitions
- Inventory turnover = COGS / average inventory value over the same period.
- Lead-time demand = average daily demand × supplier lead time.
- Reorder point = lead-time demand + safety stock.
- Safety stock (fixed lead time assumption) = Z × standard deviation of daily demand × √lead time.
- Forecast evaluation uses a chronological holdout, not a random split.

## Deliverables
Document data-quality decisions, SQL business queries, Python EDA, forecast holdout metrics, Power BI screenshots, business insights and limitations. Do not claim cost or stockout reductions unless measured and validated.
