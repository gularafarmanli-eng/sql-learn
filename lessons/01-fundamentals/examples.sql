-- ===========================================
-- Lesson 1: SQL Fundamentals - Example Queries
-- GameVerse Database
-- ===========================================
-- These examples work on both PostgreSQL and MySQL
-- unless otherwise noted.

-- ===========================================
-- PART 1: EXPLORING THE DATABASE
-- ===========================================

-- PostgreSQL: List all tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- MySQL: List all tables
-- SHOW TABLES;

-- View table structure (PostgreSQL)
-- \d players

-- View table structure (MySQL)
-- DESCRIBE players;

-- ===========================================
-- PART 2: SELECT FUNDAMENTALS
-- ===========================================

-- 2.1 Select all columns from a table
SELECT * FROM players;

-- 2.2 Select specific columns (better practice)
SELECT username, email, country_code, subscription_tier
FROM players;

-- 2.3 Using column aliases with AS
SELECT
    username AS player_name,
    total_playtime_minutes AS playtime,
    total_playtime_minutes / 60.0 AS playtime_hours
FROM players;

-- 2.4 DISTINCT - Find unique values
SELECT DISTINCT subscription_tier
FROM players;

-- 2.5 DISTINCT with multiple columns
SELECT DISTINCT country_code, subscription_tier
FROM players
ORDER BY country_code, subscription_tier;

-- 2.6 Expressions and calculations
SELECT
    game_name,
    base_price,
    base_price * 0.9 AS discounted_price,
    base_price * 0.1 AS discount_amount
FROM games
WHERE base_price > 0;

-- 2.7 String concatenation (PostgreSQL)
SELECT
    username || ' from ' || country_code AS player_info
FROM players
WHERE country_code IS NOT NULL;

-- 2.7 String concatenation (MySQL)
-- SELECT
--     CONCAT(username, ' from ', country_code) AS player_info
-- FROM players
-- WHERE country_code IS NOT NULL;

-- ===========================================
-- PART 3: WHERE CLAUSE - FILTERING DATA
-- ===========================================

-- 3.1 Basic equality
SELECT username, email, subscription_tier
FROM players
WHERE subscription_tier = 'premium';

-- 3.2 Not equal
SELECT username, account_status
FROM players
WHERE account_status <> 'active';

-- 3.3 Greater than / Less than
SELECT game_name, rating
FROM games
WHERE rating >= 4.5;

SELECT username, total_playtime_minutes
FROM players
WHERE total_playtime_minutes < 1000;

-- 3.4 AND operator - both conditions must be true
SELECT game_name, genre, rating, is_multiplayer
FROM games
WHERE is_multiplayer = TRUE
  AND rating > 4.0;

-- 3.5 OR operator - at least one condition true
SELECT username, country_code
FROM players
WHERE country_code = 'US'
   OR country_code = 'CA';

-- 3.6 NOT operator - negation
SELECT username, subscription_tier
FROM players
WHERE NOT subscription_tier = 'free';

-- 3.7 IN operator - cleaner than multiple ORs
SELECT username, country_code
FROM players
WHERE country_code IN ('US', 'CA', 'GB', 'DE');

-- 3.8 NOT IN operator
SELECT username, country_code
FROM players
WHERE country_code NOT IN ('US', 'CA');

-- 3.9 BETWEEN operator - inclusive range
SELECT username, total_playtime_minutes
FROM players
WHERE total_playtime_minutes BETWEEN 1000 AND 5000;

-- 3.10 BETWEEN with dates
SELECT game_name, release_date
FROM games
WHERE release_date BETWEEN '2023-01-01' AND '2023-06-30';

-- 3.11 LIKE operator - pattern matching with %
SELECT username, email
FROM players
WHERE username LIKE 'Dragon%';  -- starts with 'Dragon'

SELECT username, email
FROM players
WHERE email LIKE '%@email.com';  -- ends with '@email.com'

SELECT username, email
FROM players
WHERE username LIKE '%Gamer%';  -- contains 'Gamer'

-- 3.12 LIKE operator - pattern matching with _
SELECT game_name
FROM games
WHERE game_name LIKE '_a%';  -- second character is 'a'

-- 3.13 IS NULL - finding missing values
SELECT username, last_login
FROM players
WHERE last_login IS NULL;

-- 3.14 IS NOT NULL - finding existing values
SELECT username, last_login
FROM players
WHERE last_login IS NOT NULL;

-- 3.15 Complex conditions with parentheses
SELECT
    username,
    country_code,
    subscription_tier,
    total_playtime_minutes
FROM players
WHERE subscription_tier IN ('premium', 'vip')
  AND (country_code = 'US' OR country_code = 'GB')
  AND total_playtime_minutes > 3000;

-- 3.16 Another complex example
SELECT
    game_name,
    genre,
    rating,
    base_price
FROM games
WHERE (genre = 'RPG' OR genre = 'Action')
  AND rating >= 4.5
  AND (base_price = 0 OR base_price > 50);

-- ===========================================
-- PART 4: ORDER BY AND LIMIT
-- ===========================================

-- 4.1 ORDER BY ascending (default)
SELECT username, total_playtime_minutes
FROM players
ORDER BY total_playtime_minutes;

-- 4.2 ORDER BY descending
SELECT username, total_playtime_minutes
FROM players
ORDER BY total_playtime_minutes DESC;

-- 4.3 ORDER BY multiple columns
SELECT game_name, genre, rating
FROM games
ORDER BY genre ASC, rating DESC;

-- 4.4 ORDER BY with column position (not recommended)
SELECT username, country_code, total_playtime_minutes
FROM players
ORDER BY 2, 3 DESC;  -- Order by 2nd column, then 3rd descending

-- 4.5 LIMIT - Top N results
SELECT username, total_playtime_minutes
FROM players
ORDER BY total_playtime_minutes DESC
LIMIT 10;

-- 4.6 LIMIT with OFFSET - Pagination
-- Page 1: First 5 results
SELECT username, registration_date
FROM players
ORDER BY registration_date DESC
LIMIT 5 OFFSET 0;

-- Page 2: Results 6-10
SELECT username, registration_date
FROM players
ORDER BY registration_date DESC
LIMIT 5 OFFSET 5;

-- Page 3: Results 11-15
SELECT username, registration_date
FROM players
ORDER BY registration_date DESC
LIMIT 5 OFFSET 10;

-- 4.7 Combining WHERE, ORDER BY, and LIMIT
SELECT
    username,
    country_code,
    total_playtime_minutes
FROM players
WHERE subscription_tier = 'vip'
ORDER BY total_playtime_minutes DESC
LIMIT 5;

-- ===========================================
-- PART 5: DATA MANIPULATION
-- ===========================================

-- NOTE: These queries modify data. Use with caution!
-- Wrap in a transaction if you want to test safely.

-- 5.1 INSERT - Single row
INSERT INTO players (username, email, password_hash, display_name, country_code)
VALUES ('TestPlayer001', 'test001@email.com', 'hash_test001', 'Test Player 1', 'US');

-- 5.2 INSERT - Multiple rows
INSERT INTO items (game_id, item_name, item_type, rarity, base_value, is_tradeable)
VALUES
    (1, 'Silver Sword', 'weapon', 'uncommon', 75.00, TRUE),
    (1, 'Bronze Shield', 'armor', 'common', 25.00, TRUE);

-- 5.3 UPDATE - Modify existing data (always use WHERE!)
UPDATE players
SET subscription_tier = 'premium'
WHERE username = 'TestPlayer001';

-- 5.4 UPDATE - Multiple columns
UPDATE players
SET
    display_name = 'Updated Name',
    country_code = 'CA',
    updated_at = CURRENT_TIMESTAMP
WHERE username = 'TestPlayer001';

-- 5.5 UPDATE - With calculation
UPDATE players
SET total_playtime_minutes = total_playtime_minutes + 100
WHERE username = 'TestPlayer001';

-- 5.6 DELETE - Remove data (always use WHERE!)
-- First, check what will be deleted
SELECT * FROM players WHERE username = 'TestPlayer001';

-- Then delete
DELETE FROM players
WHERE username = 'TestPlayer001';

-- 5.7 DELETE with multiple conditions
DELETE FROM items
WHERE item_name IN ('Silver Sword', 'Bronze Shield')
  AND game_id = 1;

-- ===========================================
-- TRANSACTIONS EXAMPLE
-- ===========================================

-- PostgreSQL / MySQL transaction syntax
BEGIN;

-- Create a new player and give them a subscription
INSERT INTO players (username, email, password_hash, display_name, country_code, subscription_tier)
VALUES ('TransactionTest', 'transaction@email.com', 'hash_trans', 'Transaction Test', 'US', 'premium');

-- Record the subscription payment
INSERT INTO transactions (player_id, transaction_type, amount, payment_method, status)
SELECT player_id, 'subscription', 9.99, 'credit_card', 'completed'
FROM players
WHERE username = 'TransactionTest';

-- If everything is correct, commit
COMMIT;

-- If something went wrong, you would use:
-- ROLLBACK;

-- Clean up test data
DELETE FROM transactions WHERE player_id = (SELECT player_id FROM players WHERE username = 'TransactionTest');
DELETE FROM players WHERE username = 'TransactionTest';

-- ===========================================
-- USEFUL DATA EXPLORATION QUERIES
-- ===========================================

-- Count total players
SELECT COUNT(*) AS total_players FROM players;

-- Count players by subscription tier
SELECT subscription_tier, COUNT(*) AS player_count
FROM players
GROUP BY subscription_tier
ORDER BY player_count DESC;

-- Count players by country
SELECT country_code, COUNT(*) AS player_count
FROM players
WHERE country_code IS NOT NULL
GROUP BY country_code
ORDER BY player_count DESC;

-- Find the range of playtime
SELECT
    MIN(total_playtime_minutes) AS min_playtime,
    MAX(total_playtime_minutes) AS max_playtime,
    AVG(total_playtime_minutes) AS avg_playtime
FROM players;

-- Recent game releases
SELECT game_name, genre, release_date, rating
FROM games
ORDER BY release_date DESC
LIMIT 5;

-- High-value items
SELECT item_name, item_type, rarity, base_value
FROM items
WHERE rarity IN ('epic', 'legendary')
ORDER BY base_value DESC;
