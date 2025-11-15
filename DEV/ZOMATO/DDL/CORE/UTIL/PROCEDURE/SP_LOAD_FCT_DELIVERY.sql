CREATE OR REPLACE PROCEDURE "SP_LOAD_FCT_DELIVERY"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    snowflake.execute({sqlText: ''TRUNCATE TABLE INT.FCT_DELIVERY''});

    var sql = `
      INSERT INTO INT.FCT_DELIVERY
      SELECT
        TRIP_ID,
        ORDER_ID,
        AGENT_ID,
        PICKUP_TIME,
        DROP_TIME,
        DISTANCE_KM,
        ESTIMATED_TIME_MIN,
        ACTUAL_TIME_MIN,
        SLA_BREACH_FLAG
      FROM STG.V_DELIVERY_TRIP_STG
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_FCT_DELIVERY'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''FCT_DELIVERY loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''FCT_DELIVERY loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_FCT_DELIVERY'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_FCT_DELIVERY: '' + err;
  }
';
