insert into hosts_cumulated
with yesterday AS (
    SELECT
        *
    FROM hosts_cumulated
    WHERE date = '2023-01-01'
),
    today AS (
        SELECT
            host,
            CAST(event_time AS DATE) AS date
        FROM events
        WHERE CAST(event_time AS DATE) = '2023-01-02'
        and host is not null
    )
    SELECT
        COALESCE(y.host, t.host) AS host,
        COALESCE(t.date, y.date + INTERVAL '1 day') AS date,
        CASE
            WHEN y.host_activity_datelist IS NULL THEN ARRAY[t.date]
            WHEN t.date IS NULL THEN y.host_activity_datelist
            ELSE ARRAY[t.date] || y.host_activity_datelist
            END
        AS host_activity_datelist
    FROM yesterday y FULL OUTER JOIN today t on y.host = t.host
on conflict (host, date) do nothing;