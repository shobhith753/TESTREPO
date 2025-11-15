CREATE OR REPLACE PROCEDURE "SP_LOAD_FCT_ORDER_ENHANCED"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    snowflake.execute({sqlText: ''TRUNCATE TABLE INT.FCT_ORDER_ENHANCED''});

    var sql_insert = `
      INSERT INTO INT.FCT_ORDER_ENHANCED (
        ORDER_ID, CUSTOMER_ID, RESTAURANT_ID, ORDER_DATE_KEY,
        ORDER_STATUS, PAYMENT_METHOD, PROMO_ID,
        ORDER_SUBTOTAL, ORDER_DISCOUNT, DELIVERY_FEE, TOTAL_AMOUNT,
        NET_FOOD_AMOUNT, DISCOUNT_PCT, SLA_BREACHED,
        PLATFORM_COMMISSION, RESTAURANT_PAYOUT,
        END_TO_END_MIN, IS_DELIVERED, IS_CANCELLED
      )
      SELECT
        oh.ORDER_ID,
        oh.CUSTOMER_ID,
        oh.RESTAURANT_ID,
        dd.DATE_KEY AS ORDER_DATE_KEY,
        oh.ORDER_STATUS,
        oh.PAYMENT_METHOD,
        oh.PROMO_ID,
        oh.ORDER_SUBTOTAL,
        oh.ORDER_DISCOUNT,
        oh.DELIVERY_FEE,
        oh.TOTAL_AMOUNT,
        (oh.ORDER_SUBTOTAL - oh.ORDER_DISCOUNT)                          AS NET_FOOD_AMOUNT,
        CASE WHEN oh.ORDER_SUBTOTAL > 0 THEN oh.ORDER_DISCOUNT/oh.ORDER_SUBTOTAL ELSE 0 END AS DISCOUNT_PCT,
        CASE WHEN dt.SLA_BREACH_FLAG = 1 THEN 1 ELSE 0 END              AS SLA_BREACHED,
        (oh.TOTAL_AMOUNT * r.COMMISSION_RATE)                            AS PLATFORM_COMMISSION,
        (oh.TOTAL_AMOUNT - (oh.TOTAL_AMOUNT * r.COMMISSION_RATE))       AS RESTAURANT_PAYOUT,
        DATEDIFF(''minute'', oh.ORDER_CREATED_AT, oh.ACTUAL_DELIVERY_AT)  AS END_TO_END_MIN,
        CASE WHEN oh.ORDER_STATUS = ''DELIVERED'' THEN 1 ELSE 0 END       AS IS_DELIVERED,
        CASE WHEN oh.ORDER_STATUS = ''CANCELLED'' THEN 1 ELSE 0 END       AS IS_CANCELLED
      FROM STG.V_ORDER_HEADER_STG oh
      LEFT JOIN INT.DIM_DATE dd
        ON dd.FULL_DATE = CAST(oh.ORDER_CREATED_AT AS DATE)
      LEFT JOIN STG.V_DELIVERY_TRIP_STG dt
        ON oh.ORDER_ID = dt.ORDER_ID
      LEFT JOIN STG.V_RESTAURANT_STG r
        ON oh.RESTAURANT_ID = r.RESTAURANT_ID
    `;
    snowflake.execute({sqlText: sql_insert});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_LOAD_FCT_ORDER_ENHANCED'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''FCT_ORDER_ENHANCED loaded'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''FCT_ORDER_ENHANCED loaded successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_LOAD_FCT_ORDER_ENHANCED'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_LOAD_FCT_ORDER_ENHANCED: '' + err;
  }
';
