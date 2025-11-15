CREATE OR REPLACE PROCEDURE "SP_LOAD_FCT_FEEDBACK"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    snowflake.execute({sqlText: ''TRUNCATE TABLE INT.FCT_FEEDBACK''});

    var sql = `
      INSERT INTO INT.FCT_FEEDBACK
      SELECT
        FEEDBACK_ID,
        ORDER_ID,
        CUSTOMER_ID,
        RATING,
        COMMENT,
        SENTIMENT_SCORE,
        CREATED_AT
      FROM STG.V_CUSTOMER_FEEDBACK_STG
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_FCT_FEEDBACK'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''FCT_FEEDBACK loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''FCT_FEEDBACK loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_FCT_FEEDBACK'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_FCT_FEEDBACK: '' + err;
  }
';
