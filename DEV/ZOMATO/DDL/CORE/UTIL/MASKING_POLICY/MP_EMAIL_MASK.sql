create or replace masking policy MP_EMAIL_MASK as (VAL VARCHAR) 
returns VARCHAR ->
CASE
    WHEN CURRENT_ROLE() IN ('ZOMATO_PII_ADMIN_ROLE','ACCOUNTADMIN') THEN VAL
    ELSE REGEXP_REPLACE(VAL, '(^.).*(@.*$)', '\\1*****\\2')
  END
;
