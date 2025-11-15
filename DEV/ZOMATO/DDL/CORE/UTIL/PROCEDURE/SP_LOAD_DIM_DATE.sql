CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_DATE"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
try {
  // Start explicit transaction
  snowflake.execute({ sqlText: ''BEGIN'' });

  // 1) Truncate target dimension
  snowflake.execute({
    sqlText: `TRUNCATE TABLE ZOMATO_DWH.INT.DIM_DATE`
  });

  // 2) Insert date rows (2019-01-01 to 2028-12-31)
  var insertSql = `
    INSERT INTO ZOMATO_DWH.INT.DIM_DATE (
      DATE_KEY,
      FULL_DATE,
      YEAR,
      MONTH,
      MONTH_SHORT,
      DAY_OF_MONTH,
      DAY_OF_WEEK,
      DAY_OF_WEEK_SHORT,
      WEEK_OF_YEAR
    )
    WITH date_range AS (
      SELECT
        DATEADD(''day'', SEQ4(), ''2019-01-01''::DATE) AS d
      FROM TABLE(GENERATOR(ROWCOUNT => 365 * 10))   -- ~10 years
    )
    SELECT
      TO_NUMBER(TO_CHAR(d, ''YYYYMMDD''))  AS DATE_KEY,
      d                                  AS FULL_DATE,
      YEAR(d)                            AS YEAR,
      MONTH(d)                           AS MONTH,
      TO_CHAR(d, ''MON'')                  AS MONTH_SHORT,
      DAY(d)                             AS DAY_OF_MONTH,
      DAYOFWEEK(d)                       AS DAY_OF_WEEK,
      TO_CHAR(d, ''DY'')                   AS DAY_OF_WEEK_SHORT,
      WEEKOFYEAR(d)                      AS WEEK_OF_YEAR
    FROM date_range
    WHERE d <= ''2028-12-31''::DATE
  `;

  snowflake.execute({ sqlText: insertSql });

  // 3) Commit
  snowflake.execute({ sqlText: ''COMMIT'' });

  return ''SP_LOAD_DIM_DATE completed successfully'';
} catch (err) {
  // Rollback on error
  try {
    snowflake.execute({ sqlText: ''ROLLBACK'' });
  } catch (e2) {
    // ignore rollback failure
  }
  return ''ERROR in SP_LOAD_DIM_DATE: '' + err;
}
';
