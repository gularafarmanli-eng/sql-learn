-- ===========================================
-- Lesson 2: Intermediate SQL - Practice Exercises
-- GameVerse Database
-- ===========================================

-- ===========================================
-- EXERCISE 1: JOINs
-- ===========================================

-- 1.1 List all players with their total number of achievements unlocked
-- Expected columns: username, achievements_unlocked
-- Include players with 0 achievements

-- YOUR QUERY HERE:


-- 1.2 Find all games that have never been played (no sessions)
-- Expected columns: game_name, release_date, genre

-- YOUR QUERY HERE:


-- 1.3 Show each player with their friends' usernames
-- Only show accepted friendships
-- Expected columns: player, friend

-- YOUR QUERY HERE:


-- 1.4 List all items with the game they belong to and how many players own them
-- Expected columns: game_name, item_name, rarity, owner_count

-- YOUR QUERY HERE:


-- 1.5 Find players who are in multiple guilds
-- Expected columns: username, guild_count

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 2: Aggregate Functions
-- ===========================================

-- 2.1 Calculate total revenue per subscription tier
-- Expected columns: subscription_tier, player_count, transaction_count, total_revenue

-- YOUR QUERY HERE:


-- 2.2 Find the top 5 games by average session duration
-- Expected columns: game_name, avg_duration, session_count

-- YOUR QUERY HERE:


-- 2.3 Calculate achievement statistics by rarity
-- Expected columns: rarity, achievement_count, avg_points, total_unlocks

-- YOUR QUERY HERE:


-- 2.4 Find total inventory value per player (sum of item base_value * quantity)
-- Expected columns: username, total_items, total_value
-- Order by total_value descending

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 3: GROUP BY and HAVING
-- ===========================================

-- 3.1 Find games with more than 3 unique players
-- Expected columns: game_name, unique_players, total_sessions

-- YOUR QUERY HERE:


-- 3.2 Find countries with average playtime above 5000 minutes
-- Expected columns: country_code, player_count, avg_playtime

-- YOUR QUERY HERE:


-- 3.3 List guilds where the average member playtime exceeds 4000 minutes
-- Expected columns: guild_name, member_count, avg_member_playtime

-- YOUR QUERY HERE:


-- 3.4 Find item types with total base_value exceeding 500
-- Expected columns: item_type, item_count, total_value, avg_value

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 4: Subqueries
-- ===========================================

-- 4.1 Find players who have spent more than the overall average spending
-- Expected columns: username, total_spent

-- YOUR QUERY HERE:


-- 4.2 List games with above-average ratings
-- Expected columns: game_name, genre, rating

-- YOUR QUERY HERE:


-- 4.3 Find players who own items from more than 2 different games
-- Use a subquery approach
-- Expected columns: username, games_with_items

-- YOUR QUERY HERE:


-- 4.4 Find achievements that NO player has unlocked yet
-- Expected columns: achievement_name, game_name, rarity

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 5: Complex Challenges
-- ===========================================

-- 5.1 Player Engagement Report
-- For each player, show their total sessions, total playtime,
-- unique games played, and achievements earned
-- Only include players with at least 1 session
-- Expected columns: username, subscription_tier, session_count,
--                   total_playtime, games_played, achievements_earned

-- YOUR QUERY HERE:


-- 5.2 Revenue Analysis by Game and Payment Method
-- Show total revenue breakdown by game and payment method
-- Only include completed transactions
-- Expected columns: game_name, payment_method, transaction_count, total_revenue

-- YOUR QUERY HERE:


-- 5.3 Find the "Most Valuable Players" - players who:
-- - Have subscription tier 'vip' or 'premium'
-- - Have spent more than the average for their tier
-- - Have more than 2000 minutes of playtime
-- Expected columns: username, subscription_tier, total_spent, total_playtime

-- YOUR QUERY HERE:
