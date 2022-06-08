#StandardSQL
WITH table AS (
  SELECT
    day,
    pv
  FROM
    `bigquery-access-log.HP_access_data_mart.daily_pv`
  UNION ALL
  SELECT
    DATE_SUB(@run_date, INTERVAL 1 DAY),
    COUNT(time) pv
  FROM
    `bigquery-access-log.HP_access_data_lake.access_log_*`
  WHERE
    _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d',DATE_SUB(@run_date, INTERVAL 1 DAY))
)

SELECT
  day,
  pv
FROM
  table
ORDER BY
  day
