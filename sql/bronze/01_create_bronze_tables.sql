
/*
============================================================
PROJECT: OLIST E-COMMERCE DATA WAREHOUSE
LAYER: BRONZE
DATABASE: olist_dwh
ARCHITECTURE: BRONZE -> SILVER -> GOLD
============================================================

PURPOSE:
The Bronze layer stores raw data ingested from the Olist
e-commerce CSV source files.

TABLES:
1. bronze.category_translation
2. bronze.customers
3. bronze.geolocation
4. bronze.order_items
5. bronze.order_payments
6. bronze.order_reviews
7. bronze.orders
8. bronze.products
9. bronze.sellers

DESIGN PRINCIPLES:
- Preserve source data during ingestion.
- Retain source values before Silver transformations.
- Include ingestion metadata where applicable:
    dwh_load_ts
    dwh_source_file
    dwh_batch_id
- Support traceability and repeatable data loads.
- Preserve source date values as text where applicable
  until they are transformed in the Silver layer.

DATASET:
Brazilian Olist e-commerce public dataset.

NOTE:
The Bronze tables have already been created and populated
in the olist_dwh database. This file documents the layer
and its existing tables; it is not an execution script.
============================================================
*/
