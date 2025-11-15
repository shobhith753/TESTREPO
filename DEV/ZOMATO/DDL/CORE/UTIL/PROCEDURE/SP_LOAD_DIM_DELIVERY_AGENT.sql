CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_DELIVERY_AGENT"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    var sql = `
      MERGE INTO INT.DIM_DELIVERY_AGENT d
      USING STG.V_DELIVERY_AGENT_STG s
        ON d.AGENT_ID = s.AGENT_ID
      WHEN MATCHED THEN UPDATE SET
        AGENT_NAME   = s.AGENT_NAME,
        PHONE        = s.PHONE,
        HIRE_DATE    = s.HIRE_DATE,
        CITY         = s.CITY,
        VEHICLE_TYPE = s.VEHICLE_TYPE,
        STATUS       = s.STATUS
      WHEN NOT MATCHED THEN
        INSERT (AGENT_ID, AGENT_NAME, PHONE, HIRE_DATE, CITY, VEHICLE_TYPE, STATUS)
        VALUES (s.AGENT_ID, s.AGENT_NAME, s.PHONE, s.HIRE_DATE, s.CITY, s.VEHICLE_TYPE, s.STATUS)
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_DIM_DELIVERY_AGENT'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''DIM_DELIVERY_AGENT loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''DIM_DELIVERY_AGENT (SCD1) loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_DIM_DELIVERY_AGENT'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_DIM_DELIVERY_AGENT: '' + err;
  }
';
