with deduped AS (
    select
        g.game_date_est,
        g.season,
        g.home_team_id,
        gd.*,
        row_number() over (partition by
            gd.game_id,
            gd.team_id,
            gd.player_id) as row_num
    from game_details gd join games g on gd.game_id = g.game_id
--     WHERE g.game_date_est = '2016-10-04'
)
select
    game_date_est as dim_game_date,
    season as dim_season,
    team_id as dim_team_id,
    player_id as dim_player_id,
    player_name as dim_player_name,
    start_position as dim_start_position,
    team_id = home_team_id AS dim_is_playing_at_home,
    COALESCE(POSITION('DNP' in comment), 0) > 0
        as dim_did_not_play,
    COALESCE(POSITION('DND' in comment), 0) > 0
        as dim_did_not_dress,
    COALESCE(POSITION('NWT' in comment), 0) > 0
        as dim_not_with_team,
    CAST(SPLIT_PART(min, ':', 1) as real) + CAST(SPLIT_PART(min, ':', 2) AS real)/60
        AS m_minutes,
    fgm as m_fgm,
    fga as m_fga,
    fg3m as m_fg3m,
    fg3a as m_fg3a,
    ftm as m_ftm,
    fta as m_fta,
    oreb as m_oreb,
    dreb as m_dreb,
    reb as m_reb,
    ast as m_ast,
    stl as m_stl,
    blk AS m_blk,
    "TO" AS m_turnovers,
    pf AS m_pf,
    pts AS m_pts,
    plus_minus  AS m_plus_minus
from deduped
where  row_num = 1;