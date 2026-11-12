
/*
============================================================
PROJECT: OLIST E-COMMERCE DATA WAREHOUSE
LAYER: GOLD
DATABASE: olist_dwh
ARCHITECTURE: BRONZE -> SILVER -> GOLD
============================================================

PURPOSE:
Create the business-ready dimensional model and fact tables
used for analytical reporting.

DIMENSIONS:
1. dim_customer - Customer dimension with SCD Type 2.
2. dim_date     - Calendar dimension.
3. dim_product  - Product and category dimension.
4. dim_seller   - Seller dimension.

FACT TABLES:
5. fact_sales    - One row per order item.
6. fact_payments - One row per payment line.
7. fact_reviews  - One row per review and order.

DESIGN:
- Surrogate keys identify dimension and fact records.
- Unknown dimension member uses key -1.
- Customer dimension supports SCD Type 2.
- Unique indexes enforce the declared business grains.
- No foreign keys were present in the inspected database.

SAFETY:
- Creates missing tables only.
- Does not drop, truncate, or overwrite existing data.
- Does not reload or seed data.

============================================================
*/

USE olist_dwh;
GO

/*============================================================
  SECTION 1: CREATE GOLD SCHEMA
============================================================*/

IF SCHEMA_ID('gold') IS NULL
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO


/*============================================================
  SECTION 2: CUSTOMER DIMENSION
  Purpose: Stores customer attributes and historical versions.

  SCD TYPE 2:
  - customer_key is the surrogate key.
  - customer_unique_id identifies the business customer.
  - effective dates track historical validity.
  - is_current identifies the active version.
============================================================*/

IF OBJECT_ID('gold.dim_customer', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_customer
    (
        customer_key INT IDENTITY(1,1) NOT NULL,
        customer_id VARCHAR(50) NOT NULL,
        customer_unique_id VARCHAR(50) NOT NULL,
        customer_zip_code_prefix VARCHAR(10) NULL,
        customer_city VARCHAR(100) NULL,
        customer_state VARCHAR(10) NULL,

        effective_start_date DATETIME2 NOT NULL
            CONSTRAINT DF_dim_customer_start
            DEFAULT (SYSDATETIME()),

        effective_end_date DATETIME2 NOT NULL
            CONSTRAINT DF_dim_customer_end
            DEFAULT ('9999-12-31 23:59:59.9999999'),

        is_current BIT NOT NULL
            CONSTRAINT DF_dim_customer_current
            DEFAULT ((1)),

        CONSTRAINT PK_gold_dim_customer
            PRIMARY KEY (customer_key)
    );
END;
GO


/*============================================================
  SECTION 3: DATE DIMENSION
  Purpose: Provides calendar attributes for time analysis.

  date_key is manually assigned in YYYYMMDD format.
============================================================*/

IF OBJECT_ID('gold.dim_date', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_date
    (
        date_key INT NOT NULL,
        full_date DATE NOT NULL,
        day_number INT NOT NULL,
        day_name VARCHAR(20) NOT NULL,
        month_number INT NOT NULL,
        month_name VARCHAR(20) NOT NULL,
        quarter_number INT NOT NULL,
        year_number INT NOT NULL,
        is_weekend BIT NOT NULL,

        CONSTRAINT PK_gold_dim_date
            PRIMARY KEY (date_key)
    );
END;
GO


/*============================================================
  SECTION 4: PRODUCT DIMENSION
  Purpose: Stores product and category information.

  product_key is the surrogate key.
  product_id is the unique source business identifier.
============================================================*/

IF OBJECT_ID('gold.dim_product', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_product
    (
        product_key INT IDENTITY(1,1) NOT NULL,
        product_id VARCHAR(50) NOT NULL,
        product_category_name VARCHAR(255) NULL,
        product_category_name_english VARCHAR(255) NULL,
        product_name_length INT NULL,
        product_description_length INT NULL,
        product_photos_qty INT NULL,
        product_weight_g INT NULL,
        product_length_cm INT NULL,
        product_height_cm INT NULL,
        product_width_cm INT NULL,

        CONSTRAINT PK_gold_dim_product
            PRIMARY KEY (product_key)
    );
END;
GO


/*============================================================
  SECTION 5: SELLER DIMENSION
  Purpose: Stores seller identification and location details.
============================================================*/

IF OBJECT_ID('gold.dim_seller', 'U') IS NULL
BEGIN
    CREATE TABLE gold.dim_seller
    (
        seller_key INT IDENTITY(1,1) NOT NULL,
        seller_id VARCHAR(50) NOT NULL,
        seller_zip_code_prefix VARCHAR(10) NULL,
        seller_city VARCHAR(100) NULL,
        seller_state VARCHAR(10) NULL,

        CONSTRAINT PK_gold_dim_seller
            PRIMARY KEY (seller_key)
    );
END;
GO


/*============================================================
  SECTION 6: SALES FACT TABLE
  Grain: One row per order item.

  Measures:
  - price
  - freight_value
  - total_item_value

  sales_key is the surrogate fact key.
  order_id + order_item_id enforce the fact grain.
============================================================*/

IF OBJECT_ID('gold.fact_sales', 'U') IS NULL
BEGIN
    CREATE TABLE gold.fact_sales
    (
        sales_key BIGINT IDENTITY(1,1) NOT NULL,
        order_id VARCHAR(50) NOT NULL,
        order_item_id INT NOT NULL,
        customer_key INT NOT NULL,
        product_key INT NOT NULL,
        seller_key INT NOT NULL,
        purchase_date_key INT NOT NULL,
        shipping_limit_date_key INT NULL,
        order_status VARCHAR(50) NULL,
        price DECIMAL(18,2) NULL,
        freight_value DECIMAL(18,2) NULL,
        total_item_value DECIMAL(18,2) NULL,
        order_purchase_timestamp DATETIME2 NULL,

        CONSTRAINT PK_gold_fact_sales
            PRIMARY KEY (sales_key)
    );
END;
GO


/*============================================================
  SECTION 7: PAYMENTS FACT TABLE
  Grain: One row per payment line.

  Measures:
  - payment_value

  order_id + payment_sequential enforce the fact grain.
============================================================*/

IF OBJECT_ID('gold.fact_payments', 'U') IS NULL
BEGIN
    CREATE TABLE gold.fact_payments
    (
        payment_key BIGINT IDENTITY(1,1) NOT NULL,
        order_id VARCHAR(50) NOT NULL,
        payment_sequential INT NOT NULL,
        customer_key INT NOT NULL,
        purchase_date_key INT NOT NULL,
        payment_type VARCHAR(50) NULL,
        payment_installments INT NULL,
        payment_value DECIMAL(18,2) NULL,

        CONSTRAINT PK_gold_fact_payments
            PRIMARY KEY (payment_key)
    );
END;
GO


/*============================================================
  SECTION 8: REVIEWS FACT TABLE
  Grain: One row per review and order.

  Measures:
  - review_score

  review_id + order_id enforce the fact grain.
============================================================*/

IF OBJECT_ID('gold.fact_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE gold.fact_reviews
    (
        review_key BIGINT IDENTITY(1,1) NOT NULL,
        review_id VARCHAR(50) NOT NULL,
        order_id VARCHAR(50) NOT NULL,
        customer_key INT NOT NULL,
        review_date_key INT NOT NULL,
        review_answer_date_key INT NOT NULL,
        review_score INT NULL,
        review_comment_title NVARCHAR(MAX) NULL,
        review_comment_message NVARCHAR(MAX) NULL,
        review_answer_timestamp DATETIME2 NULL,

        CONSTRAINT PK_gold_fact_reviews
            PRIMARY KEY (review_key)
    );
END;
GO


/*============================================================
  SECTION 9: UNIQUE INDEXES
  Purpose: Enforce business-key uniqueness and fact-table grain.

  Indexes are created only when their names do not already exist.
============================================================*/

-- One current record per customer business key.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.dim_customer')
      AND name = 'UX_dim_customer_current'
)
BEGIN
    CREATE UNIQUE INDEX UX_dim_customer_current
    ON gold.dim_customer (customer_unique_id)
    WHERE is_current = 1;
END;
GO


-- One record per product business key.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.dim_product')
      AND name = 'UX_dim_product_product_id'
)
BEGIN
    CREATE UNIQUE INDEX UX_dim_product_product_id
    ON gold.dim_product (product_id);
END;
GO


-- One record per seller business key.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.dim_seller')
      AND name = 'UX_dim_seller_seller_id'
)
BEGIN
    CREATE UNIQUE INDEX UX_dim_seller_seller_id
    ON gold.dim_seller (seller_id);
END;
GO


-- Sales grain: one row per order item.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.fact_sales')
      AND name = 'UQ_fact_sales_order_item'
)
BEGIN
    CREATE UNIQUE INDEX UQ_fact_sales_order_item
    ON gold.fact_sales (order_id, order_item_id);
END;
GO


-- Payments grain: one row per payment sequence per order.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.fact_payments')
      AND name = 'UQ_fact_payments_order_line'
)
BEGIN
    CREATE UNIQUE INDEX UQ_fact_payments_order_line
    ON gold.fact_payments (order_id, payment_sequential);
END;
GO


-- Reviews grain: one row per review and order.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('gold.fact_reviews')
      AND name = 'UQ_fact_reviews_review_order'
)
BEGIN
    CREATE UNIQUE INDEX UQ_fact_reviews_review_order
    ON gold.fact_reviews (review_id, order_id);
END;
GO


/*============================================================
  SECTION 10: COMPLETION MESSAGE
============================================================*/

PRINT 'Gold layer table creation checks completed successfully.';
GO
