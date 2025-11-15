CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_PROMOTION"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    var sql = `
      MERGE INTO INT.DIM_PROMOTION d
      USING STG.V_PROMOTION_STG s
        ON d.PROMO_ID = s.PROMO_ID
      WHEN MATCHED THEN UPDATE SET
        PROMO_CODE       = s.PROMO_CODE,
        DISCOUNT_PERCENT = s.DISCOUNT_PERCENT,
        START_DATE       = s.START_DATE,
        END_DATE         = s.END_DATE,
        MAX_DISCOUNT_AMT = s.MAX_DISCOUNT_AMT,
        TARGET_SEGMENT   = s.TARGET_SEGMENT,
        TARGET_CITY      = s.TARGET_CITY
      WHEN NOT MATCHED THEN
        INSERT (PROMO_ID, PROMO_CODE, DISCOUNT_PERCENT, START_DATE, END_DATE,
                MAX_DISCOUNT_AMT, TARGET_SEGMENT, TARGET_CITY)
        VALUES (s.PROMO_ID, s.PROMO_CODE, s.DISCOUNT_PERCENT, s.START_DATE, s.END_DATE,
                s.MAX_DISCOUNT_AMT, s.TARGET_SEGMENT, s.TARGET_CITY)
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_DIM_PROMOTION'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''DIM_PROMOTION loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''DIM_PROMOTION (SCD1) loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_DIM_PROMOTION'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_DIM_PROMOTION: '' + err;
  }
';
