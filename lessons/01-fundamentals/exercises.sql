-- ===========================================
-- Lesson 1: SQL Fundamentals - Practice Exercises
-- GameVerse Database
-- ===========================================

-- ===========================================
-- EXERCISE 1: Basic SELECT Queries
-- ===========================================

-- 1.1 Select all games in the 'Action' genre
-- Expected columns: game_name, genre, rating

-- YOUR QUERY HERE:


-- 1.2 List all players registered in the last 90 days
-- Expected columns: username, registration_date
-- Hint: Use CURRENT_TIMESTAMP - INTERVAL '90 days'

-- YOUR QUERY HERE:


-- 1.3 Find all items with rarity 'legendary' that are tradeable
-- Expected columns: item_name, rarity, base_value, is_tradeable

-- YOUR QUERY HERE:


-- 1.4 Display games with their prices in Euros (assume 1 USD = 0.92 EUR)
-- Expected columns: game_name, base_price (as usd_price), euro_price

-- YOUR QUERY HERE:


-- 1.5 Find unique genres in the games table
-- Expected: List of distinct genres

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 2: WHERE Clause and Filtering
-- ===========================================

-- 2.1 Find the top 20 players by total playtime who are from 'US' or 'GB'
-- Expected columns: username, country_code, total_playtime_minutes
-- Sort by playtime descending

-- YOUR QUERY HERE:


-- 2.2 List all games released in 2023 with rating >= 4.0
-- Expected columns: game_name, release_date, rating
-- Sort by rating descending

-- YOUR QUERY HERE:


-- 2.3 Find all premium or vip players who have played more than 5000 minutes
-- Expected columns: username, subscription_tier, total_playtime_minutes

-- YOUR QUERY HERE:


-- 2.4 Find games that are free (base_price = 0) OR cost more than $50
-- Expected columns: game_name, base_price, is_multiplayer

-- YOUR QUERY HERE:


-- 2.5 Find players whose username contains 'Dragon' or 'Warrior'
-- Expected columns: username, email, registration_date

-- YOUR QUERY HERE:


-- 2.6 Find all players who have never logged in (NULL last_login)
-- Expected columns: username, registration_date, last_login

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 3: ORDER BY and LIMIT
-- ===========================================

-- 3.1 Find the 5 highest-rated games
-- Expected columns: game_name, genre, rating

-- YOUR QUERY HERE:


-- 3.2 Find the 10 most recently registered players
-- Expected columns: username, registration_date, country_code

-- YOUR QUERY HERE:


-- 3.3 Get page 3 of players (items 21-30) ordered by username alphabetically
-- Expected columns: username, email

-- YOUR QUERY HERE:


-- 3.4 Find the 5 most expensive items
-- Expected columns: item_name, item_type, rarity, base_value

-- YOUR QUERY HERE:


-- ===========================================
-- EXERCISE 4: Data Manipulation
-- ===========================================

-- 4.1 Insert a new game into the games table
-- Game: "Adventure Quest", Genre: "Adventure", Release: 2024-02-15
-- Multiplayer: TRUE, Max Players: 4, Rating: 4.3, Price: 29.99

-- YOUR QUERY HERE:


-- 4.2 Update all players from 'MX' to have subscription_tier 'premium'
-- (Note: This is for practice only - be careful with bulk updates!)

-- YOUR QUERY HERE:


-- 4.3 Delete all scores where score_value is 0
-- First write a SELECT to see what would be deleted, then write the DELETE

-- Preview query:


-- Delete query:


-- ===========================================
-- EXERCISE 5: Combined Challenges
-- ===========================================

-- 5.1 Find VIP players from Asia-Pacific countries (JP, KR, AU)
-- who have more than 6000 minutes of playtime
-- Order by playtime descending, limit to 5

-- YOUR QUERY HERE:


-- 5.2 Find all multiplayer RPG games with ratings above 4.5
-- that can have more than 20 players

-- YOUR QUERY HERE:


-- 5.3 Find achievements for Game ID 1 that are 'rare' or rarer
-- (rare, epic, legendary) ordered by points descending

-- YOUR QUERY HERE:
