create or replace view V_MENU_ITEM_STG(
	MENU_ITEM_ID,
	RESTAURANT_ID,
	ITEM_NAME,
	CATEGORY,
	PRICE,
	IS_VEG,
	IS_ACTIVE
) as
SELECT
  TRY_TO_NUMBER(MENU_ITEM_ID)                                 AS MENU_ITEM_ID,
  TRY_TO_NUMBER(RESTAURANT_ID)                                AS RESTAURANT_ID,
  TRIM(ITEM_NAME)                                             AS ITEM_NAME,
  TRIM(CATEGORY)                                              AS CATEGORY,
  COALESCE(TRY_TO_NUMBER(PRICE), 0)                           AS PRICE,
  COALESCE(
    TRY_TO_BOOLEAN(
      CASE UPPER(TRIM(IS_VEG))
        WHEN 'Y' THEN 'TRUE'
        WHEN '1' THEN 'TRUE'
        WHEN 'TRUE' THEN 'TRUE'
        ELSE 'FALSE'
      END
    ), FALSE
  )                                                           AS IS_VEG,
  COALESCE(
    TRY_TO_BOOLEAN(
      CASE UPPER(TRIM(IS_ACTIVE))
        WHEN 'Y' THEN 'TRUE'
        WHEN '1' THEN 'TRUE'
        WHEN 'TRUE' THEN 'TRUE'
        ELSE 'FALSE'
      END
    ), TRUE
  )                                                           AS IS_ACTIVE
FROM RAW.MENU_ITEM_RAW;
