create or replace view V_CUSTOMER_EVENTS_STG(
	EVENT_ID,
	CUSTOMER_ID,
	EVENT_TYPE,
	EVENT_TS,
	SEARCH_QUERY,
	DEVICE_OS,
	APP_VERSION
) as
SELECT
  EVENT_RAW:"event_id"::NUMBER                               AS EVENT_ID,
  EVENT_RAW:"customer_id"::NUMBER                            AS CUSTOMER_ID,
  EVENT_RAW:"event_type"::STRING                             AS EVENT_TYPE,
  TRY_TO_TIMESTAMP_NTZ(EVENT_RAW:"event_ts"::STRING)         AS EVENT_TS,
  EVENT_RAW:"metadata":"search_query"::STRING                AS SEARCH_QUERY,
  EVENT_RAW:"metadata":"device_os"::STRING                   AS DEVICE_OS,
  EVENT_RAW:"metadata":"app_version"::STRING                 AS APP_VERSION
FROM RAW.CUSTOMER_EVENTS_RAW;
