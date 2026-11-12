# Olist Source Data

## Dataset

**Source:** Olist Brazilian E-Commerce Public Dataset

**Download:** https://www.kaggle.com/datasets/olistbr/brazillian-ecommerce

## Required source files

Download and extract the dataset. Place the following nine CSV files inside `data/raw/`:

1. `olist_customers_dataset.csv`
2. `olist_geolocation_dataset.csv`
3. `olist_order_items_dataset.csv`
4. `olist_order_payments_dataset.csv`
5. `olist_order_reviews_dataset.csv`
6. `olist_orders_dataset.csv`
7. `olist_products_dataset.csv`
8. `olist_sellers_dataset.csv`
9. `product_category_name_translation.csv`

## Data handling

- Original CSV files are stored locally in `data/raw/`.
- Raw source files are preserved unchanged.
- Raw CSV files are excluded from GitHub and are not committed to the repository.
- Download the dataset separately before attempting to reproduce the project.

## Important

The SQL scripts create the Bronze, Silver and Gold database structures. The current SSIS master package orchestrates customer SCD Type 2 and fact-table loading; it does not automate the complete raw CSV ingestion process.