-- 1. Comprehensive Player Efficiency Analysis
-- Combines multiple efficiency metrics to find the most well-rounded efficient players

SELECT 
    PLAYER_NAME, 
    TEAM_ABBREVIATION, 
    GP,
    PIE,
    TS_PCT,
    EFG_PCT,
    AST_RATIO,
    AST_TO,
    USG_PCT,
    REB_PCT,
    ROUND((PIE + TS_PCT + EFG_PCT/2 + AST_TO/10), 3) AS EFFICIENCY_INDEX
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 30
ORDER BY EFFICIENCY_INDEX DESC
LIMIT 30;

-- 2. Advanced Defensive Impact Analysis
-- Identifies the best defensive players based on multiple defensive metrics

SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    DEF_RATING_RANK,
    DREB_PCT,
    DREB_PCT_RANK,
    PIE,
    CASE 
        WHEN DEF_RATING_RANK <= 20 THEN 'Elite'
        WHEN DEF_RATING_RANK <= 50 THEN 'Above Average'
        WHEN DEF_RATING_RANK <= 100 THEN 'Average'
        ELSE 'Below Average'
    END AS DEFENSIVE_TIER
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 20
ORDER BY DEF_RATING_RANK, DREB_PCT_RANK
LIMIT 30;

-- 3. Offensive Creation vs. Efficiency
-- Analyzes which players create the most offense while maintaining efficiency

WITH CreationEfficiency AS (
    SELECT
        PLAYER_NAME,
        TEAM_ABBREVIATION,
        AST_PCT_RANK,
        USG_PCT,
        TS_PCT,
        EFG_PCT,
        E_TOV_PCT,
        AST_RATIO,
        RANK() OVER (ORDER BY (AST_RATIO * TS_PCT / NULLIF(E_TOV_PCT, 0)) DESC) AS CREATION_EFFICIENCY_RANK
    FROM `utopian-honor-385413.nba_data.player_stats`
    WHERE GP > 25 AND AST_RATIO > 10 -- Focus on significant playmakers
)
SELECT *
FROM CreationEfficiency
WHERE CREATION_EFFICIENCY_RANK <= 20
ORDER BY CREATION_EFFICIENCY_RANK;

-- 4. Pace Impact Analysis
-- Examines how pace affects team performance

SELECT
    TEAM_ABBREVIATION,
    ROUND(AVG(PACE), 2) AS AVG_TEAM_PACE,
    ROUND(AVG(E_PACE), 2) AS AVG_EFFECTIVE_PACE,
    ROUND(AVG(W/NULLIF(GP, 0))*100, 2) AS WIN_PERCENTAGE,
    RANK() OVER (ORDER BY AVG(PACE) DESC) AS PACE_RANK,
    RANK() OVER (ORDER BY AVG(W/NULLIF(GP, 0)) DESC) AS WIN_RANK
FROM `utopian-honor-385413.nba_data.player_stats`
GROUP BY TEAM_ABBREVIATION
ORDER BY AVG_TEAM_PACE DESC;

-- 5. Player Versatility Index Using CTE
-- Creates a composite metric to identify the most versatile players

WITH PlayerVersatility AS (
    SELECT
        PLAYER_NAME,
        TEAM_ABBREVIATION,
        PIE,
        AST_RATIO,
        REB_PCT,
        TS_PCT,
        USG_PCT,
        (
            (PIE * 0.3) + 
            (AST_RATIO/30 * 0.25) + 
            (REB_PCT * 0.25) + 
            (TS_PCT * 0.2)
        ) AS VERSATILITY_INDEX
    FROM `utopian-honor-385413.nba_data.player_stats`
    WHERE GP > 25
)
SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    ROUND(VERSATILITY_INDEX, 3) AS VERSATILITY_INDEX,
    RANK() OVER (ORDER BY VERSATILITY_INDEX DESC) AS VERSATILITY_RANK
FROM PlayerVersatility
ORDER BY VERSATILITY_RANK
LIMIT 25;

-- 6. Rebounding Specialists Analysis
-- Identifies the best offensive, defensive, and overall rebounders

SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    OREB_PCT,
    DREB_PCT,
    REB_PCT,
    OREB_PCT_RANK,
    DREB_PCT_RANK,
    REB_PCT_RANK,
    CASE
        WHEN OREB_PCT > DREB_PCT * 1.5 THEN 'Offensive Rebounder'
        WHEN DREB_PCT > OREB_PCT * 1.5 THEN 'Defensive Rebounder'
        ELSE 'Balanced Rebounder'
    END AS REBOUNDER_TYPE
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 20 AND REB_PCT > 0.08 -- Focus on significant rebounders
ORDER BY REB_PCT DESC
LIMIT 30;

-- 7. Player Ranking Changes Over Time (Using Temp Table)
-- Tracks how player rankings change over the season

CREATE OR REPLACE TEMP TABLE PlayerRankHistory AS
SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    GP,
    PIE_RANK,
    EFG_PCT_RANK,
    TS_PCT_RANK,
    OFF_RATING_RANK,
    DEF_RATING_RANK,
    NET_RATING_RANK
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 10;

SELECT
    p.PLAYER_NAME,
    p.TEAM_ABBREVIATION,
    p.GP,
    p.PIE_RANK,
    p.EFG_PCT_RANK,
    p.TS_PCT_RANK,
    p.NET_RATING_RANK,
    RANK() OVER (ORDER BY (p.PIE_RANK + p.EFG_PCT_RANK + p.TS_PCT_RANK + p.NET_RATING_RANK) ASC) AS COMPOSITE_RANK
FROM PlayerRankHistory p
ORDER BY COMPOSITE_RANK
LIMIT 20;

-- 8. Creating View for Advanced Analytics Dashboard

CREATE OR REPLACE VIEW `utopian-honor-385413.nba_data.advanced_player_metrics` AS
SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    GP,
    W,
    L,
    PIE,
    TS_PCT,
    EFG_PCT,
    USG_PCT,
    AST_RATIO,
    AST_TO,
    REB_PCT,
    OREB_PCT,
    DREB_PCT,
    E_TOV_PCT,
    PACE,
    OFF_RATING_RANK,
    DEF_RATING_RANK,
    NET_RATING_RANK,
    PIE_RANK,
    TS_PCT_RANK,
    (PIE * 0.3 + TS_PCT * 0.2 + AST_RATIO/30 * 0.2 + REB_PCT * 0.2 - E_TOV_PCT * 0.1) AS PLAYER_IMPACT_SCORE
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 20;

-- 9. Most Efficient Scorers Analysis
-- Identifies players with the best scoring efficiency

SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    FGM_PG,
    FGA_PG,
    ROUND(FGM_PG/NULLIF(FGA_PG, 0), 3) AS FG_PCT,
    TS_PCT,
    EFG_PCT,
    USG_PCT,
    ROUND((TS_PCT * EFG_PCT * 100), 2) AS SCORING_EFFICIENCY
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE FGA_PG > 8 AND GP > 20  -- Focus on significant scorers
ORDER BY SCORING_EFFICIENCY DESC
LIMIT 20;

-- 10. Turnover Efficiency Analysis
-- Identifies which players have the best assist-to-turnover balance

SELECT
    PLAYER_NAME,
    TEAM_ABBREVIATION,
    AST_RATIO,
    AST_TO,
    E_TOV_PCT,
    TM_TOV_PCT,
    ROUND((AST_RATIO / NULLIF(E_TOV_PCT, 0)), 2) AS BALL_HANDLING_EFFICIENCY
FROM `utopian-honor-385413.nba_data.player_stats`
WHERE GP > 20 AND AST_RATIO > 5  -- Players with significant playmaking
ORDER BY BALL_HANDLING_EFFICIENCY DESC
LIMIT 25;




-- Player Comparison 

-- Main player analysis
SELECT
  p.PLAYER_NAME,
  p.TEAM_ABBREVIATION,
  
  -- Offensive metrics
  p.TS_PCT AS `True Shooting %`,
  p.EFG_PCT AS `Effective Field Goal %`,
  p.USG_PCT AS `Usage %`,
  p.AST_RATIO AS `Assist Ratio`,
  p.OFF_RATING_RANK AS `League Offensive Rank`,
  
  -- Defensive metrics
  p.DEF_RATING_RANK AS `League Defensive Rank`,
  p.DREB_PCT AS `Defensive Rebound %`,
  
  -- Overall metrics
  p.PIE AS `Player Impact Estimate`,
  p.NET_RATING_RANK AS `League Net Rating Rank`,
  
  -- Simple league percentile calculations (lower rank number is better)
  CONCAT(ROUND((1 - (p.OFF_RATING_RANK / total_players)) * 100), '%') AS `Offensive Percentile`,
  CONCAT(ROUND((1 - (p.DEF_RATING_RANK / total_players)) * 100), '%') AS `Defensive Percentile`,
  CONCAT(ROUND((1 - (p.NET_RATING_RANK / total_players)) * 100), '%') AS `Overall Percentile`

FROM 
  `utopian-honor-385413.nba_data.player_stats` p,
  (SELECT COUNT(*) AS total_players FROM `utopian-honor-385413.nba_data.player_stats` WHERE GP > 20) as counts
  
WHERE 
  p.PLAYER_NAME = 'Alperen Sengun'  -- Change to any player name
  AND p.GP > 20;  -- Only players with significant minutes
