-- ===========================================
-- Lesson 3: Advanced SQL - Practice Exercises
-- GameVerse Database
-- ===========================================

-- ===========================================
-- EXERCISE 1: Window Functions
-- ===========================================

-- 1.1 Rank players within each subscription tier by total spending
-- Expected columns: username, subscription_tier, total_spent, tier_rank
-- Use RANK() for ranking

-- YOUR QUERY HERE:


-- 1.2 Calculate each player's score improvement over their previous score
-- (for the same game)
-- Expected columns: username, game_name, score_value, prev_score, improvement
-- Use LAG() to get previous score

-- YOUR QUERY HERE:


-- 1.3 Find the percentage of total revenue each game contributes
-- Expected columns: game_name, game_revenue, total_revenue, pct_of_total

-- YOUR QUERY HERE:


-- 1.4 For each player, show their first and last game session dates
-- Expected columns: username, first_session, last_session, days_active

-- YOUR QUERY HERE:


-- 1.5 Create player spending quartiles (Q1, Q2, Q3, Q4)
-- and show the spending range for each quartile
-- Expected columns: quartile, min_spent, max_spent, player_count

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 2: Common Table Expressions (CTEs)
-- ===========================================

-- 2.1 Build a player engagement report using multiple CTEs
-- Include: sessions played, total playtime, games played, achievements earned
-- Expected columns: username, subscription_tier, sessions, playtime,
--                   games_played, achievements

-- YOUR QUERY HERE:


-- 2.2 Create a daily retention analysis using CTEs
-- For each day, show how many players played and how many returned the next day
-- Expected columns: play_date, players_that_day, returned_next_day, retention_rate

-- YOUR QUERY HERE:


-- 2.3 Calculate month-over-month growth in revenue using CTEs
-- Expected columns: month, monthly_revenue, prev_month_revenue, growth_pct

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 3: Normalization
-- ===========================================

-- 3.1 Identify which tables in GameVerse demonstrate 1NF
-- (atomic values, no repeating groups)
-- Write a query that shows data from a table following 1NF principles

-- YOUR QUERY HERE:


-- 3.2 Show an example of 2NF by querying related tables
-- that separate entity information correctly
-- (e.g., player info separate from score info)

-- YOUR QUERY HERE:


-- 3.3 Write a query that would have issues if the database wasn't normalized
-- Then show how our normalized design makes it work properly

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 4: Query Optimization
-- ===========================================

-- 4.1 Rewrite this query to be more efficient:
-- Original (BAD):
-- SELECT * FROM game_sessions WHERE EXTRACT(YEAR FROM session_start) = 2024;
-- Write an optimized version:

-- YOUR QUERY HERE:


-- 4.2 Rewrite using EXISTS instead of IN:
-- Original: SELECT * FROM players WHERE player_id IN (SELECT player_id FROM transactions);
-- Write an optimized version:

-- YOUR QUERY HERE:


-- 4.3 Write a query and its EXPLAIN to understand the execution plan
-- Query players with their session counts, then analyze the plan

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 5: Data Engineering Patterns
-- ===========================================

-- 5.1 Write an UPSERT to update daily_player_stats
-- If the record exists, add to the totals
-- If not, insert new record

-- YOUR QUERY HERE:


-- 5.2 Write a deduplication query to find and list duplicate event logs
-- (same event_type, player_id, and created_at within the same minute)

-- YOUR QUERY HERE:


-- 5.3 Write a query to identify data quality issues:
-- - Players without any sessions
-- - Sessions without valid player references
-- - Scores with negative values

-- YOUR QUERY HERE:
