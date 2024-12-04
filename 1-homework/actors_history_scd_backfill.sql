insert into actors_history_scd
WITH with_previous AS (SELECT actor,
                                      actorid,
                                      current_year,
                                      quality_class,
                                      is_active,
                                      LAG(quality_class, 1) OVER (PARTITION BY actorid ORDER BY current_year)
                                          as previous_quality_class,
                                      LAG(is_active, 1) OVER (PARTITION BY actorid ORDER BY current_year)
                                          as previous_is_active
                               from actors
                               where current_year <= 2021),
            with_indicators AS (
                SELECT *,
                       CASE
                           WHEN quality_class <> previous_quality_class THEN 1
                           WHEN is_active <> previous_is_active THEN 1
                           ELSE 0
                       END as change_indicator
                FROM with_previous
                        ),
                with_streaks AS (
                    select *,
                   SUM(change_indicator)
                   over(partition by actorid order by current_year)
                    AS streak_identifier
                        from with_indicators
                )
        select actor,
               actorid,
               is_active,
               quality_class,
               min(current_year) as start_date,
               max(current_year) as end_date,
               2021 as current_year
        from with_streaks
        group by actor, actorid, streak_identifier, is_active, quality_class
        order by actor, streak_identifier;
