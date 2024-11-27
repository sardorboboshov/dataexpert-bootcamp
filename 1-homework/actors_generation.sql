INSERT INTO actors
with last_year AS (
    SELECT * FROM actors
    WHERE current_year = 1969
),
    this_year AS (
    SELECT
        actor,
        actorid,
        year,
        ARRAY_AGG(ROW(film, votes, rating, filmid)::films) AS films,
        AVG(rating) AS avg_rating
    FROM actor_films
    where year = 1970
    GROUP BY actor, actorid, year
    )
SELECT
    COALESCE(ty.actor, ly.actor) AS actor,
    COALESCE(ty.actorid, ly.actorid) AS actorid,
    COALESCE(ty.year, ly.current_year + 1) as current_year,

    CASE
        WHEN ly.films IS NULL THEN ty.films
        WHEN ty.films IS NOT NULL THEN ly.films || ty.films
        ELSE ly.films
    END AS films,
    CASE
        WHEN ty.year IS NOT NULL THEN
            CASE
                WHEN ty.avg_rating > 8 THEN 'star'
                WHEN ty.avg_rating > 7 THEN 'good'
                WHEN ty.avg_rating > 6 THEN 'average'
                ELSE 'bad'
            END::quality_class
        ELSE ly.quality_class
    END AS quality_class,
    CASE WHEN ty.year IS NULL THEN FALSE
        ELSE TRUE
        END AS is_active


FROM last_year ly FULL OUTER JOIN this_year ty on ly.actorid = ty.actorid;