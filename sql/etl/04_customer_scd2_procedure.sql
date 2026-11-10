
CREATE PROCEDURE etl.usp_load_dim_customer_scd2
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @load_time DATETIME2(7) = SYSDATETIME();
    DECLARE @expired_rows INT = 0;
    DECLARE @inserted_rows INT = 0;

    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    INTO #customer_source
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY customer_unique_id
                ORDER BY customer_id
            ) AS rn
        FROM silver.customers
        WHERE customer_unique_id IS NOT NULL
    ) s
    WHERE rn = 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE target
        SET
            target.is_current = 0,
            target.effective_end_date =
                DATEADD(NANOSECOND, -100, @load_time)
        FROM gold.dim_customer target
        INNER JOIN #customer_source source
            ON target.customer_unique_id = source.customer_unique_id
        WHERE target.is_current = 1
          AND (
              ISNULL(target.customer_id, '') <>
                  ISNULL(source.customer_id, '')
              OR ISNULL(target.customer_zip_code_prefix, '') <>
                  ISNULL(source.customer_zip_code_prefix, '')
              OR ISNULL(target.customer_city, '') <>
                  ISNULL(source.customer_city, '')
              OR ISNULL(target.customer_state, '') <>
                  ISNULL(source.customer_state, '')
          );

        SET @expired_rows = @@ROWCOUNT;

        INSERT INTO gold.dim_customer (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            effective_start_date,
            effective_end_date,
            is_current
        )
        SELECT
            source.customer_id,
            source.customer_unique_id,
            source.customer_zip_code_prefix,
            source.customer_city,
            source.customer_state,
            @load_time,
            '9999-12-31 23:59:59.9999999',
            1
        FROM #customer_source source
        WHERE NOT EXISTS (
            SELECT 1
            FROM gold.dim_customer current_record
            WHERE current_record.customer_unique_id =
                  source.customer_unique_id
              AND current_record.is_current = 1
        );

        SET @inserted_rows = @@ROWCOUNT;

        COMMIT TRANSACTION;

        SELECT
            @expired_rows AS expired_customer_versions,
            @inserted_rows AS inserted_customer_versions,
            @load_time AS load_timestamp;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
