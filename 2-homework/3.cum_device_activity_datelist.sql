DO
$$
DECLARE
    _date DATE := DATE '2022-12-31';
BEGIN
    -- Loop from December 31st of one year to January 31st of the next year
    WHILE _date <= DATE '2023-01-31' LOOP
insert into user_devices_cumulated
with yesterday AS (
    SELECT
        *
    FROM user_devices_cumulated
    WHERE date = _date
),
    today AS (
    SELECT
        CAST(e.user_id AS TEXT) as user_id,
        CAST(d.browser_type AS TEXT) as browser_type,
        DATE(CAST(e.event_time AS TIMESTAMP)) AS date_active
    FROM events e join devices d on e.device_id = d.device_id
    WHERE
        DATE(CAST(event_time AS TIMESTAMP)) = _date + interval '1 day'
        AND user_id is not null
    )
    select
        COALESCE(t.user_id, y.user_id) AS user_id,
        COALESCE(t.browser_type, y.browser_type) as browser_type,
        CASE
            WHEN y.device_activity_datelist IS NULL
            THEN ARRAY[t.date_active]
            WHEN t.date_active is null then y.device_activity_datelist
            ELSE ARRAY[t.date_active] || y.device_activity_datelist
            END
            AS device_activity_datelist,
        COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date
        FROM today t
        FULL OUTER JOIN yesterday y
        ON t.user_id = y.user_id and t.browser_type = y.browser_type
on conflict (user_id, browser_type, date) do nothing ;
    _date := _date + interval '1 day';
    END LOOP;
END
$$;