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
select game_name, genre, rating from games where genre='Action'

-- 1.2 List all players registered in the last 90 days
-- Expected columns: username, registration_date
-- Hint: Use CURRENT_TIMESTAMP - INTERVAL '90 days' 

-- YOUR QUERY HERE:
select username, registration_date from players where registration_date >= CURRENT_TIMESTAMP - INTERVAL '90 days' 

-- 1.3 Find all items with rarity 'legendary' that are tradeable
-- Expected columns: item_name, rarity, base_value, is_tradeable

-- YOUR QUERY HERE:
select item_name, rarity, base_value, is_tradeable from items where rarity = 'legendary' and is_tradeable='True'

-- 1.4 Display games with their prices in Euros (assume 1 USD = 0.92 EUR)
-- Expected columns: game_name, base_price (as usd_price), euro_price

-- YOUR QUERY HERE:
select game_name, base_price as usd_price, base_price * 0.92 AS euro_price from games

-- 1.5 Find unique genres in the games table
-- Expected: List of distinct genres

-- YOUR QUERY HERE:
select distinct genre from games

-- ===========================================
-- EXERCISE 2: WHERE Clause and Filtering
-- ===========================================

-- 2.1 Find the top 20 players by total playtime who are from 'US' or 'GB'
-- Expected columns: username, country_code, total_playtime_minutes
-- Sort by playtime descending

-- YOUR QUERY HERE:
select  username, country_code, total_playtime_minutes 
from players where country_code in ('US','GB')
group by username, country_code
order by total_playtime_minutes desc
limit 20

-- 2.2 List all games released in 2023 with rating >= 4.0
-- Expected columns: game_name, release_date, rating
-- Sort by rating descending

-- YOUR QUERY HERE:
select game_name, release_date, rating from games 
where release_date between '01-jan-2023' and '31-dec-2023' and rating >= 4
order by rating desc

-- 2.3 Find all premium or vip players who have played more than 5000 minutes
-- Expected columns: username, subscription_tier, total_playtime_minutes

-- YOUR QUERY HERE:
select username, subscription_tier, total_playtime_minutes from players 
where subscription_tier in ('premiun','vip')
having playtime_minutes >5000

-- 2.4 Find games that are free (base_price = 0) OR cost more than $50
-- Expected columns: game_name, base_price, is_multiplayer

-- YOUR QUERY HERE:
select game_name, base_price, is_multiplayer from games where base_price =0 or base_price  >50

-- 2.5 Find players whose username contains 'Dragon' or 'Warrior'
-- Expected columns: username, email, registration_date

-- YOUR QUERY HERE:
select username, email, registration_date from players where username like '%Dragon%' OR username like '%Warrior%'

-- 2.6 Find all players who have never logged in (NULL last_login)
-- Expected columns: username, registration_date, last_login

-- YOUR QUERY HERE:
select username, registration_date, last_login from players where last_login is null

-- ===========================================
-- EXERCISE 3: ORDER BY and LIMIT
-- ===========================================

-- 3.1 Find the 5 highest-rated games
-- Expected columns: game_name, genre, rating

-- YOUR QUERY HERE:
select game_name, genre, rating from games order by rating desc limit 5

-- 3.2 Find the 10 most recently registered players
-- Expected columns: username, registration_date, country_code

-- YOUR QUERY HERE:
select username, registration_date, country_code from players order by registration_date desc limit 10

-- 3.3 Get page 3 of players (items 21-30) ordered by username alphabetically
-- Expected columns: username, email

-- YOUR QUERY HERE:
select username, email from players order by username limit 10 offset 20

-- 3.4 Find the 5 most expensive items
-- Expected columns: item_name, item_type, rarity, base_value

-- YOUR QUERY HERE:
select item_name, item_type, rarity, base_value from items order by base_value desc limit 5

-- ===========================================
-- EXERCISE 4: Data Manipulation
-- ===========================================

-- 4.1 Insert a new game into the games table
-- Game: "Adventure Quest", Genre: "Adventure", Release: 2024-02-15
-- Multiplayer: TRUE, Max Players: 4, Rating: 4.3, Price: 29.99

-- YOUR QUERY HERE:
insert into games (
    game_name,
    genre,
    release_date,
    is_multiplayer,
    max_players,
    rating,
    base_price)
values (
    'Adventure Quest',
    'Adventure',
    '2024-02-15',
    TRUE,
    4,
    4.3,
    29.99);

-- 4.2 Update all players from 'MX' to have subscription_tier 'premium'
-- (Note: This is for practice only - be careful with bulk updates!)

-- YOUR QUERY HERE:
update players set subscription_tier = 'premium' where country_code='MX'

-- 4.3 Delete all scores where score_value is 0
-- First write a SELECT to see what would be deleted, then write the DELETE

-- Preview query:
select * from scores where score_value=0

-- Delete query:
delete from scores where score_value=0

-- ===========================================
-- EXERCISE 5: Combined Challenges
-- ===========================================

-- 5.1 Find VIP players from Asia-Pacific countries (JP, KR, AU)
-- who have more than 6000 minutes of playtime
-- Order by playtime descending, limit to 5

-- YOUR QUERY HERE:
select * from players where country_code in ('JP', 'KR', 'AU')
and total_playtime_minutes > 6000
and subscription_tier='VIP'
order by total_playtime_minutes desc limit 5

-- 5.2 Find all multiplayer RPG games with ratings above 4.5
-- that can have more than 20 players

-- YOUR QUERY HERE:
select game_name, genre, rating, max_players
from games
WHERE is_multiplayer = 'TRUE'
  AND genre = 'RPG'
  AND rating > 4.5
  AND max_players > 20;

-- 5.3 Find achievements for Game ID 1 that are 'rare' or rarer
-- (rare, epic, legendary) ordered by points descending

-- YOUR QUERY HERE:
select 
    achievement_name,
    rarity,
    points
from achievements
where game_id = 1
  and rarity in ('rare', 'epic', 'legendary')
order by points desc;