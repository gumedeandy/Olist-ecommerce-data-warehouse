
/*
============================================================
PROJECT: OLIST E-COMMERCE DATA WAREHOUSE
LAYER: SILVER
DATABASE: olist_dwh
ARCHITECTURE: BRONZE -> SILVER -> GOLD
============================================================

PURPOSE:
The Silver layer contains cleaned, standardized and
typed data transformed from the Bronze layer.

TABLES:
1. silver.category_translation
2. silver.customers
3. silver.geolocation
4. silver.order_items
5. silver.order_payments
6. silver.order_reviews
7. silver.orders
8. silver.products
9. silver.sellers

TRANSFORMATION PRINCIPLES:
- Convert date strings into datetime2 values.
- Standardize data types across source tables.
- Clean and prepare data for analytical modelling.
- Retain business identifiers for joins between tables.
- Remove Bronze ingestion metadata from Silver tables.
- Prepare data for Gold dimensions and fact tables.

DATA QUALITY:
- Silver data is prepared for downstream validation.
- Duplicate and invalid records are checked through
  dedicated data-quality tests.

NOTE:
The Silver tables have already been created and populated
in the olist_dwh database. This file documents the layer
and its existing tables; it is not an execution script.
============================================================
*/
