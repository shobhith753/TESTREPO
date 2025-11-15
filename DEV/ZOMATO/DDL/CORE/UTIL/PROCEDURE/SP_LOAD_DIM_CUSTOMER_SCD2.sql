CREATE OR REPLACE PROCEDURE "SP_LOAD_DIM_CUSTOMER_SCD2"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    var sql_merge = `
      MERGE INTO INT.DIM_CUSTOMER d
      USING STG.V_CUSTOMER_STG s
        ON d.CUSTOMER_ID = s.CUSTOMER_ID
       AND d.IS_CURRENT = TRUE
       AND (
         NVL(d.CUSTOMER_NAME,'''')      <> NVL(s.CUSTOMER_NAME,'''') OR
         NVL(d.EMAIL,'''')              <> NVL(s.EMAIL,'''') OR
         NVL(d.PRIMARY_PHONE,'''')      <> NVL(s.PRIMARY_PHONE,'''') OR
         NVL(d.CITY,'''')               <> NVL(s.CITY,'''') OR
         NVL(d.AREA,'''')               <> NVL(s.AREA,'''') OR
         NVL(d.SEGMENT,'''')            <> NVL(s.SEGMENT,'''') OR
         NVL(d.IS_PRIME_MEMBER,FALSE) <> NVL(s.IS_PRIME_MEMBER,FALSE) OR
         NVL(d.STATUS,'''')             <> NVL(s.STATUS,'''')
       )
      WHEN MATCHED THEN UPDATE SET
        EFFECTIVE_TO = CURRENT_TIMESTAMP(),
        IS_CURRENT   = FALSE
    `;
    snowflake.execute({sqlText: sql_merge});

    var sql_insert = `
      INSERT INTO INT.DIM_CUSTOMER (
        CUSTOMER_ID, CUSTOMER_NAME, EMAIL, PRIMARY_PHONE,
        CITY, AREA, SEGMENT, IS_PRIME_MEMBER, STATUS,
        EFFECTIVE_FROM, EFFECTIVE_TO, IS_CURRENT, RECORD_SOURCE
      )
      SELECT
        s.CUSTOMER_ID,
        s.CUSTOMER_NAME,
        s.EMAIL,
        s.PRIMARY_PHONE,
        s.CITY,
        s.AREA,
        s.SEGMENT,
        s.IS_PRIME_MEMBER,
        s.STATUS,
        CURRENT_TIMESTAMP(),
        TO_TIMESTAMP_NTZ(''9999-12-31''),
        TRUE,
        ''STG.V_CUSTOMER_STG''
      FROM STG.V_CUSTOMER_STG s
      LEFT JOIN INT.DIM_CUSTOMER d
        ON d.CUSTOMER_ID = s.CUSTOMER_ID
       AND d.IS_CURRENT = TRUE
      WHERE d.CUSTOMER_ID IS NULL
    `;
    snowflake.execute({sqlText: sql_insert});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_DIM_CUSTOMER_SCD2'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''DIM_CUSTOMER SCD2 loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''DIM_CUSTOMER SCD2 loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_DIM_CUSTOMER_SCD2'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_DIM_CUSTOMER_SCD2: '' + err;
  }
';
