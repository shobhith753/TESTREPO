CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_RESTAURANT_SCD2"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    var sql_merge = `
      MERGE INTO INT.DIM_RESTAURANT d
      USING STG.V_RESTAURANT_STG s
        ON d.RESTAURANT_ID = s.RESTAURANT_ID
       AND d.IS_CURRENT = TRUE
       AND (
         NVL(d.RESTAURANT_NAME,'''')    <> NVL(s.RESTAURANT_NAME,'''') OR
         NVL(d.CUISINE_PRIMARY,'''')    <> NVL(s.CUISINE_PRIMARY,'''') OR
         NVL(d.CUISINE_SECONDARY,'''')  <> NVL(s.CUISINE_SECONDARY,'''') OR
         NVL(d.CITY,'''')               <> NVL(s.CITY,'''') OR
         NVL(d.AREA,'''')               <> NVL(s.AREA,'''') OR
         NVL(d.AVG_RATING,0)          <> NVL(s.AVG_RATING,0) OR
         NVL(d.COMMISSION_RATE,0)     <> NVL(s.COMMISSION_RATE,0) OR
         NVL(d.IS_ACTIVE,FALSE)       <> NVL(s.IS_ACTIVE,FALSE)
       )
      WHEN MATCHED THEN UPDATE SET
        EFFECTIVE_TO = CURRENT_TIMESTAMP(),
        IS_CURRENT   = FALSE
    `;
    snowflake.execute({sqlText: sql_merge});

    var sql_insert = `
      INSERT INTO INT.DIM_RESTAURANT (
        RESTAURANT_ID, RESTAURANT_NAME,
        CUISINE_PRIMARY, CUISINE_SECONDARY,
        CITY, AREA,
        AVG_RATING, COMMISSION_RATE, IS_ACTIVE, ONBOARDED_AT,
        EFFECTIVE_FROM, EFFECTIVE_TO, IS_CURRENT, RECORD_SOURCE
      )
      SELECT
        s.RESTAURANT_ID,
        s.RESTAURANT_NAME,
        s.CUISINE_PRIMARY,
        s.CUISINE_SECONDARY,
        s.CITY,
        s.AREA,
        s.AVG_RATING,
        s.COMMISSION_RATE,
        s.IS_ACTIVE,
        s.ONBOARDED_AT,
        CURRENT_TIMESTAMP(),
        TO_TIMESTAMP_NTZ(''9999-12-31''),
        TRUE,
        ''STG.V_RESTAURANT_STG''
      FROM STG.V_RESTAURANT_STG s
      LEFT JOIN INT.DIM_RESTAURANT d
        ON d.RESTAURANT_ID = s.RESTAURANT_ID
       AND d.IS_CURRENT = TRUE
      WHERE d.RESTAURANT_ID IS NULL
    `;
    snowflake.execute({sqlText: sql_insert});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_DIM_RESTAURANT_SCD2'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''DIM_RESTAURANT SCD2 loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''DIM_RESTAURANT SCD2 loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_DIM_RESTAURANT_SCD2'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_DIM_RESTAURANT_SCD2: '' + err;
  }
';
