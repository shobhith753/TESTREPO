CREATE OR REPLACE PROCEDURE "SP_REFRESH_FCT_ORDER_SECURE"()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
  try {
    snowflake.execute({sqlText: ''BEGIN''});

    snowflake.execute({sqlText: ''TRUNCATE TABLE MARTS.FCT_ORDER_SECURE''});

    var sql = `
      INSERT INTO MARTS.FCT_ORDER_SECURE (
        ORDER_ID,
        ORDER_DATE_KEY,
        FULL_DATE,
        TOTAL_AMOUNT,
        ORDER_SUBTOTAL,
        ORDER_DISCOUNT,
        DELIVERY_FEE,
        NET_FOOD_AMOUNT,
        DISCOUNT_PCT,
        SLA_BREACHED,
        PLATFORM_COMMISSION,
        RESTAURANT_PAYOUT,
        END_TO_END_MIN,
        ORDER_STATUS,
        PAYMENT_METHOD,
        PROMO_ID,
        IS_DELIVERED,
        IS_CANCELLED,
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CUSTOMER_CITY,
        CUSTOMER_AREA,
        CUSTOMER_SEGMENT,
        RESTAURANT_ID,
        RESTAURANT_NAME,
        RESTAURANT_CITY,
        RESTAURANT_AREA,
        CUISINE_PRIMARY,
        COMMISSION_RATE,
        DISTANCE_KM,
        SLA_BREACH_FLAG,
        RATING,
        SENTIMENT_SCORE
      )
      SELECT
        ORDER_ID,
        ORDER_DATE_KEY,
        FULL_DATE,
        TOTAL_AMOUNT,
        ORDER_SUBTOTAL,
        ORDER_DISCOUNT,
        DELIVERY_FEE,
        NET_FOOD_AMOUNT,
        DISCOUNT_PCT,
        SLA_BREACHED,
        PLATFORM_COMMISSION,
        RESTAURANT_PAYOUT,
        END_TO_END_MIN,
        ORDER_STATUS,
        PAYMENT_METHOD,
        PROMO_ID,
        IS_DELIVERED,
        IS_CANCELLED,
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CUSTOMER_CITY,
        CUSTOMER_AREA,
        CUSTOMER_SEGMENT,
        RESTAURANT_ID,
        RESTAURANT_NAME,
        RESTAURANT_CITY,
        RESTAURANT_AREA,
        CUISINE_PRIMARY,
        COMMISSION_RATE,
        DISTANCE_KM,
        SLA_BREACH_FLAG,
        RATING,
        SENTIMENT_SCORE
      FROM MARTS.V_ORDER_ENRICHED
    `;
    snowflake.execute({sqlText: sql});

    snowflake.execute({sqlText: `
      INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
      VALUES (''SP_REFRESH_FCT_ORDER_SECURE'', CURRENT_TIMESTAMP(), ''SUCCESS'', ''FCT_ORDER_SECURE refreshed'')
    `});

    snowflake.execute({sqlText: ''COMMIT''});
    return ''FCT_ORDER_SECURE refreshed successfully'';
  } catch (err) {
    try { snowflake.execute({sqlText: ''ROLLBACK''}); } catch (e2) {}
    snowflake.execute({
      sqlText: `
        INSERT INTO UTIL.PROC_AUDIT_LOG(PROC_NAME,RUN_TS,STATUS,MESSAGE)
        VALUES (''SP_REFRESH_FCT_ORDER_SECURE'', CURRENT_TIMESTAMP(), ''ERROR'', :msg)
      `,
      binds: { msg: err.toString() }
    });
    return ''ERROR in SP_REFRESH_FCT_ORDER_SECURE: '' + err;
  }
';
