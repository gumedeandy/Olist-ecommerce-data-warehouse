
USE olist_dwh;
GO

/* =========================================================
   OLIST E-COMMERCE DATA WAREHOUSE
   DATA QUALITY VALIDATION
   10 automated checks across Gold tables
   ========================================================= */

SELECT
    '01 - Duplicate Sales Order Items' AS test_name,
    (
        SELECT COUNT(*)
        FROM (
            SELECT order_id, order_item_id
            FROM gold.fact_sales
            GROUP BY order_id, order_item_id
            HAVING COUNT(*) > 1
        ) d
    ) AS failed_records

UNION ALL

SELECT
    '02 - Null Sales Identifiers',
    (
        SELECT COUNT(*)
        FROM gold.fact_sales
        WHERE order_id IS NULL
           OR order_item_id IS NULL
    )

UNION ALL

SELECT
    '03 - Negative Sales Values',
    (
        SELECT COUNT(*)
        FROM gold.fact_sales
        WHERE price < 0
           OR freight_value < 0
           OR total_item_value < 0
    )

UNION ALL

SELECT
    '04 - Incorrect Sales Totals',
    (
        SELECT COUNT(*)
        FROM gold.fact_sales
        WHERE ABS(total_item_value - (price + freight_value)) > 0.01
    )

UNION ALL

SELECT
    '05 - Duplicate Payment Lines',
    (
        SELECT COUNT(*)
        FROM (
            SELECT order_id, payment_sequential
            FROM gold.fact_payments
            GROUP BY order_id, payment_sequential
            HAVING COUNT(*) > 1
        ) d
    )

UNION ALL

SELECT
    '06 - Invalid Payment Amounts',
    (
        SELECT COUNT(*)
        FROM gold.fact_payments
        WHERE payment_value IS NULL
           OR payment_value < 0
    )

UNION ALL

SELECT
    '07 - Duplicate Review Records',
    (
        SELECT COUNT(*)
        FROM (
            SELECT review_id, order_id
            FROM gold.fact_reviews
            GROUP BY review_id, order_id
            HAVING COUNT(*) > 1
        ) d
    )

UNION ALL

SELECT
    '08 - Invalid Review Scores',
    (
        SELECT COUNT(*)
        FROM gold.fact_reviews
        WHERE review_score IS NULL
           OR review_score NOT BETWEEN 1 AND 5
    )

UNION ALL

SELECT
    '09 - Duplicate Current Customers',
    (
        SELECT COUNT(*)
        FROM (
            SELECT customer_unique_id
            FROM gold.dim_customer
            WHERE is_current = 1
              AND customer_key <> -1
            GROUP BY customer_unique_id
            HAVING COUNT(*) > 1
        ) d
    )

UNION ALL

SELECT
    '10 - Duplicate Products',
    (
        SELECT COUNT(*)
        FROM (
            SELECT product_id
            FROM gold.dim_product
            WHERE product_key <> -1
            GROUP BY product_id
            HAVING COUNT(*) > 1
        ) d
    )

ORDER BY test_name;
GO
