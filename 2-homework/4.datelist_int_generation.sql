WITH users AS (
    SELECT * FROM user_devices_cumulated
    WHERE date = DATE('2023-01-31')
),
    series AS (
        SELECT * FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'),
                                      INTERVAL '1 day') as series_date
    ),
    place_holder_ints AS (
    select
         case
             when
                device_activity_datelist @> ARRAY [DATE(series_date)]
                THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
             else 0
             end as placeholder_int_value,
        *
    from users CROSS JOIN series
    )
SELECT
    user_id, browser_type, placeholder_int_value
FROM place_holder_ints;