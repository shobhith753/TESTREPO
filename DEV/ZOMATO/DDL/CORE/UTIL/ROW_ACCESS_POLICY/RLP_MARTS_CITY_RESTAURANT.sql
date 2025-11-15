create or replace row access policy RLP_MARTS_CITY_RESTAURANT as (RESTAURANT_CITY VARCHAR, RESTAURANT_ID NUMBER(38,0)) 
returns BOOLEAN ->
CASE
    -- Admin/system roles see everything
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'ZOMATO_SYSADMIN') THEN TRUE

    -- For other roles, check mapping table
    ELSE EXISTS (
      SELECT 1
      FROM UTIL.RLS_ROLE_ACCESS r
      WHERE r.ROLE_NAME = CURRENT_ROLE()
        AND (
             (r.ACCESS_TYPE = 'CITY'
              AND r.CITY = RESTAURANT_CITY)
          OR (r.ACCESS_TYPE = 'RESTAURANT'
              AND r.RESTAURANT_ID = RESTAURANT_ID)
        )
    )
  END
;
