
USE olist_dwh;
GO

/* =========================================================
   1. LOAD FACT SALES
   Grain: one row per order_id + order_item_id
   ========================================================= */

CREATE OR ALTER PROCEDURE etl.usp_load_fact_sales
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO gold.fact_sales
        (
            order_id,
            order_item_id,
            customer_key,
            product_key,
            seller_key,
            purchase_date_key,
            shipping_limit_date_key,
            order_status,
            price,
            freight_value,
            total_item_value,
            order_purchase_timestamp
        )
        SELECT
            oi.order_id,
            oi.order_item_id,
            ISNULL(dc.customer_key, -1),
            ISNULL(dp.product_key, -1),
            ISNULL(ds.seller_key, -1),
            ISNULL(dd.date_key, -1),
            ISNULL(sd.date_key, -1),
            o.order_status,
            oi.price,
            oi.freight_value,
            oi.price + oi.freight_value,
            o.order_purchase_timestamp
        FROM silver.order_items oi
        INNER JOIN silver.orders o
            ON oi.order_id = o.order_id
        LEFT JOIN silver.customers c
            ON o.customer_id = c.customer_id
        LEFT JOIN gold.dim_customer dc
            ON c.customer_unique_id = dc.customer_unique_id
           AND dc.is_current = 1
        LEFT JOIN gold.dim_product dp
            ON oi.product_id = dp.product_id
        LEFT JOIN gold.dim_seller ds
            ON oi.seller_id = ds.seller_id
        LEFT JOIN gold.dim_date dd
            ON CAST(o.order_purchase_timestamp AS date) = dd.full_date
        LEFT JOIN gold.dim_date sd
            ON CAST(oi.shipping_limit_date AS date) = sd.full_date
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM gold.fact_sales existing
            WHERE existing.order_id = oi.order_id
              AND existing.order_item_id = oi.order_item_id
        );

        DECLARE @sales_rows INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT @sales_rows AS inserted_sales_rows;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


/* =========================================================
   2. LOAD FACT PAYMENTS
   Grain: one row per order_id + payment_sequential
   ========================================================= */

CREATE OR ALTER PROCEDURE etl.usp_load_fact_payments
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO gold.fact_payments
        (
            order_id,
            payment_sequential,
            customer_key,
            purchase_date_key,
            payment_type,
            payment_installments,
            payment_value
        )
        SELECT
            p.order_id,
            p.payment_sequential,
            ISNULL(dc.customer_key, -1),
            ISNULL(dd.date_key, -1),
            p.payment_type,
            p.payment_installments,
            p.payment_value
        FROM silver.order_payments p
        INNER JOIN silver.orders o
            ON p.order_id = o.order_id
        LEFT JOIN silver.customers c
            ON o.customer_id = c.customer_id
        LEFT JOIN gold.dim_customer dc
            ON c.customer_unique_id = dc.customer_unique_id
           AND dc.is_current = 1
        LEFT JOIN gold.dim_date dd
            ON CAST(o.order_purchase_timestamp AS date) = dd.full_date
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM gold.fact_payments existing
            WHERE existing.order_id = p.order_id
              AND existing.payment_sequential = p.payment_sequential
        );

        DECLARE @payment_rows INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT @payment_rows AS inserted_payment_rows;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


/* =========================================================
   3. LOAD FACT REVIEWS
   Grain: one row per review_id + order_id
   ========================================================= */

CREATE OR ALTER PROCEDURE etl.usp_load_fact_reviews
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO gold.fact_reviews
        (
            review_id,
            order_id,
            customer_key,
            review_date_key,
            review_answer_date_key,
            review_score,
            review_comment_title,
            review_comment_message,
            review_answer_timestamp
        )
        SELECT
            r.review_id,
            r.order_id,
            ISNULL(dc.customer_key, -1),
            ISNULL(rd.date_key, -1),
            ISNULL(rad.date_key, -1),
            r.review_score,
            r.review_comment_title,
            r.review_comment_message,
            r.review_answer_timestamp
        FROM silver.order_reviews r
        INNER JOIN silver.orders o
            ON r.order_id = o.order_id
        LEFT JOIN silver.customers c
            ON o.customer_id = c.customer_id
        LEFT JOIN gold.dim_customer dc
            ON c.customer_unique_id = dc.customer_unique_id
           AND dc.is_current = 1
        LEFT JOIN gold.dim_date rd
            ON CAST(r.review_creation_date AS date) = rd.full_date
        LEFT JOIN gold.dim_date rad
            ON CAST(r.review_answer_timestamp AS date) = rad.full_date
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM gold.fact_reviews existing
            WHERE existing.review_id = r.review_id
              AND existing.order_id = r.order_id
        );

        DECLARE @review_rows INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT @review_rows AS inserted_review_rows;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
