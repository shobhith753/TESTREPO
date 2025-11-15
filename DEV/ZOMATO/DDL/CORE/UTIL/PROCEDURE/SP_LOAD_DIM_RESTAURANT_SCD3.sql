CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_RESTAURANT_SCD3"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    var sql = `
      MERGE INTO INT.DIM_RESTAURANT_SCD3 d
      USING STG.V_RESTAURANT_STG s
        ON d.RESTAURANT_ID = s.RESTAURANT_ID
      WHEN MATCHED AND NVL(d.CURRENT_CUISINE,'''') <> NVL(s.CUISINE_PRIMARY,'''') THEN
        UPDATE SET
          PREVIOUS_CUISINE = d.CURRENT_CUISINE,
          CURRENT_CUISINE  = s.CUISINE_PRIMARY,
          LAST_CHANGE_DATE = CURRENT_TIMESTAMP(),
          CITY             = s.CITY,
          AREA             = s.AREA
      WHEN NOT MATCHED THEN
        INSERT (RESTAURANT_ID, RESTAURANT_NAME, CURRENT_CUISINE, PREVIOUS_CUISINE, LAST_CHANGE_DATE, CITY, AREA)
        VALUES (
          s.RESTAURANT_ID,
          s.RESTAURANT_NAME,
          s.CUISINE_PRIMARY,
          NULL,
          CURRENT_TIMESTAMP(),
          s.CITY,
          s.AREA
        )
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_DIM_RESTAURANT_SCD3'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''DIM_RESTAURANT_SCD3 loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''DIM_RESTAURANT_SCD3 loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_DIM_RESTAURANT_SCD3'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_DIM_RESTAURANT_SCD3: '' + err;
  }
';
