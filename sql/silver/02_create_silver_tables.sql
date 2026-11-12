
/*
================================================================
PROJECT       : OLIST E-COMMERCE DATA WAREHOUSE
LAYER         : SILVER
DATABASE      : olist_dwh
TECHNOLOGY    : MICROSOFT SQL SERVER
ARCHITECTURE  : BRONZE -> SILVER -> GOLD

PURPOSE
-------
The Silver layer stores cleaned, standardised and typed data
transformed from the Bronze source tables.

DESIGN PRINCIPLES
-----------------
1. Standardise data types across source tables.
2. Convert applicable date strings into DATETIME2 values.
3. Preserve business identifiers for downstream joins.
4. Prepare data for analytical modelling.
5. Exclude Bronze ingestion metadata from Silver tables.
6. Allow nullable values where source data may be incomplete.
7. Create missing tables without dropping existing tables.

SOURCE
------
The nine Bronze tables in the olist_dwh database.

TARGET TABLES
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
Safe to execute against an existing database.
Existing tables and their data are preserved.
Only missing tables are created.

================================================================
*/

USE olist_dwh;
GO

-- Create the Silver schema if it does not already exist.
IF SCHEMA_ID('silver') IS NULL
    EXEC('CREATE SCHEMA silver');
GO

/*
----------------------------------------------------------------
TABLE 01: silver.category_translation

PURPOSE:
Stores standardised product category translations.

KEY COLUMNS:
- product_category_name: original Portuguese category.
- product_category_name_english: English category name.

USAGE:
Supports readable product categories and category analysis.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.category_translation', 'U') IS NULL
BEGIN
    CREATE TABLE silver.category_translation
    (
        product_category_name NVARCHAR(100) NULL,
        product_category_name_english NVARCHAR(100) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 02: silver.customers

PURPOSE:
Stores cleaned and standardised customer information.

KEY COLUMNS:
- customer_id: source customer record identifier.
- customer_unique_id: unique customer business identifier.
- customer_zip_code_prefix: standardised postal code.
- customer_city: customer city.
- customer_state: customer state.

USAGE:
Supports customer analysis and the Gold customer dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.customers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.customers
    (
        customer_id NVARCHAR(50) NULL,
        customer_unique_id NVARCHAR(50) NULL,
        customer_zip_code_prefix VARCHAR(10) NULL,
        customer_city NVARCHAR(200) NULL,
        customer_state NVARCHAR(10) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 03: silver.geolocation

PURPOSE:
Stores standardised Brazilian postal-code location data.

KEY COLUMNS:
- geolocation_zip_code_prefix: postal code prefix.
- geolocation_lat: latitude.
- geolocation_lng: longitude.
- geolocation_city: city name.
- geolocation_state: two-character state code.

DATA TYPES:
Latitude and longitude use DECIMAL(10,7).

USAGE:
Supports geographic analysis and location enrichment.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.geolocation', 'U') IS NULL
BEGIN
    CREATE TABLE silver.geolocation
    (
        geolocation_zip_code_prefix VARCHAR(10) NULL,
        geolocation_lat DECIMAL(10,7) NULL,
        geolocation_lng DECIMAL(10,7) NULL,
        geolocation_city NVARCHAR(100) NULL,
        geolocation_state VARCHAR(2) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 04: silver.order_items

PURPOSE:
Stores cleaned individual order-item records.

GRAIN:
One row per order item.

KEY COLUMNS:
- order_id: order business identifier.
- order_item_id: item sequence within an order.
- product_id: purchased product identifier.
- seller_id: selling merchant identifier.
- shipping_limit_date: standardised shipping deadline.
- price: item price.
- freight_value: item shipping cost.

DATA TYPES:
shipping_limit_date uses DATETIME2.
Price and freight use DECIMAL(12,2).

USAGE:
Supports the Gold sales fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_items
    (
        order_id VARCHAR(50) NULL,
        order_item_id INT NULL,
        product_id VARCHAR(50) NULL,
        seller_id VARCHAR(50) NULL,
        shipping_limit_date DATETIME2 NULL,
        price DECIMAL(12,2) NULL,
        freight_value DECIMAL(12,2) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 05: silver.order_payments

PURPOSE:
Stores cleaned payment transaction records.

GRAIN:
One row per payment sequence within an order.

KEY COLUMNS:
- order_id: associated order identifier.
- payment_sequential: payment sequence number.
- payment_type: payment method.
- payment_installments: number of instalments.
- payment_value: payment amount.

DATA TYPES:
Payment amounts use DECIMAL(12,2).

USAGE:
Supports payment analysis and the Gold payments fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.order_payments', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_payments
    (
        order_id VARCHAR(50) NULL,
        payment_sequential INT NULL,
        payment_type VARCHAR(30) NULL,
        payment_installments INT NULL,
        payment_value DECIMAL(12,2) NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 06: silver.order_reviews

PURPOSE:
Stores standardised customer reviews and feedback.

KEY COLUMNS:
- review_id: review identifier.
- order_id: associated order identifier.
- review_score: customer rating.
- review_comment_title: review heading.
- review_comment_message: review text.
- review_creation_date: review creation timestamp.
- review_answer_timestamp: response timestamp.

DATA TYPES:
Review dates use DATETIME2.
Review comments use NVARCHAR(MAX).

USAGE:
Supports customer satisfaction analysis and the Gold
reviews fact table.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.order_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_reviews
    (
        review_id VARCHAR(50) NULL,
        order_id VARCHAR(50) NULL,
        review_score INT NULL,
        review_comment_title NVARCHAR(MAX) NULL,
        review_comment_message NVARCHAR(MAX) NULL,
        review_creation_date DATETIME2 NULL,
        review_answer_timestamp DATETIME2 NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 07: silver.orders

PURPOSE:
Stores cleaned order records and standardised lifecycle dates.

KEY COLUMNS:
- order_id: order identifier.
- customer_id: associated customer identifier.
- order_status: order status.
- order_purchase_timestamp: purchase timestamp.
- order_approved_at: approval timestamp.
- order_delivered_carrier_date: carrier handover timestamp.
- order_delivered_customer_date: customer delivery timestamp.
- order_estimated_delivery_date: estimated delivery timestamp.

DATA TYPES:
All order lifecycle timestamps use DATETIME2.

USAGE:
Supports order lifecycle analysis and Gold fact loading.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.orders', 'U') IS NULL
BEGIN
    CREATE TABLE silver.orders
    (
        order_id VARCHAR(50) NULL,
        customer_id VARCHAR(50) NULL,
        order_status VARCHAR(30) NULL,
        order_purchase_timestamp DATETIME2 NULL,
        order_approved_at DATETIME2 NULL,
        order_delivered_carrier_date DATETIME2 NULL,
        order_delivered_customer_date DATETIME2 NULL,
        order_estimated_delivery_date DATETIME2 NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 08: silver.products

PURPOSE:
Stores cleaned product catalogue information.

KEY COLUMNS:
- product_id: product identifier.
- product_category_name: product category.
- product_name_length: product name length.
- product_description_length: description length.
- product_photos_qty: number of product photos.
- product_weight_g: product weight in grams.
- product_length_cm: product length in centimetres.
- product_height_cm: product height in centimetres.
- product_width_cm: product width in centimetres.

USAGE:
Supports product analysis and the Gold product dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.products', 'U') IS NULL
BEGIN
    CREATE TABLE silver.products
    (
        product_id VARCHAR(50) NULL,
        product_category_name NVARCHAR(100) NULL,
        product_name_length INT NULL,
        product_description_length INT NULL,
        product_photos_qty INT NULL,
        product_weight_g INT NULL,
        product_length_cm INT NULL,
        product_height_cm INT NULL,
        product_width_cm INT NULL
    );
END;
GO

/*
----------------------------------------------------------------
TABLE 09: silver.sellers

PURPOSE:
Stores cleaned seller identification and location data.

KEY COLUMNS:
- seller_id: seller identifier.
- seller_zip_code_prefix: seller postal code.
- seller_city: seller city.
- seller_state: two-character state code.

USAGE:
Supports seller analysis and the Gold seller dimension.
----------------------------------------------------------------
*/
IF OBJECT_ID('silver.sellers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.sellers
    (
        seller_id VARCHAR(50) NULL,
        seller_zip_code_prefix VARCHAR(10) NULL,
        seller_city NVARCHAR(100) NULL,
        seller_state VARCHAR(2) NULL
    );
END;
GO

-- Final confirmation.
PRINT 'Silver layer table creation checks completed successfully.';
GO
