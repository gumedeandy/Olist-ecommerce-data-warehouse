
/*
================================================================
PROJECT       : OLIST E-COMMERCE DATA WAREHOUSE
LAYER         : BRONZE
DATABASE      : olist_dwh
TECHNOLOGY    : MICROSOFT SQL SERVER
ARCHITECTURE  : BRONZE -> SILVER -> GOLD

PURPOSE
-------
The Bronze layer is the initial storage layer of the data
warehouse. It contains source data ingested from the nine
Brazilian Olist E-Commerce CSV files.

DESIGN PRINCIPLES
-----------------
1. Preserve source values as closely as possible.
2. Allow nullable columns to accommodate source inconsistencies.
3. Retain original text representations of date values where
   applicable for transformation in the Silver layer.
4. Include ingestion metadata where supported:
      - dwh_load_ts: timestamp of ingestion
      - dwh_source_file: name of the source file
      - dwh_batch_id: ingestion batch identifier
5. Do not apply business transformations in this layer.
6. Use conditional table creation to avoid dropping existing
   tables or deleting previously loaded data.

SOURCE TABLES
-------------
1. category_translation
2. customers
3. geolocation
4. order_items
5. order_payments
6. order_reviews
7. orders
8. products
9. sellers

EXECUTION
---------
Safe to execute against an existing database. Existing tables
are preserved; only missing tables are created.

================================================================
*/

USE olist_dwh;
GO

-- Create the Bronze schema if it does not already exist.
IF SCHEMA_ID('bronze') IS NULL
    EXEC('CREATE SCHEMA bronze');
GO

/*
----------------------------------------------------------------
TABLE 01: bronze.category_translation

PURPOSE:
Stores the Portuguese-to-English product category translations
provided by the Olist source dataset.

USAGE:
Supports category standardisation and readable product
descriptions in the Silver and Gold layers.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.category_translation', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.category_translation
    (
        product_category_name NVARCHAR(100) NULL,
        product_category_name_english NVARCHAR(100) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 02: bronze.customers

PURPOSE:
Stores the original customer records from the Olist dataset.

KEY ATTRIBUTES:
- customer_id: identifies an individual customer record.
- customer_unique_id: identifies a customer across orders.
- customer_zip_code_prefix: customer's postal code prefix.
- customer_city: customer's city.
- customer_state: customer's Brazilian state.

USAGE:
Provides customer information for Silver transformations
and the Gold customer dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.customers', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.customers
    (
        customer_id NVARCHAR(50) NULL,
        customer_unique_id NVARCHAR(50) NULL,
        customer_zip_code_prefix NVARCHAR(20) NULL,
        customer_city NVARCHAR(200) NULL,
        customer_state NVARCHAR(10) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file NVARCHAR(260) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 03: bronze.geolocation

PURPOSE:
Stores Brazilian postal-code geolocation information.

KEY ATTRIBUTES:
- geolocation_zip_code_prefix: postal code prefix.
- geolocation_lat: geographic latitude.
- geolocation_lng: geographic longitude.
- geolocation_city: city associated with the location.
- geolocation_state: Brazilian state abbreviation.

USAGE:
Supports geographic analysis and location enrichment.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.geolocation', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.geolocation
    (
        geolocation_zip_code_prefix VARCHAR(10) NULL,
        geolocation_lat DECIMAL(10,7) NULL,
        geolocation_lng DECIMAL(10,7) NULL,
        geolocation_city NVARCHAR(100) NULL,
        geolocation_state CHAR(2) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 04: bronze.order_items

PURPOSE:
Stores individual product items associated with customer orders.

GRAIN:
One row per order item.

KEY ATTRIBUTES:
- order_id: identifies the order.
- order_item_id: identifies the item within the order.
- product_id: identifies the purchased product.
- seller_id: identifies the seller.
- price: product item price.
- freight_value: shipping cost for the item.

USAGE:
Provides the source records for the Gold sales fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_items
    (
        order_id VARCHAR(50) NULL,
        order_item_id INT NULL,
        product_id VARCHAR(50) NULL,
        seller_id VARCHAR(50) NULL,
        shipping_limit_date VARCHAR(50) NULL,
        price DECIMAL(12,2) NULL,
        freight_value DECIMAL(12,2) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 05: bronze.order_payments

PURPOSE:
Stores payment transaction details associated with orders.

GRAIN:
One row per payment sequence within an order.

KEY ATTRIBUTES:
- order_id: identifies the order.
- payment_sequential: identifies the payment sequence.
- payment_type: payment method.
- payment_installments: number of instalments.
- payment_value: payment amount.

USAGE:
Provides source records for the Gold payments fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.order_payments', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_payments
    (
        order_id VARCHAR(50) NULL,
        payment_sequential INT NULL,
        payment_type VARCHAR(30) NULL,
        payment_installments INT NULL,
        payment_value DECIMAL(12,2) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 06: bronze.order_reviews

PURPOSE:
Stores customer feedback and review information.

KEY ATTRIBUTES:
- review_id: identifies the review.
- order_id: identifies the associated order.
- review_score: customer rating.
- review_comment_title: review heading.
- review_comment_message: review text.
- review_creation_date: date the review was created.
- review_answer_timestamp: timestamp of the response.

USAGE:
Provides source records for the Gold reviews fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.order_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_reviews
    (
        review_id VARCHAR(50) NULL,
        order_id VARCHAR(50) NULL,
        review_score INT NULL,
        review_comment_title NVARCHAR(MAX) NULL,
        review_comment_message NVARCHAR(MAX) NULL,
        review_creation_date VARCHAR(50) NULL,
        review_answer_timestamp VARCHAR(50) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 07: bronze.orders

PURPOSE:
Stores the original order records and their lifecycle timestamps.

KEY ATTRIBUTES:
- order_id: unique order identifier in the source.
- customer_id: customer associated with the order.
- order_status: current order status.
- order_purchase_timestamp: purchase timestamp.
- order_approved_at: approval timestamp.
- order_delivered_carrier_date: carrier handover timestamp.
- order_delivered_customer_date: customer delivery timestamp.
- order_estimated_delivery_date: estimated delivery date.

USAGE:
Provides order lifecycle information for Silver transformations
and Gold analytical fact loading.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.orders', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.orders
    (
        order_id VARCHAR(50) NULL,
        customer_id VARCHAR(50) NULL,
        order_status VARCHAR(30) NULL,
        order_purchase_timestamp VARCHAR(50) NULL,
        order_approved_at VARCHAR(50) NULL,
        order_delivered_carrier_date VARCHAR(50) NULL,
        order_delivered_customer_date VARCHAR(50) NULL,
        order_estimated_delivery_date VARCHAR(50) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 08: bronze.products

PURPOSE:
Stores product catalogue information from the source dataset.

KEY ATTRIBUTES:
- product_id: identifies the product.
- product_category_name: original product category.
- product_name_length: product name length.
- product_description_length: description length.
- product_photos_qty: number of product photos.
- product_weight_g: product weight in grams.
- product_length_cm: product length in centimetres.
- product_height_cm: product height in centimetres.
- product_width_cm: product width in centimetres.

USAGE:
Provides product attributes for the Gold product dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.products', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.products
    (
        product_id VARCHAR(50) NULL,
        product_category_name NVARCHAR(100) NULL,
        product_name_length INT NULL,
        product_description_length INT NULL,
        product_photos_qty INT NULL,
        product_weight_g INT NULL,
        product_length_cm INT NULL,
        product_height_cm INT NULL,
        product_width_cm INT NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 09: bronze.sellers

PURPOSE:
Stores seller identification and location information.

KEY ATTRIBUTES:
- seller_id: identifies the seller.
- seller_zip_code_prefix: seller postal code prefix.
- seller_city: seller city.
- seller_state: Brazilian state abbreviation.

USAGE:
Provides seller attributes for the Gold seller dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('bronze.sellers', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.sellers
    (
        seller_id VARCHAR(50) NULL,
        seller_zip_code_prefix VARCHAR(10) NULL,
        seller_city NVARCHAR(100) NULL,
        seller_state CHAR(2) NULL,
        dwh_load_ts DATETIME2 NULL,
        dwh_source_file VARCHAR(255) NULL,
        dwh_batch_id INT NULL
    );
END;
GO

-- Final confirmation message.
PRINT 'Bronze layer table creation checks completed successfully.';
GO
