-- ===========================================
-- Lesson 2: Intermediate SQL - Example Queries
-- GameVerse Database
-- ===========================================

-- ===========================================
-- PART 1: JOINs
-- ===========================================

-- 1.1 INNER JOIN: Players with their scores
SELECT
    p.username,
    g.game_name,
    s.score_value,
    s.difficulty,
    s.achieved_at
FROM players p
INNER JOIN scores s ON p.player_id = s.player_id
INNER JOIN games g ON s.game_id = g.game_id
ORDER BY s.score_value DESC
LIMIT 10;

-- 1.2 INNER JOIN: Recent game sessions with player and game info
SELECT
    p.username,
    g.game_name,
    gs.session_start,
    gs.duration_minutes,
    gs.device_type
FROM game_sessions gs
INNER JOIN players p ON gs.player_id = p.player_id
INNER JOIN games g ON gs.game_id = g.game_id
WHERE gs.session_start >= '2024-01-15'
ORDER BY gs.session_start DESC;

-- 1.3 LEFT JOIN: All players and their guild membership
-- (includes players without guilds)
SELECT
    p.username,
    p.subscription_tier,
    g.guild_name,
    gm.role AS guild_role
FROM players p
LEFT JOIN guild_members gm ON p.player_id = gm.player_id
LEFT JOIN guilds g ON gm.guild_id = g.guild_id
ORDER BY p.username;

-- 1.4 LEFT JOIN: Find players without any scores
SELECT
    p.username,
    p.registration_date,
    p.total_playtime_minutes
FROM players p
LEFT JOIN scores s ON p.player_id = s.player_id
WHERE s.score_id IS NULL
ORDER BY p.registration_date;

-- 1.5 LEFT JOIN: All games with their achievement count
SELECT
    g.game_name,
    g.genre,
    COUNT(a.achievement_id) AS achievement_count
FROM games g
LEFT JOIN achievements a ON g.game_id = a.game_id
GROUP BY g.game_id, g.game_name, g.genre
ORDER BY achievement_count DESC;

-- 1.6 RIGHT JOIN: All achievements and which players unlocked them
SELECT
    a.achievement_name,
    a.rarity,
    a.points,
    p.username AS unlocked_by,
    pa.unlocked_at
FROM player_achievements pa
RIGHT JOIN achievements a ON pa.achievement_id = a.achievement_id
LEFT JOIN players p ON pa.player_id = p.player_id
ORDER BY a.game_id, a.achievement_name;

-- 1.7 Self JOIN: Find mutual friendships
SELECT
    p1.username AS player,
    p2.username AS friend,
    f.status,
    f.accepted_at
FROM friendships f
INNER JOIN players p1 ON f.player_id = p1.player_id
INNER JOIN players p2 ON f.friend_id = p2.player_id
WHERE f.status = 'accepted'
ORDER BY p1.username;

-- 1.8 Multiple JOINs: Complete player inventory with item and game details
SELECT
    p.username,
    i.item_name,
    i.item_type,
    i.rarity,
    g.game_name,
    inv.quantity,
    inv.acquired_method,
    inv.acquired_at
FROM inventory inv
INNER JOIN players p ON inv.player_id = p.player_id
INNER JOIN items i ON inv.item_id = i.item_id
INNER JOIN games g ON i.game_id = g.game_id
WHERE i.rarity IN ('epic', 'legendary')
ORDER BY p.username, inv.acquired_at DESC;

-- 1.9 Complex JOIN: Player with their guild, scores, and achievements count
SELECT
    p.username,
    p.subscription_tier,
    g.guild_name,
    COUNT(DISTINCT s.score_id) AS total_scores,
    COUNT(DISTINCT pa.achievement_id) AS achievements_earned
FROM players p
LEFT JOIN guild_members gm ON p.player_id = gm.player_id
LEFT JOIN guilds g ON gm.guild_id = g.guild_id
LEFT JOIN scores s ON p.player_id = s.player_id
LEFT JOIN player_achievements pa ON p.player_id = pa.player_id
GROUP BY p.player_id, p.username, p.subscription_tier, g.guild_name
ORDER BY total_scores DESC;

-- ===========================================
-- PART 2: AGGREGATE FUNCTIONS
-- ===========================================

-- 2.1 Basic COUNT variations
SELECT
    COUNT(*) AS total_players,
    COUNT(last_login) AS players_logged_in,
    COUNT(DISTINCT country_code) AS unique_countries,
    COUNT(DISTINCT subscription_tier) AS subscription_types
FROM players;

-- 2.2 SUM and AVG
SELECT
    SUM(amount) AS total_revenue,
    AVG(amount) AS average_transaction,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS completed_revenue,
    AVG(CASE WHEN status = 'completed' THEN amount END) AS avg_completed
FROM transactions;

-- 2.3 MIN and MAX
SELECT
    MIN(registration_date) AS first_registration,
    MAX(registration_date) AS latest_registration,
    MIN(total_playtime_minutes) AS min_playtime,
    MAX(total_playtime_minutes) AS max_playtime
FROM players;

-- 2.4 Comprehensive statistics
SELECT
    COUNT(*) AS total_games,
    ROUND(AVG(rating), 2) AS average_rating,
    MIN(rating) AS lowest_rating,
    MAX(rating) AS highest_rating,
    MIN(base_price) AS cheapest_game,
    MAX(base_price) AS most_expensive,
    SUM(CASE WHEN is_multiplayer THEN 1 ELSE 0 END) AS multiplayer_count,
    SUM(CASE WHEN base_price = 0 THEN 1 ELSE 0 END) AS free_games
FROM games;

-- 2.5 Score statistics by difficulty
SELECT
    difficulty,
    COUNT(*) AS attempts,
    ROUND(AVG(score_value), 0) AS avg_score,
    MAX(score_value) AS high_score,
    MIN(score_value) AS low_score
FROM scores
WHERE difficulty IS NOT NULL
GROUP BY difficulty
ORDER BY avg_score DESC;

-- ===========================================
-- PART 3: GROUP BY AND HAVING
-- ===========================================

-- 3.1 Players per country
SELECT
    country_code,
    COUNT(*) AS player_count,
    ROUND(AVG(total_playtime_minutes), 0) AS avg_playtime,
    SUM(total_playtime_minutes) AS total_playtime
FROM players
WHERE country_code IS NOT NULL
GROUP BY country_code
ORDER BY player_count DESC;

-- 3.2 Players per subscription tier
SELECT
    subscription_tier,
    COUNT(*) AS player_count,
    ROUND(AVG(total_playtime_minutes), 0) AS avg_playtime
FROM players
GROUP BY subscription_tier
ORDER BY player_count DESC;

-- 3.3 Revenue per game
SELECT
    g.game_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_revenue,
    ROUND(AVG(t.amount), 2) AS avg_transaction
FROM transactions t
INNER JOIN games g ON t.game_id = g.game_id
WHERE t.status = 'completed'
GROUP BY g.game_id, g.game_name
ORDER BY total_revenue DESC;

-- 3.4 HAVING: Countries with more than 2 players
SELECT
    country_code,
    COUNT(*) AS player_count
FROM players
WHERE country_code IS NOT NULL
GROUP BY country_code
HAVING COUNT(*) > 2
ORDER BY player_count DESC;

-- 3.5 HAVING: Games with high player engagement
SELECT
    g.game_name,
    COUNT(DISTINCT gs.player_id) AS unique_players,
    COUNT(gs.session_id) AS total_sessions,
    SUM(gs.duration_minutes) AS total_playtime
FROM game_sessions gs
INNER JOIN games g ON gs.game_id = g.game_id
WHERE gs.session_status = 'completed'
GROUP BY g.game_id, g.game_name
HAVING COUNT(DISTINCT gs.player_id) >= 2
ORDER BY unique_players DESC;

-- 3.6 Combining WHERE and HAVING
SELECT
    g.genre,
    COUNT(*) AS game_count,
    ROUND(AVG(g.rating), 2) AS avg_rating
FROM games g
WHERE g.release_date >= '2023-01-01'  -- Filter rows
GROUP BY g.genre
HAVING AVG(g.rating) >= 4.3           -- Filter groups
ORDER BY avg_rating DESC;

-- 3.7 GROUP BY with multiple columns
SELECT
    g.game_name,
    gs.device_type,
    COUNT(*) AS session_count,
    ROUND(AVG(gs.duration_minutes), 0) AS avg_duration
FROM game_sessions gs
INNER JOIN games g ON gs.game_id = g.game_id
GROUP BY g.game_name, gs.device_type
ORDER BY g.game_name, session_count DESC;

-- 3.8 Monthly transaction summary (PostgreSQL)
SELECT
    DATE_TRUNC('month', created_at) AS month,
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM transactions
WHERE created_at >= '2023-01-01'
GROUP BY DATE_TRUNC('month', created_at), transaction_type
HAVING SUM(amount) > 50
ORDER BY month, total_amount DESC;

-- 3.8 MySQL version:
-- SELECT
--     DATE_FORMAT(created_at, '%Y-%m-01') AS month,
--     transaction_type,
--     COUNT(*) AS transaction_count,
--     SUM(amount) AS total_amount
-- FROM transactions
-- WHERE created_at >= '2023-01-01'
-- GROUP BY DATE_FORMAT(created_at, '%Y-%m-01'), transaction_type
-- HAVING SUM(amount) > 50
-- ORDER BY month, total_amount DESC;

-- ===========================================
-- PART 4: SUBQUERIES
-- ===========================================

-- 4.1 Scalar subquery: Players with above-average playtime
SELECT username, total_playtime_minutes
FROM players
WHERE total_playtime_minutes > (
    SELECT AVG(total_playtime_minutes) FROM players
)
ORDER BY total_playtime_minutes DESC;

-- 4.2 Subquery with IN: Players who have legendary items
SELECT username, email, subscription_tier
FROM players
WHERE player_id IN (
    SELECT DISTINCT inv.player_id
    FROM inventory inv
    INNER JOIN items i ON inv.item_id = i.item_id
    WHERE i.rarity = 'legendary'
)
ORDER BY username;

-- 4.3 Subquery with NOT IN: Games with no sessions
SELECT game_name, release_date, genre
FROM games
WHERE game_id NOT IN (
    SELECT DISTINCT game_id FROM game_sessions
);

-- 4.4 Correlated subquery: Players above their country's average playtime
SELECT p.username, p.country_code, p.total_playtime_minutes
FROM players p
WHERE p.country_code IS NOT NULL
AND p.total_playtime_minutes > (
    SELECT AVG(p2.total_playtime_minutes)
    FROM players p2
    WHERE p2.country_code = p.country_code
)
ORDER BY p.country_code, p.total_playtime_minutes DESC;

-- 4.5 EXISTS: Players with legendary achievements
SELECT p.username, p.email
FROM players p
WHERE EXISTS (
    SELECT 1
    FROM player_achievements pa
    INNER JOIN achievements a ON pa.achievement_id = a.achievement_id
    WHERE pa.player_id = p.player_id
    AND a.rarity = 'legendary'
);

-- 4.6 NOT EXISTS: Players without any purchases
SELECT p.username, p.registration_date, p.subscription_tier
FROM players p
WHERE NOT EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.player_id = p.player_id
    AND t.transaction_type = 'purchase'
)
ORDER BY p.registration_date;

-- 4.7 Subquery in SELECT: Player with their rank
SELECT
    p.username,
    p.total_playtime_minutes,
    (SELECT COUNT(*) + 1
     FROM players p2
     WHERE p2.total_playtime_minutes > p.total_playtime_minutes) AS playtime_rank
FROM players p
ORDER BY total_playtime_minutes DESC
LIMIT 10;

-- 4.8 Subquery in FROM (Derived Table): Average score by player
SELECT
    player_scores.username,
    player_scores.avg_score,
    player_scores.total_games_played
FROM (
    SELECT
        p.username,
        ROUND(AVG(s.score_value), 0) AS avg_score,
        COUNT(DISTINCT s.game_id) AS total_games_played
    FROM players p
    INNER JOIN scores s ON p.player_id = s.player_id
    GROUP BY p.player_id, p.username
) AS player_scores
WHERE player_scores.total_games_played >= 1
ORDER BY player_scores.avg_score DESC;

-- ===========================================
-- ADVANCED EXAMPLES
-- ===========================================

-- Player spending analysis with multiple aggregates
SELECT
    p.username,
    p.subscription_tier,
    COUNT(t.transaction_id) AS purchase_count,
    COALESCE(SUM(t.amount), 0) AS total_spent,
    COALESCE(ROUND(AVG(t.amount), 2), 0) AS avg_purchase
FROM players p
LEFT JOIN transactions t ON p.player_id = t.player_id AND t.transaction_type = 'purchase'
GROUP BY p.player_id, p.username, p.subscription_tier
ORDER BY total_spent DESC;

-- Guild statistics with member details
SELECT
    g.guild_name,
    g.member_count,
    COUNT(gm.player_id) AS actual_members,
    STRING_AGG(p.username, ', ' ORDER BY p.username) AS member_names
FROM guilds g
LEFT JOIN guild_members gm ON g.guild_id = gm.guild_id
LEFT JOIN players p ON gm.player_id = p.player_id
GROUP BY g.guild_id, g.guild_name, g.member_count
ORDER BY actual_members DESC;

-- Note: In MySQL, use GROUP_CONCAT instead of STRING_AGG:
-- GROUP_CONCAT(p.username ORDER BY p.username SEPARATOR ', ') AS member_names

-- Achievement completion rates
SELECT
    a.achievement_name,
    a.rarity,
    a.points,
    COUNT(pa.player_id) AS times_unlocked,
    ROUND(100.0 * COUNT(pa.player_id) / (SELECT COUNT(*) FROM players), 2) AS completion_rate
FROM achievements a
LEFT JOIN player_achievements pa ON a.achievement_id = pa.achievement_id
GROUP BY a.achievement_id, a.achievement_name, a.rarity, a.points
ORDER BY completion_rate DESC;
