insert into host_activity_reduced
with daily_aggregate AS (
    SELECT
        host,
        DATE(event_time) AS date,
        COUNT(1) AS num_site_hits,
        COUNT(DISTINCT user_id) AS num_unique_visitors
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-03')
    AND host is not null
    group by host, event_time
),
    yesterday_array AS (
        SELECT * FROM host_activity_reduced
                WHERE month = DATE('2023-01-01')
    )
SELECT
    COALESCE(ya.month, DATE_TRUNC('month', da.date)) AS month,
    COALESCE(da.host, ya.host) as host,
    CASE WHEN ya.hit_array IS NOT NULL THEN
        ya.hit_array || ARRAY[COALESCE(da.num_site_hits, 0)]
    WHEN ya.hit_array IS NULL
        THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)])
                 || ARRAY[COALESCE(da.num_site_hits, 0)]
    END AS hit_array,
    CASE WHEN ya.unique_visitors IS NOT NULL THEN
        ya.unique_visitors || ARRAY[COALESCE(da.num_unique_visitors, 0)]
    WHEN ya.unique_visitors IS NULL
        THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)])
                 || ARRAY[COALESCE(da.num_unique_visitors, 0)]
    END AS unique_visitors


FROM daily_aggregate da
    FULL OUTER JOIN yesterday_array ya on da.host = ya.host
on conflict (host, month) do nothing ;