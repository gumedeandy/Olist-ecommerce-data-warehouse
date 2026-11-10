
/*
============================================================
PROJECT: OLIST E-COMMERCE DATA WAREHOUSE
LAYER: GOLD
DATABASE: olist_dwh
ARCHITECTURE: BRONZE -> SILVER -> GOLD
============================================================

PURPOSE:
The Gold layer contains business-ready dimensional models
and fact tables for reporting and analytics.

DIMENSION TABLES:
1. gold.dim_customer
   - Customer dimension
   - Supports Slowly Changing Dimension Type 2 (SCD2)
   - Tracks effective dates and current records

2. gold.dim_date
   - Calendar dimension
   - Supports day, month, quarter and year analysis

3. gold.dim_product
   - Product and product-category attributes

4. gold.dim_seller
   - Seller location and identification attributes

FACT TABLES:
5. gold.fact_sales
   - Grain: one row per order item
   - Measures: price, freight_value, total_item_value

6. gold.fact_payments
   - Grain: one row per payment line
   - Measures: payment_value

7. gold.fact_reviews
   - Grain: one row per review record
   - Measures: review_score

DESIGN PRINCIPLES:
- Dimensional modelling
- Surrogate keys for dimensions
- Unknown dimension member uses key -1
- Customer dimension supports SCD Type 2
- Fact tables reference dimension keys
- Designed for analytical reporting

NOTE:
These Gold tables have already been created and populated
in the olist_dwh database. This file documents their
structure and purpose; it is not an execution script.
============================================================
*/
