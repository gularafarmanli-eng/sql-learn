-- ===========================================
-- Lesson 3: Advanced SQL - Example Queries
-- GameVerse Database
-- ===========================================

-- ===========================================
-- PART 1: WINDOW FUNCTIONS
-- ===========================================

-- 1.1 ROW_NUMBER: Unique rank for each row
SELECT
    username,
    country_code,
    total_playtime_minutes,
    ROW_NUMBER() OVER (
        PARTITION BY country_code
        ORDER BY total_playtime_minutes DESC
    ) AS country_rank
FROM players
WHERE country_code IS NOT NULL
ORDER BY country_code, country_rank;

-- 1.2 RANK vs DENSE_RANK: Handle ties in leaderboards
SELECT
    p.username,
    g.game_name,
    s.score_value,
    RANK() OVER (PARTITION BY g.game_id ORDER BY s.score_value DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY g.game_id ORDER BY s.score_value DESC) AS dense_rank,
    ROW_NUMBER() OVER (PARTITION BY g.game_id ORDER BY s.score_value DESC) AS row_num
FROM scores s
INNER JOIN players p ON s.player_id = p.player_id
INNER JOIN games g ON s.game_id = g.game_id
ORDER BY g.game_name, s.score_value DESC;

-- 1.3 LAG: Access previous row's value
SELECT
    p.username,
    gs.session_start,
    gs.duration_minutes,
    LAG(gs.session_start) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
    ) AS prev_session,
    LAG(gs.duration_minutes) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
    ) AS prev_duration
FROM game_sessions gs
INNER JOIN players p ON gs.player_id = p.player_id
ORDER BY p.username, gs.session_start;

-- 1.4 LEAD: Access next row's value
SELECT
    p.username,
    gs.session_start,
    gs.duration_minutes,
    LEAD(gs.session_start) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
    ) AS next_session,
    LEAD(gs.duration_minutes) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
    ) AS next_duration
FROM game_sessions gs
INNER JOIN players p ON gs.player_id = p.player_id
ORDER BY p.username, gs.session_start;

-- 1.5 Running total: Cumulative revenue per player
SELECT
    p.username,
    t.created_at,
    t.amount,
    SUM(t.amount) OVER (
        PARTITION BY p.player_id
        ORDER BY t.created_at
    ) AS cumulative_spent
FROM transactions t
INNER JOIN players p ON t.player_id = p.player_id
WHERE t.status = 'completed'
ORDER BY p.username, t.created_at;

-- 1.6 Moving average (PostgreSQL)
WITH daily_sessions AS (
    SELECT
        DATE(session_start) AS play_date,
        COUNT(*) AS session_count
    FROM game_sessions
    GROUP BY DATE(session_start)
)
SELECT
    play_date,
    session_count,
    ROUND(AVG(session_count) OVER (
        ORDER BY play_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS three_day_avg
FROM daily_sessions
ORDER BY play_date;

-- 1.7 NTILE: Segment players into quartiles
SELECT
    p.username,
    SUM(t.amount) AS total_spent,
    NTILE(4) OVER (ORDER BY SUM(t.amount)) AS spending_quartile,
    CASE NTILE(4) OVER (ORDER BY SUM(t.amount))
        WHEN 1 THEN 'Low Spender'
        WHEN 2 THEN 'Medium-Low'
        WHEN 3 THEN 'Medium-High'
        WHEN 4 THEN 'High Spender'
    END AS spending_category
FROM players p
INNER JOIN transactions t ON p.player_id = t.player_id
WHERE t.status = 'completed'
GROUP BY p.player_id, p.username
ORDER BY total_spent;

-- 1.8 FIRST_VALUE and LAST_VALUE
SELECT DISTINCT
    p.username,
    FIRST_VALUE(g.game_name) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_game_played,
    LAST_VALUE(g.game_name) OVER (
        PARTITION BY gs.player_id
        ORDER BY gs.session_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_game_played
FROM game_sessions gs
INNER JOIN players p ON gs.player_id = p.player_id
INNER JOIN games g ON gs.game_id = g.game_id;

-- 1.9 Percentage of total
SELECT
    p.username,
    p.subscription_tier,
    p.total_playtime_minutes,
    SUM(p.total_playtime_minutes) OVER () AS total_all_players,
    ROUND(100.0 * p.total_playtime_minutes / SUM(p.total_playtime_minutes) OVER (), 2) AS pct_of_total
FROM players p
ORDER BY p.total_playtime_minutes DESC;

-- ===========================================
-- PART 2: COMMON TABLE EXPRESSIONS (CTEs)
-- ===========================================

-- 2.1 Basic CTE
WITH high_value_players AS (
    SELECT
        player_id,
        username,
        total_playtime_minutes
    FROM players
    WHERE total_playtime_minutes > 5000
)
SELECT * FROM high_value_players ORDER BY total_playtime_minutes DESC;

-- 2.2 Multiple CTEs
WITH player_sessions AS (
    SELECT
        player_id,
        COUNT(*) AS session_count,
        SUM(duration_minutes) AS total_playtime
    FROM game_sessions
    GROUP BY player_id
),
player_spending AS (
    SELECT
        player_id,
        SUM(amount) AS total_spent
    FROM transactions
    WHERE status = 'completed'
    GROUP BY player_id
),
player_achievements AS (
    SELECT
        player_id,
        COUNT(*) AS achievement_count
    FROM player_achievements
    GROUP BY player_id
)
SELECT
    p.username,
    p.subscription_tier,
    COALESCE(ps.session_count, 0) AS sessions,
    COALESCE(ps.total_playtime, 0) AS playtime,
    COALESCE(sp.total_spent, 0) AS spent,
    COALESCE(pa.achievement_count, 0) AS achievements
FROM players p
LEFT JOIN player_sessions ps ON p.player_id = ps.player_id
LEFT JOIN player_spending sp ON p.player_id = sp.player_id
LEFT JOIN player_achievements pa ON p.player_id = pa.player_id
ORDER BY playtime DESC;

-- 2.3 CTE with window functions
WITH ranked_scores AS (
    SELECT
        p.username,
        g.game_name,
        s.score_value,
        ROW_NUMBER() OVER (
            PARTITION BY g.game_id
            ORDER BY s.score_value DESC
        ) AS rank
    FROM scores s
    INNER JOIN players p ON s.player_id = p.player_id
    INNER JOIN games g ON s.game_id = g.game_id
)
SELECT username, game_name, score_value
FROM ranked_scores
WHERE rank = 1
ORDER BY game_name;

-- 2.4 Recursive CTE: Generate date series (PostgreSQL)
  WITH RECURSIVE date_series AS (
      -- Base case
      SELECT DATE '2024-01-01' AS dt

      UNION ALL

      -- Recursive case
      SELECT (dt + INTERVAL '1 day')::date
      FROM date_series
      WHERE dt < DATE '2024-01-10'
  )
  SELECT dt FROM date_series;

-- 2.5 CTE for cohort analysis
WITH first_session AS (
    SELECT
        player_id,
        DATE(MIN(session_start)) AS cohort_date
    FROM game_sessions
    GROUP BY player_id
),
cohort_size AS (
    SELECT
        cohort_date,
        COUNT(*) AS players_in_cohort
    FROM first_session
    GROUP BY cohort_date
)
SELECT
    fs.cohort_date,
    cs.players_in_cohort,
    COUNT(DISTINCT gs.player_id) AS returned_players
FROM first_session fs
INNER JOIN cohort_size cs ON fs.cohort_date = cs.cohort_date
LEFT JOIN game_sessions gs ON fs.player_id = gs.player_id
    AND DATE(gs.session_start) > fs.cohort_date
GROUP BY fs.cohort_date, cs.players_in_cohort
ORDER BY fs.cohort_date;

-- ===========================================
-- PART 3: NORMALIZATION EXAMPLES
-- ===========================================

-- 3.1 Example of denormalized data (for demonstration)
-- This shows what BADLY designed data looks like:
/*
CREATE TABLE bad_player_data (
    id SERIAL,
    username VARCHAR(50),
    games_played TEXT,           -- "RPG, Action" - violates 1NF!
    game_developer VARCHAR(100), -- Depends on game, not player - violates 2NF!
    country_name VARCHAR(50)     -- Transitive dependency - violates 3NF!
);
*/

-- 3.2 Our GameVerse database IS properly normalized:

-- 1NF: Atomic values, no repeating groups
-- Instead of storing "RPG, Action, Puzzle" in one field,
-- we have separate rows in game_sessions for each game played

-- 2NF: No partial dependencies
-- Game information (name, developer) is in the games table,
-- not mixed into scores or sessions

-- 3NF: No transitive dependencies
-- Country information would be in a separate countries table
-- (referenced by country_code)

-- 3.3 Query showing normalized data access
SELECT
    p.username,
    p.country_code,
    g.game_name,
    g.developer,
    s.score_value
FROM players p
INNER JOIN scores s ON p.player_id = s.player_id
INNER JOIN games g ON s.game_id = g.game_id
LIMIT 10;

-- ===========================================
-- PART 4: QUERY OPTIMIZATION
-- ===========================================

-- 4.1 EXPLAIN: See query execution plan (PostgreSQL)
EXPLAIN
SELECT * FROM players WHERE country_code = 'US';

-- 4.2 EXPLAIN ANALYZE: See plan with actual timing
EXPLAIN ANALYZE
SELECT p.username, COUNT(s.score_id)
FROM players p
LEFT JOIN scores s ON p.player_id = s.player_id
GROUP BY p.player_id, p.username;

-- 4.3 Creating useful indexes
-- These would typically be run once during setup

-- Index for common WHERE clause
-- CREATE INDEX idx_players_country ON players(country_code);

-- Composite index for common join pattern
-- CREATE INDEX idx_sessions_player_game ON game_sessions(player_id, game_id);

-- Index for date range queries
-- CREATE INDEX idx_transactions_date ON transactions(created_at);

-- 4.4 Bad vs Good query patterns

-- BAD: Function on indexed column (can't use index)
EXPLAIN ANALYZE
SELECT * FROM game_sessions
WHERE DATE(session_start) = '2024-01-15';

-- GOOD: Range query (can use index)
EXPLAIN ANALYZE
SELECT * FROM game_sessions
WHERE session_start >= '2024-01-15'
  AND session_start < '2024-01-16';

-- BAD: SELECT * (fetches unnecessary data)
SELECT * FROM players WHERE country_code = 'US';

-- GOOD: Select only needed columns
SELECT player_id, username, email
FROM players
WHERE country_code = 'US';

-- 4.5 EXISTS vs IN (EXISTS is often faster)

-- Using IN (creates list in memory)
SELECT * FROM players
WHERE player_id IN (SELECT player_id FROM scores);

-- Using EXISTS (stops at first match)
SELECT * FROM players p
WHERE EXISTS (SELECT 1 FROM scores s WHERE s.player_id = p.player_id);

-- ===========================================
-- PART 5: DATA ENGINEERING PATTERNS
-- ===========================================

-- 5.1 UPSERT: Insert or update (PostgreSQL)
INSERT INTO daily_player_stats (player_id, stat_date, total_sessions, total_playtime_minutes, total_score)
VALUES (1, CURRENT_DATE, 1, 60, 5000)
ON CONFLICT (player_id, stat_date)
DO UPDATE SET
    total_sessions = daily_player_stats.total_sessions + EXCLUDED.total_sessions,
    total_playtime_minutes = daily_player_stats.total_playtime_minutes + EXCLUDED.total_playtime_minutes,
    total_score = daily_player_stats.total_score + EXCLUDED.total_score;

-- 5.2 UPSERT (MySQL version - MySQL 8.0.20+ syntax using alias)
-- INSERT INTO daily_player_stats (player_id, stat_date, total_sessions, total_playtime_minutes)
-- VALUES (1, CURDATE(), 1, 60) AS new_values
-- ON DUPLICATE KEY UPDATE
--     total_sessions = total_sessions + new_values.total_sessions,
--     total_playtime_minutes = total_playtime_minutes + new_values.total_playtime_minutes;
--
-- Note: VALUES() function is deprecated in MySQL 8.0.20+. Use row alias syntax instead.

-- 5.3 Find duplicates using window functions
WITH potential_duplicates AS (
    SELECT
        score_id,
        player_id,
        game_id,
        score_value,
        achieved_at,
        ROW_NUMBER() OVER (
            PARTITION BY player_id, game_id, score_value, achieved_at
            ORDER BY score_id
        ) AS rn
    FROM scores
)
SELECT *
FROM potential_duplicates
WHERE rn > 1;

-- 5.4 Deduplication query (keep first, delete rest)
-- First preview what would be deleted:
WITH duplicates AS (
    SELECT
        score_id,
        ROW_NUMBER() OVER (
            PARTITION BY player_id, game_id, score_value, achieved_at
            ORDER BY score_id
        ) AS rn
    FROM scores
)
SELECT score_id FROM duplicates WHERE rn > 1;

-- Then delete (uncomment to execute):
-- DELETE FROM scores
-- WHERE score_id IN (
--     SELECT score_id FROM (
--         SELECT
--             score_id,
--             ROW_NUMBER() OVER (
--                 PARTITION BY player_id, game_id, score_value, achieved_at
--                 ORDER BY score_id
--             ) AS rn
--         FROM scores
--     ) ranked WHERE rn > 1
-- );

-- 5.5 Working with JSON data (PostgreSQL)
-- Query JSON fields
SELECT
    log_id,
    event_type,
    event_data->>'device' AS device,
    event_data->>'region' AS region,
    created_at
FROM event_logs
WHERE event_type = 'login';

-- Extract nested JSON
SELECT
    log_id,
    event_type,
    event_data->>'item_id' AS item_id,
    event_data->>'rarity' AS rarity,
    event_data->>'method' AS acquisition_method
FROM event_logs
WHERE event_type = 'item_acquired';

-- Aggregate player achievements as JSON array
SELECT
    p.username,
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'name', a.achievement_name,
            'rarity', a.rarity,
            'points', a.points,
            'unlocked', pa.unlocked_at
        ) ORDER BY pa.unlocked_at
    ) AS achievements_json
FROM players p
INNER JOIN player_achievements pa ON p.player_id = pa.player_id
INNER JOIN achievements a ON pa.achievement_id = a.achievement_id
GROUP BY p.player_id, p.username
LIMIT 5;

-- 5.6 Incremental processing pattern
-- Mark rows as processed
UPDATE event_logs
SET
    is_processed = TRUE,
    processed_at = CURRENT_TIMESTAMP
WHERE log_id IN (
    SELECT log_id
    FROM event_logs
    WHERE is_processed = FALSE
    ORDER BY created_at
    LIMIT 100
);

-- Query only unprocessed events
SELECT *
FROM event_logs
WHERE is_processed = FALSE
ORDER BY created_at
LIMIT 100;

-- ===========================================
-- ADVANCED ANALYTICS EXAMPLES
-- ===========================================

-- Player lifetime value analysis
WITH player_metrics AS (
    SELECT
        p.player_id,
        p.username,
        p.subscription_tier,
        p.registration_date,
        COALESCE(SUM(t.amount), 0) AS lifetime_value,
        COUNT(DISTINCT gs.session_id) AS total_sessions,
        COUNT(DISTINCT DATE(gs.session_start)) AS active_days
    FROM players p
    LEFT JOIN transactions t ON p.player_id = t.player_id AND t.status = 'completed'
    LEFT JOIN game_sessions gs ON p.player_id = gs.player_id
    GROUP BY p.player_id, p.username, p.subscription_tier, p.registration_date
)
SELECT
    username,
    subscription_tier,
    lifetime_value,
    total_sessions,
    active_days,
    CASE
        WHEN lifetime_value >= 500 THEN 'Whale'
        WHEN lifetime_value >= 100 THEN 'Dolphin'
        WHEN lifetime_value > 0 THEN 'Minnow'
        ELSE 'Free Player'
    END AS player_segment,
    NTILE(10) OVER (ORDER BY lifetime_value) AS ltv_decile
FROM player_metrics
ORDER BY lifetime_value DESC;

-- Game health metrics
WITH game_metrics AS (
    SELECT
        g.game_id,
        g.game_name,
        g.genre,
        COUNT(DISTINCT gs.player_id) AS unique_players,
        COUNT(gs.session_id) AS total_sessions,
        AVG(gs.duration_minutes) AS avg_session_length,
        SUM(t.amount) AS total_revenue
    FROM games g
    LEFT JOIN game_sessions gs ON g.game_id = gs.game_id
    LEFT JOIN transactions t ON g.game_id = t.game_id AND t.status = 'completed'
    GROUP BY g.game_id, g.game_name, g.genre
)
SELECT
    game_name,
    genre,
    unique_players,
    total_sessions,
    ROUND(avg_session_length, 1) AS avg_session_mins,
    COALESCE(total_revenue, 0) AS revenue,
    CASE
        WHEN unique_players >= 5 AND total_sessions >= 10 THEN 'Healthy'
        WHEN unique_players >= 2 THEN 'Growing'
        ELSE 'Needs Attention'
    END AS health_status
FROM game_metrics
ORDER BY unique_players DESC;
