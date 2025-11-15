CREATE OR REPLACE PROCEDURE "SP_LOAD_FCT_CUSTOMER_EVENT"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    snowflake.execute({sqlText: ''TRUNCATE TABLE INT.FCT_CUSTOMER_EVENT''});

    var sql = `
      INSERT INTO INT.FCT_CUSTOMER_EVENT
      SELECT
        EVENT_ID,
        CUSTOMER_ID,
        EVENT_TYPE,
        EVENT_TS,
        SEARCH_QUERY,
        DEVICE_OS,
        APP_VERSION
      FROM STG.V_CUSTOMER_EVENTS_STG
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_FCT_CUSTOMER_EVENT'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''FCT_CUSTOMER_EVENT loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''FCT_CUSTOMER_EVENT loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_FCT_CUSTOMER_EVENT'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_FCT_CUSTOMER_EVENT: '' + err;
  }
';
