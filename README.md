# Analyzing NBA Player Statistics with SQL
 
This repository contains a collection of advanced SQL queries designed for analyzing NBA player and team performance metrics. These queries are designed to work with a BigQuery dataset (`utopian-honor-385413.nba_data.player_stats`) containing comprehensive NBA statistics.

## Data Source

The data used in these queries is from the "NBA Gamelogs 2024-25" dataset on Kaggle:
- Source: [NBA Gamelogs 2024-25 on Kaggle](https://www.kaggle.com/datasets/joopaivaaaaaaa/nba-gamelogs-2024-25)
- The dataset contains detailed NBA game statistics for the 2024-25 season.

## Table of Contents

1. [Comprehensive Player Efficiency Analysis](#1-comprehensive-player-efficiency-analysis)
2. [Advanced Defensive Impact Analysis](#2-advanced-defensive-impact-analysis)
3. [Offensive Creation vs. Efficiency](#3-offensive-creation-vs-efficiency)
4. [Pace Impact Analysis](#4-pace-impact-analysis)
5. [Player Versatility Index](#5-player-versatility-index)
6. [Rebounding Specialists Analysis](#6-rebounding-specialists-analysis)
7. [Player Ranking Changes Over Time](#7-player-ranking-changes-over-time)
8. [Advanced Analytics Dashboard View](#8-advanced-analytics-dashboard-view)
9. [Most Efficient Scorers Analysis](#9-most-efficient-scorers-analysis)
10. [Turnover Efficiency Analysis](#10-turnover-efficiency-analysis)
11. [Player Comparison](#11-player-comparison)

## Query Descriptions

### 1. Comprehensive Player Efficiency Analysis

This query combines multiple efficiency metrics to find the most well-rounded efficient players in the league. It creates a composite `EFFICIENCY_INDEX` based on PIE (Player Impact Estimate), TS% (True Shooting Percentage), EFG% (Effective Field Goal Percentage), and AST/TO (Assist to Turnover ratio).

The query filters for players who have appeared in more than 30 games to ensure statistical significance.

### 2. Advanced Defensive Impact Analysis

Identifies the best defensive players based on multiple defensive metrics, including defensive rating rank and defensive rebounding percentage. It categorizes players into defensive tiers (Elite, Above Average, Average, Below Average) based on their defensive rating rank.

Only players with more than 20 games played are included in the analysis.

### 3. Offensive Creation vs. Efficiency

Analyzes which players create the most offense while maintaining efficiency. The query uses a Common Table Expression (CTE) to calculate a `CREATION_EFFICIENCY_RANK` based on a formula that factors in assist ratio, true shooting percentage, and turnover percentage.

This analysis focuses on significant playmakers (players with an assist ratio > 10) who have played more than 25 games.

### 4. Pace Impact Analysis

Examines how pace affects team performance by calculating average team pace, effective pace, and win percentage for each team. It also ranks teams by both pace and win percentage to identify any correlation between playing fast and winning games.

### 5. Player Versatility Index

Creates a composite metric to identify the most versatile players in the league. The versatility index weights different aspects of performance:
- Player Impact Estimate (30%)
- Assist Ratio (25%)
- Rebounding Percentage (25%)
- True Shooting Percentage (20%)

The query filters for players with more than 25 games played.

### 6. Rebounding Specialists Analysis

Identifies the best offensive, defensive, and overall rebounders in the league. It categorizes players into three types of rebounders:
- Offensive Rebounder (when OREB% > DREB% * 1.5)
- Defensive Rebounder (when DREB% > OREB% * 1.5)
- Balanced Rebounder (when neither condition is met)

Only significant rebounders (REB% > 8%) with more than 20 games played are included.

### 7. Player Ranking Changes Over Time

Uses a temporary table to track how player rankings change over the season. It creates a composite rank based on PIE rank, EFG% rank, TS% rank, and NET rating rank.

Players with fewer than 10 games played are excluded from this analysis.

### 8. Advanced Analytics Dashboard View

Creates a view called `advanced_player_metrics` for dashboard visualization purposes. The view includes a calculated `PLAYER_IMPACT_SCORE` that weights various performance metrics:
- PIE (30%)
- TS% (20%)
- Assist Ratio (20%)
- Rebounding Percentage (20%)
- Turnover Percentage (-10%, as a penalty)

Only players with more than 20 games played are included in this view.

### 9. Most Efficient Scorers Analysis

Identifies players with the best scoring efficiency based on a calculated `SCORING_EFFICIENCY` metric that multiplies TS% and EFG%. The query focuses on significant scorers (players with more than 8 field goal attempts per game) who have played more than 20 games.

### 10. Turnover Efficiency Analysis

Identifies which players have the best assist-to-turnover balance by calculating a `BALL_HANDLING_EFFICIENCY` metric. This analysis focuses on players with significant playmaking responsibilities (assist ratio > 5) who have played more than 20 games.

### 11. Player Comparison

Provides a comprehensive player analysis for a specific player (in this case, Alperen Sengun). The query calculates offensive, defensive, and overall percentiles based on the player's league ranks, providing context for how the player compares to the rest of the league.

Only players with more than 20 games played are included in this analysis.


## Key Metrics Explained

- **PIE (Player Impact Estimate)**: A measure of a player's overall statistical contribution
- **TS% (True Shooting Percentage)**: A measure of shooting efficiency that accounts for field goals, 3-point field goals, and free throws
- **EFG% (Effective Field Goal Percentage)**: A measure of shooting efficiency that adjusts for the fact that a 3-point field goal is worth more than a 2-point field goal
- **USG% (Usage Percentage)**: An estimate of the percentage of team plays used by a player while they are on the floor
- **AST_RATIO (Assist Ratio)**: The percentage of a player's possessions that end in an assist
- **REB% (Rebound Percentage)**: The percentage of available rebounds a player grabbed while on the floor
- **PACE**: An estimate of the number of possessions per 48 minutes


## Note

These queries assume that rankings in the dataset follow the convention where lower numbers indicate better performance (e.g., a DEF_RATING_RANK of 1 means the player has the best defensive rating in the league).
