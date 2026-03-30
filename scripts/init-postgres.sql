-- ===========================================
-- GameVerse Database Schema - PostgreSQL
-- SQL Learning Curriculum for Data Engineers
-- ===========================================

-- Drop tables if they exist (for clean re-initialization)
DROP TABLE IF EXISTS daily_player_stats CASCADE;
DROP TABLE IF EXISTS event_logs CASCADE;
DROP TABLE IF EXISTS guild_members CASCADE;
DROP TABLE IF EXISTS guilds CASCADE;
DROP TABLE IF EXISTS friendships CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS player_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;
DROP TABLE IF EXISTS scores CASCADE;
DROP TABLE IF EXISTS game_sessions CASCADE;
DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS players CASCADE;

-- ===========================================
-- CORE TABLES
-- ===========================================

-- Players table: User accounts
CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    country_code CHAR(2),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    account_status VARCHAR(20) DEFAULT 'active',
    subscription_tier VARCHAR(20) DEFAULT 'free',
    total_playtime_minutes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Games table: Game catalog
CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    game_name VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    release_date DATE,
    developer VARCHAR(100),
    publisher VARCHAR(100),
    base_price DECIMAL(10,2),
    is_multiplayer BOOLEAN DEFAULT FALSE,
    max_players INT DEFAULT 1,
    rating DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Game sessions table: Player gaming activity
CREATE TABLE game_sessions (
    session_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    game_id INT REFERENCES games(game_id) ON DELETE CASCADE,
    session_start TIMESTAMP NOT NULL,
    session_end TIMESTAMP,
    duration_minutes INT,
    server_region VARCHAR(20),
    device_type VARCHAR(30),
    session_status VARCHAR(20) DEFAULT 'completed'
);

-- Scores table: Player scores and achievements
CREATE TABLE scores (
    score_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    game_id INT REFERENCES games(game_id) ON DELETE CASCADE,
    session_id INT REFERENCES game_sessions(session_id) ON DELETE SET NULL,
    score_value BIGINT NOT NULL,
    level_reached INT,
    difficulty VARCHAR(20),
    is_highscore BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Achievements table: Available achievements per game
CREATE TABLE achievements (
    achievement_id SERIAL PRIMARY KEY,
    game_id INT REFERENCES games(game_id) ON DELETE CASCADE,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    points INT DEFAULT 10,
    rarity VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Player achievements: Junction table for earned achievements
CREATE TABLE player_achievements (
    id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    achievement_id INT REFERENCES achievements(achievement_id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_percentage INT DEFAULT 100,
    UNIQUE(player_id, achievement_id)
);

-- Items table: In-game items catalog
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    game_id INT REFERENCES games(game_id) ON DELETE CASCADE,
    item_name VARCHAR(100) NOT NULL,
    item_type VARCHAR(50),
    rarity VARCHAR(20),
    base_value DECIMAL(10,2),
    is_tradeable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory table: Player item ownership
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    item_id INT REFERENCES items(item_id) ON DELETE CASCADE,
    quantity INT DEFAULT 1,
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acquired_method VARCHAR(50)
);

-- Transactions table: Purchases and payments
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    transaction_type VARCHAR(50),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    item_id INT REFERENCES items(item_id) ON DELETE SET NULL,
    game_id INT REFERENCES games(game_id) ON DELETE SET NULL,
    payment_method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Friendships table: Player social connections
CREATE TABLE friendships (
    friendship_id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    friend_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    UNIQUE(player_id, friend_id)
);

-- Guilds table: Player groups/clans
CREATE TABLE guilds (
    guild_id SERIAL PRIMARY KEY,
    guild_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    leader_id INT REFERENCES players(player_id) ON DELETE SET NULL,
    game_id INT REFERENCES games(game_id) ON DELETE CASCADE,
    member_count INT DEFAULT 1,
    max_members INT DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Guild members table: Guild membership
CREATE TABLE guild_members (
    id SERIAL PRIMARY KEY,
    guild_id INT REFERENCES guilds(guild_id) ON DELETE CASCADE,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    role VARCHAR(30) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(guild_id, player_id)
);

-- Event logs table: Raw event data (for ETL exercises)
CREATE TABLE event_logs (
    log_id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    player_id INT,
    game_id INT,
    event_data JSONB,
    client_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    is_processed BOOLEAN DEFAULT FALSE
);

-- Daily player stats table: Aggregated daily metrics
CREATE TABLE daily_player_stats (
    id SERIAL PRIMARY KEY,
    player_id INT REFERENCES players(player_id) ON DELETE CASCADE,
    stat_date DATE NOT NULL,
    total_sessions INT DEFAULT 0,
    total_playtime_minutes INT DEFAULT 0,
    total_score BIGINT DEFAULT 0,
    achievements_unlocked INT DEFAULT 0,
    items_acquired INT DEFAULT 0,
    money_spent DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(player_id, stat_date)
);

-- ===========================================
-- INDEXES
-- ===========================================

CREATE INDEX idx_players_country ON players(country_code);
CREATE INDEX idx_players_subscription ON players(subscription_tier);
CREATE INDEX idx_players_status ON players(account_status);
CREATE INDEX idx_sessions_player ON game_sessions(player_id);
CREATE INDEX idx_sessions_game ON game_sessions(game_id);
CREATE INDEX idx_sessions_start ON game_sessions(session_start);
CREATE INDEX idx_scores_player ON scores(player_id);
CREATE INDEX idx_scores_game ON scores(game_id);
CREATE INDEX idx_transactions_player ON transactions(player_id);
CREATE INDEX idx_transactions_date ON transactions(created_at);
CREATE INDEX idx_event_logs_type ON event_logs(event_type);
CREATE INDEX idx_event_logs_processed ON event_logs(is_processed);

-- ===========================================
-- SEED DATA: Games
-- ===========================================

INSERT INTO games (game_name, genre, release_date, developer, publisher, base_price, is_multiplayer, max_players, rating) VALUES
('Dragon Quest Online', 'RPG', '2023-03-15', 'Epic Studios', 'GameCorp', 59.99, TRUE, 100, 4.75),
('Speed Racers', 'Racing', '2023-06-20', 'Velocity Games', 'GameCorp', 49.99, TRUE, 12, 4.50),
('Puzzle Kingdom', 'Puzzle', '2023-01-10', 'Brain Works', 'Indie Pub', 19.99, FALSE, 1, 4.25),
('Battle Royale Arena', 'Action', '2022-11-05', 'Combat Studios', 'MegaGames', 0.00, TRUE, 100, 4.60),
('Space Explorers', 'Strategy', '2023-08-12', 'Stellar Dev', 'Cosmic Pub', 39.99, TRUE, 8, 4.35),
('Fantasy Warriors', 'RPG', '2022-05-22', 'Legend Games', 'MegaGames', 54.99, TRUE, 50, 4.80),
('City Builder Pro', 'Simulation', '2023-04-01', 'Urban Studios', 'SimWorld', 29.99, FALSE, 1, 4.40),
('Zombie Survival', 'Action', '2023-07-15', 'Horror Games', 'DarkSide Pub', 34.99, TRUE, 4, 4.15),
('Tennis Champions', 'Sports', '2023-02-28', 'Sports Interactive', 'GameCorp', 44.99, TRUE, 4, 4.30),
('Mystery Detective', 'Adventure', '2023-09-05', 'Story Masters', 'Narrative Inc', 24.99, FALSE, 1, 4.55);

-- ===========================================
-- SEED DATA: Players
-- ===========================================

INSERT INTO players (username, email, password_hash, display_name, country_code, registration_date, last_login, account_status, subscription_tier, total_playtime_minutes) VALUES
('DragonSlayer99', 'dragon@email.com', 'hash_001', 'Dragon Master', 'US', '2023-01-15 10:30:00', '2024-01-20 18:45:00', 'active', 'premium', 5420),
('SpeedDemon', 'speed@email.com', 'hash_002', 'Speed King', 'GB', '2023-02-20 14:15:00', '2024-01-19 22:30:00', 'active', 'vip', 8750),
('PuzzleMaster', 'puzzle@email.com', 'hash_003', 'Puzzle Pro', 'DE', '2023-03-10 09:00:00', '2024-01-20 12:00:00', 'active', 'free', 2100),
('WarriorPrincess', 'warrior@email.com', 'hash_004', 'Battle Queen', 'CA', '2023-01-05 16:45:00', '2024-01-18 20:15:00', 'active', 'premium', 6800),
('CosmicExplorer', 'cosmic@email.com', 'hash_005', 'Space Captain', 'AU', '2023-04-22 11:30:00', '2024-01-20 14:30:00', 'active', 'free', 3200),
('NightHunter', 'hunter@email.com', 'hash_006', 'Dark Hunter', 'US', '2023-05-18 20:00:00', '2024-01-17 23:45:00', 'active', 'premium', 4500),
('CityMayor', 'mayor@email.com', 'hash_007', 'Mayor Pro', 'FR', '2023-06-30 08:15:00', '2024-01-20 10:00:00', 'active', 'free', 1800),
('ZombieCrusher', 'zombie@email.com', 'hash_008', 'Zombie Killer', 'JP', '2023-07-12 15:30:00', '2024-01-19 19:00:00', 'active', 'vip', 7200),
('TennisAce', 'tennis@email.com', 'hash_009', 'Court Champion', 'ES', '2023-08-25 12:00:00', '2024-01-20 16:30:00', 'active', 'premium', 3900),
('DetectiveHolmes', 'detective@email.com', 'hash_010', 'Mystery Solver', 'GB', '2023-09-08 17:45:00', '2024-01-18 21:00:00', 'active', 'free', 2400),
('PixelWarrior', 'pixel@email.com', 'hash_011', 'Pixel Hero', 'US', '2023-02-14 10:00:00', '2024-01-15 14:00:00', 'active', 'free', 1500),
('ShadowNinja', 'shadow@email.com', 'hash_012', 'Shadow Master', 'JP', '2023-03-20 22:30:00', '2024-01-20 01:15:00', 'active', 'premium', 9100),
('RacingQueen', 'racing@email.com', 'hash_013', 'Speed Queen', 'IT', '2023-04-05 13:45:00', '2024-01-19 17:30:00', 'active', 'vip', 6300),
('MageSupreme', 'mage@email.com', 'hash_014', 'Grand Mage', 'BR', '2023-05-30 19:00:00', '2024-01-20 20:00:00', 'active', 'premium', 5800),
('GuildLeader', 'guild@email.com', 'hash_015', 'Guild Master', 'KR', '2023-01-25 07:30:00', '2024-01-20 09:45:00', 'active', 'vip', 11200),
('CasualGamer', 'casual@email.com', 'hash_016', 'Casual Player', 'MX', '2023-10-15 16:00:00', '2024-01-10 12:30:00', 'active', 'free', 450),
('ProStreamer', 'streamer@email.com', 'hash_017', 'Live Streamer', 'US', '2022-12-01 14:30:00', '2024-01-20 22:00:00', 'active', 'vip', 15600),
('RetroGamer', 'retro@email.com', 'hash_018', 'Retro Fan', 'DE', '2023-06-10 11:15:00', '2024-01-12 18:45:00', 'active', 'free', 980),
('EsportsChamp', 'esports@email.com', 'hash_019', 'Tournament King', 'KR', '2022-08-20 09:00:00', '2024-01-20 23:30:00', 'active', 'vip', 18500),
('WeekendPlayer', 'weekend@email.com', 'hash_020', 'Weekend Warrior', 'CA', '2023-11-05 20:30:00', NULL, 'active', 'free', 320);

-- ===========================================
-- SEED DATA: Game Sessions
-- ===========================================

INSERT INTO game_sessions (player_id, game_id, session_start, session_end, duration_minutes, server_region, device_type, session_status) VALUES
(1, 1, '2024-01-15 18:00:00', '2024-01-15 20:30:00', 150, 'us-east', 'pc', 'completed'),
(1, 1, '2024-01-18 19:00:00', '2024-01-18 21:00:00', 120, 'us-east', 'pc', 'completed'),
(2, 2, '2024-01-14 20:00:00', '2024-01-14 22:15:00', 135, 'eu-west', 'console', 'completed'),
(2, 2, '2024-01-19 21:00:00', '2024-01-19 23:30:00', 150, 'eu-west', 'console', 'completed'),
(3, 3, '2024-01-16 10:00:00', '2024-01-16 11:30:00', 90, 'eu-central', 'mobile', 'completed'),
(4, 6, '2024-01-17 15:00:00', '2024-01-17 18:00:00', 180, 'us-west', 'pc', 'completed'),
(5, 5, '2024-01-18 12:00:00', '2024-01-18 14:30:00', 150, 'ap-southeast', 'pc', 'completed'),
(6, 4, '2024-01-19 22:00:00', '2024-01-20 00:30:00', 150, 'us-east', 'pc', 'completed'),
(7, 7, '2024-01-15 09:00:00', '2024-01-15 11:00:00', 120, 'eu-west', 'pc', 'completed'),
(8, 8, '2024-01-16 20:00:00', '2024-01-16 23:00:00', 180, 'ap-northeast', 'console', 'completed'),
(9, 9, '2024-01-17 14:00:00', '2024-01-17 15:30:00', 90, 'eu-south', 'console', 'completed'),
(10, 10, '2024-01-18 19:00:00', '2024-01-18 21:30:00', 150, 'eu-west', 'pc', 'completed'),
(11, 1, '2024-01-19 16:00:00', '2024-01-19 17:30:00', 90, 'us-east', 'mobile', 'completed'),
(12, 6, '2024-01-20 00:00:00', '2024-01-20 03:00:00', 180, 'ap-northeast', 'pc', 'completed'),
(13, 2, '2024-01-14 18:00:00', '2024-01-14 20:00:00', 120, 'eu-south', 'console', 'completed'),
(14, 1, '2024-01-15 20:00:00', '2024-01-15 22:30:00', 150, 'sa-east', 'pc', 'completed'),
(15, 6, '2024-01-16 08:00:00', '2024-01-16 12:00:00', 240, 'ap-northeast', 'pc', 'completed'),
(15, 1, '2024-01-17 09:00:00', '2024-01-17 11:30:00', 150, 'ap-northeast', 'pc', 'completed'),
(17, 4, '2024-01-18 21:00:00', '2024-01-19 01:00:00', 240, 'us-east', 'pc', 'completed'),
(19, 4, '2024-01-19 22:00:00', '2024-01-20 02:00:00', 240, 'ap-northeast', 'pc', 'completed'),
(1, 4, '2024-01-20 18:00:00', '2024-01-20 19:30:00', 90, 'us-east', 'pc', 'completed'),
(2, 4, '2024-01-20 20:00:00', '2024-01-20 22:00:00', 120, 'eu-west', 'pc', 'completed'),
(3, 3, '2024-01-20 11:00:00', '2024-01-20 12:00:00', 60, 'eu-central', 'mobile', 'completed'),
(4, 1, '2024-01-20 14:00:00', '2024-01-20 16:30:00', 150, 'us-west', 'pc', 'completed'),
(5, 5, '2024-01-20 13:00:00', '2024-01-20 14:30:00', 90, 'ap-southeast', 'pc', 'completed');

-- ===========================================
-- SEED DATA: Scores
-- ===========================================

INSERT INTO scores (player_id, game_id, session_id, score_value, level_reached, difficulty, is_highscore, achieved_at) VALUES
(1, 1, 1, 125000, 45, 'hard', TRUE, '2024-01-15 20:30:00'),
(1, 1, 2, 98000, 38, 'hard', FALSE, '2024-01-18 21:00:00'),
(2, 2, 3, 45200, 12, 'medium', TRUE, '2024-01-14 22:15:00'),
(2, 2, 4, 52800, 15, 'hard', TRUE, '2024-01-19 23:30:00'),
(3, 3, 5, 89500, 150, 'easy', TRUE, '2024-01-16 11:30:00'),
(4, 6, 6, 215000, 62, 'expert', TRUE, '2024-01-17 18:00:00'),
(5, 5, 7, 78000, 25, 'medium', TRUE, '2024-01-18 14:30:00'),
(6, 4, 8, 15, NULL, 'hard', FALSE, '2024-01-20 00:30:00'),
(7, 7, 9, 1250000, NULL, 'easy', TRUE, '2024-01-15 11:00:00'),
(8, 8, 10, 45000, 22, 'hard', TRUE, '2024-01-16 23:00:00'),
(9, 9, 11, 6, 3, 'medium', FALSE, '2024-01-17 15:30:00'),
(10, 10, 12, 8500, 8, 'medium', TRUE, '2024-01-18 21:30:00'),
(11, 1, 13, 35000, 15, 'easy', FALSE, '2024-01-19 17:30:00'),
(12, 6, 14, 310000, 85, 'expert', TRUE, '2024-01-20 03:00:00'),
(13, 2, 15, 38500, 10, 'medium', FALSE, '2024-01-14 20:00:00'),
(14, 1, 16, 142000, 52, 'hard', TRUE, '2024-01-15 22:30:00'),
(15, 6, 17, 425000, 120, 'expert', TRUE, '2024-01-16 12:00:00'),
(15, 1, 18, 185000, 58, 'expert', TRUE, '2024-01-17 11:30:00'),
(17, 4, 19, 28, NULL, 'hard', TRUE, '2024-01-19 01:00:00'),
(19, 4, 20, 35, NULL, 'expert', TRUE, '2024-01-20 02:00:00'),
(1, 4, 21, 8, NULL, 'medium', FALSE, '2024-01-20 19:30:00'),
(2, 4, 22, 12, NULL, 'hard', FALSE, '2024-01-20 22:00:00'),
(3, 3, 23, 95000, 165, 'medium', TRUE, '2024-01-20 12:00:00'),
(4, 1, 24, 168000, 55, 'hard', FALSE, '2024-01-20 16:30:00'),
(5, 5, 25, 82000, 28, 'hard', TRUE, '2024-01-20 14:30:00');

-- ===========================================
-- SEED DATA: Achievements
-- ===========================================

INSERT INTO achievements (game_id, achievement_name, description, points, rarity) VALUES
(1, 'Dragon Slayer', 'Defeat 100 dragons', 100, 'legendary'),
(1, 'First Steps', 'Complete the tutorial', 10, 'common'),
(1, 'Level 10', 'Reach level 10', 25, 'common'),
(1, 'Level 50', 'Reach level 50', 75, 'rare'),
(1, 'Guild Founder', 'Create a guild', 50, 'uncommon'),
(2, 'Speed Demon', 'Win 50 races', 75, 'rare'),
(2, 'Nitro Master', 'Use nitro 1000 times', 50, 'uncommon'),
(2, 'Track Legend', 'Complete all tracks', 100, 'legendary'),
(3, 'Puzzle Beginner', 'Solve 10 puzzles', 10, 'common'),
(3, 'Puzzle Expert', 'Solve 100 puzzles', 50, 'rare'),
(3, 'Speed Solver', 'Solve a puzzle in under 30 seconds', 75, 'epic'),
(4, 'First Blood', 'Get your first elimination', 10, 'common'),
(4, 'Victory Royale', 'Win a match', 50, 'uncommon'),
(4, 'Champion', 'Win 100 matches', 100, 'legendary'),
(6, 'Knight', 'Reach Knight rank', 50, 'uncommon'),
(6, 'Warrior King', 'Complete all main quests', 100, 'legendary'),
(7, 'City Planner', 'Build a city with 10000 population', 50, 'uncommon'),
(8, 'Survivor', 'Survive 10 nights', 25, 'common'),
(8, 'Zombie Hunter', 'Eliminate 500 zombies', 75, 'rare'),
(9, 'Grand Slam', 'Win all four major tournaments', 100, 'legendary');

-- ===========================================
-- SEED DATA: Player Achievements
-- ===========================================

INSERT INTO player_achievements (player_id, achievement_id, unlocked_at, progress_percentage) VALUES
(1, 1, '2024-01-10 15:30:00', 100),
(1, 2, '2023-01-16 11:00:00', 100),
(1, 3, '2023-01-20 14:00:00', 100),
(1, 4, '2023-06-15 18:00:00', 100),
(2, 6, '2023-08-20 22:00:00', 100),
(2, 7, '2023-05-10 20:30:00', 100),
(3, 9, '2023-03-15 10:00:00', 100),
(3, 10, '2023-09-20 11:45:00', 100),
(4, 15, '2023-04-10 16:00:00', 100),
(4, 16, '2023-12-25 19:00:00', 100),
(6, 12, '2023-06-01 22:30:00', 100),
(6, 13, '2023-07-15 23:45:00', 100),
(8, 18, '2023-07-20 21:00:00', 100),
(8, 19, '2023-11-30 22:15:00', 100),
(12, 1, '2023-10-15 02:00:00', 100),
(12, 4, '2023-08-20 01:30:00', 100),
(15, 1, '2023-05-10 10:00:00', 100),
(15, 4, '2023-03-15 09:30:00', 100),
(15, 5, '2023-02-01 08:00:00', 100),
(17, 12, '2023-01-15 22:00:00', 100),
(17, 13, '2023-02-20 23:30:00', 100),
(17, 14, '2023-08-10 01:00:00', 100),
(19, 12, '2022-09-15 22:00:00', 100),
(19, 13, '2022-10-20 23:00:00', 100),
(19, 14, '2023-03-05 00:30:00', 100);

-- ===========================================
-- SEED DATA: Items
-- ===========================================

INSERT INTO items (game_id, item_name, item_type, rarity, base_value, is_tradeable) VALUES
(1, 'Dragon Sword', 'weapon', 'legendary', 500.00, TRUE),
(1, 'Steel Armor', 'armor', 'rare', 150.00, TRUE),
(1, 'Health Potion', 'consumable', 'common', 5.00, TRUE),
(1, 'Magic Staff', 'weapon', 'epic', 300.00, TRUE),
(1, 'Phoenix Feather', 'cosmetic', 'legendary', 1000.00, FALSE),
(2, 'Turbo Engine', 'upgrade', 'rare', 200.00, TRUE),
(2, 'Racing Suit', 'cosmetic', 'uncommon', 50.00, TRUE),
(2, 'Nitro Boost', 'consumable', 'common', 10.00, TRUE),
(4, 'Golden Gun', 'weapon', 'legendary', 750.00, FALSE),
(4, 'Combat Skin', 'cosmetic', 'epic', 250.00, TRUE),
(4, 'Shield Potion', 'consumable', 'common', 15.00, TRUE),
(6, 'Excalibur', 'weapon', 'legendary', 999.00, FALSE),
(6, 'Knight Armor', 'armor', 'epic', 400.00, TRUE),
(6, 'Healing Herb', 'consumable', 'common', 3.00, TRUE),
(8, 'Chainsaw', 'weapon', 'rare', 180.00, TRUE),
(8, 'Medkit', 'consumable', 'uncommon', 25.00, TRUE);

-- ===========================================
-- SEED DATA: Inventory
-- ===========================================

INSERT INTO inventory (player_id, item_id, quantity, acquired_at, acquired_method) VALUES
(1, 1, 1, '2024-01-10 15:35:00', 'reward'),
(1, 2, 1, '2023-06-20 18:00:00', 'purchase'),
(1, 3, 25, '2024-01-15 20:00:00', 'purchase'),
(2, 6, 1, '2023-09-10 21:00:00', 'reward'),
(2, 7, 3, '2023-05-15 20:00:00', 'purchase'),
(2, 8, 50, '2024-01-19 22:00:00', 'purchase'),
(4, 12, 1, '2023-12-25 19:05:00', 'reward'),
(4, 13, 1, '2023-08-10 17:00:00', 'purchase'),
(4, 14, 100, '2024-01-17 16:00:00', 'purchase'),
(6, 9, 1, '2023-11-20 23:00:00', 'reward'),
(6, 10, 2, '2023-10-15 22:30:00', 'purchase'),
(8, 15, 1, '2023-12-01 22:00:00', 'purchase'),
(8, 16, 30, '2024-01-16 21:00:00', 'purchase'),
(12, 1, 1, '2023-10-15 02:05:00', 'reward'),
(12, 4, 1, '2023-11-20 01:00:00', 'purchase'),
(15, 1, 1, '2023-05-10 10:05:00', 'reward'),
(15, 4, 2, '2023-07-15 09:00:00', 'purchase'),
(15, 5, 1, '2023-09-20 08:30:00', 'reward'),
(17, 9, 1, '2023-08-10 01:05:00', 'reward'),
(17, 10, 5, '2024-01-18 22:00:00', 'purchase'),
(19, 9, 1, '2023-03-05 00:35:00', 'reward');

-- ===========================================
-- SEED DATA: Transactions
-- ===========================================

INSERT INTO transactions (player_id, transaction_type, amount, currency, item_id, game_id, payment_method, status, created_at) VALUES
(1, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-01-15 10:35:00'),
(1, 'purchase', 150.00, 'USD', 2, 1, 'credit_card', 'completed', '2023-06-20 18:00:00'),
(1, 'purchase', 25.00, 'USD', 3, 1, 'paypal', 'completed', '2024-01-15 20:00:00'),
(2, 'subscription', 19.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-02-20 14:20:00'),
(2, 'purchase', 50.00, 'USD', 7, 2, 'credit_card', 'completed', '2023-05-15 20:00:00'),
(2, 'purchase', 100.00, 'USD', 8, 2, 'paypal', 'completed', '2024-01-19 22:00:00'),
(4, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-01-05 16:50:00'),
(4, 'purchase', 400.00, 'USD', 13, 6, 'credit_card', 'completed', '2023-08-10 17:00:00'),
(4, 'purchase', 30.00, 'USD', 14, 6, 'paypal', 'completed', '2024-01-17 16:00:00'),
(6, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-05-18 20:05:00'),
(6, 'purchase', 500.00, 'USD', 10, 4, 'credit_card', 'completed', '2023-10-15 22:30:00'),
(8, 'subscription', 19.99, 'USD', NULL, NULL, 'paypal', 'completed', '2023-07-12 15:35:00'),
(8, 'purchase', 180.00, 'USD', 15, 8, 'credit_card', 'completed', '2023-12-01 22:00:00'),
(8, 'purchase', 75.00, 'USD', 16, 8, 'paypal', 'completed', '2024-01-16 21:00:00'),
(9, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-08-25 12:05:00'),
(12, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-03-20 22:35:00'),
(12, 'purchase', 300.00, 'USD', 4, 1, 'credit_card', 'completed', '2023-11-20 01:00:00'),
(13, 'subscription', 19.99, 'USD', NULL, NULL, 'paypal', 'completed', '2023-04-05 13:50:00'),
(14, 'subscription', 9.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-05-30 19:05:00'),
(15, 'subscription', 19.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2023-01-25 07:35:00'),
(15, 'purchase', 600.00, 'USD', 4, 1, 'credit_card', 'completed', '2023-07-15 09:00:00'),
(17, 'subscription', 19.99, 'USD', NULL, NULL, 'credit_card', 'completed', '2022-12-01 14:35:00'),
(17, 'purchase', 1250.00, 'USD', 10, 4, 'credit_card', 'completed', '2024-01-18 22:00:00'),
(19, 'subscription', 19.99, 'USD', NULL, NULL, 'paypal', 'completed', '2022-08-20 09:05:00');

-- ===========================================
-- SEED DATA: Friendships
-- ===========================================

INSERT INTO friendships (player_id, friend_id, status, created_at, accepted_at) VALUES
(1, 4, 'accepted', '2023-02-01 10:00:00', '2023-02-01 12:00:00'),
(1, 6, 'accepted', '2023-03-15 14:00:00', '2023-03-15 16:30:00'),
(1, 14, 'accepted', '2023-06-20 18:30:00', '2023-06-20 19:00:00'),
(2, 13, 'accepted', '2023-04-10 20:00:00', '2023-04-10 21:15:00'),
(4, 1, 'accepted', '2023-02-01 12:00:00', '2023-02-01 12:00:00'),
(4, 14, 'accepted', '2023-07-05 15:00:00', '2023-07-05 17:00:00'),
(6, 1, 'accepted', '2023-03-15 16:30:00', '2023-03-15 16:30:00'),
(6, 17, 'accepted', '2023-08-20 22:00:00', '2023-08-20 23:00:00'),
(8, 12, 'accepted', '2023-09-10 21:00:00', '2023-09-10 22:30:00'),
(12, 8, 'accepted', '2023-09-10 22:30:00', '2023-09-10 22:30:00'),
(12, 15, 'accepted', '2023-10-05 01:00:00', '2023-10-05 08:00:00'),
(15, 12, 'accepted', '2023-10-05 08:00:00', '2023-10-05 08:00:00'),
(15, 19, 'accepted', '2023-02-15 09:00:00', '2023-02-15 10:00:00'),
(17, 6, 'accepted', '2023-08-20 23:00:00', '2023-08-20 23:00:00'),
(17, 19, 'accepted', '2023-01-10 22:00:00', '2023-01-10 23:30:00'),
(19, 15, 'accepted', '2023-02-15 10:00:00', '2023-02-15 10:00:00'),
(19, 17, 'accepted', '2023-01-10 23:30:00', '2023-01-10 23:30:00'),
(3, 7, 'pending', '2024-01-15 11:00:00', NULL),
(5, 9, 'pending', '2024-01-18 13:00:00', NULL);

-- ===========================================
-- SEED DATA: Guilds
-- ===========================================

INSERT INTO guilds (guild_name, description, leader_id, game_id, member_count, max_members, created_at) VALUES
('Dragon Knights', 'Elite RPG guild for Dragon Quest Online', 15, 1, 8, 50, '2023-02-01 08:00:00'),
('Speed Legends', 'Top racing guild in Speed Racers', 2, 2, 5, 25, '2023-05-10 20:00:00'),
('Battle Masters', 'Competitive Battle Royale team', 17, 4, 12, 50, '2023-01-15 22:00:00'),
('Fantasy Heroes', 'Casual Fantasy Warriors guild', 4, 6, 6, 30, '2023-04-20 16:00:00'),
('Zombie Hunters', 'Survive together in Zombie Survival', 8, 8, 4, 20, '2023-08-01 21:00:00');

-- ===========================================
-- SEED DATA: Guild Members
-- ===========================================

INSERT INTO guild_members (guild_id, player_id, role, joined_at) VALUES
(1, 15, 'leader', '2023-02-01 08:00:00'),
(1, 1, 'officer', '2023-02-05 10:00:00'),
(1, 12, 'officer', '2023-02-10 01:00:00'),
(1, 14, 'member', '2023-03-15 19:00:00'),
(1, 11, 'member', '2023-04-20 16:00:00'),
(1, 4, 'member', '2023-05-10 15:00:00'),
(1, 6, 'member', '2023-06-20 22:00:00'),
(1, 18, 'member', '2023-07-15 11:00:00'),
(2, 2, 'leader', '2023-05-10 20:00:00'),
(2, 13, 'officer', '2023-05-15 18:00:00'),
(2, 9, 'member', '2023-06-20 14:00:00'),
(2, 5, 'member', '2023-07-10 12:00:00'),
(2, 20, 'member', '2023-11-10 20:00:00'),
(3, 17, 'leader', '2023-01-15 22:00:00'),
(3, 19, 'officer', '2023-01-20 23:00:00'),
(3, 6, 'officer', '2023-02-15 22:00:00'),
(3, 1, 'member', '2023-03-10 18:00:00'),
(3, 2, 'member', '2023-04-05 20:00:00'),
(4, 4, 'leader', '2023-04-20 16:00:00'),
(4, 14, 'officer', '2023-05-01 19:00:00'),
(4, 1, 'member', '2023-05-15 18:00:00'),
(4, 12, 'member', '2023-06-10 01:00:00'),
(5, 8, 'leader', '2023-08-01 21:00:00'),
(5, 6, 'member', '2023-08-15 22:00:00');

-- ===========================================
-- SEED DATA: Event Logs (for ETL exercises)
-- ===========================================

INSERT INTO event_logs (event_type, player_id, game_id, event_data, client_ip, created_at, is_processed) VALUES
('login', 1, NULL, '{"device": "pc", "region": "us-east"}', '192.168.1.100', '2024-01-20 18:00:00', FALSE),
('game_start', 1, 4, '{"session_id": 21, "difficulty": "medium"}', '192.168.1.100', '2024-01-20 18:00:30', FALSE),
('score_update', 1, 4, '{"score": 8, "kills": 8}', '192.168.1.100', '2024-01-20 19:30:00', FALSE),
('item_acquired', 1, 4, '{"item_id": 11, "rarity": "common", "method": "loot"}', '192.168.1.100', '2024-01-20 19:15:00', FALSE),
('login', 2, NULL, '{"device": "pc", "region": "eu-west"}', '10.0.0.50', '2024-01-20 20:00:00', FALSE),
('game_start', 2, 4, '{"session_id": 22, "difficulty": "hard"}', '10.0.0.50', '2024-01-20 20:00:30', FALSE),
('achievement_unlock', 2, 4, '{"achievement_id": 13, "name": "Victory Royale"}', '10.0.0.50', '2024-01-20 21:45:00', FALSE),
('purchase', 17, 4, '{"item_id": 10, "amount": 250, "currency": "USD"}', '172.16.0.25', '2024-01-18 22:00:00', TRUE),
('login', 15, NULL, '{"device": "pc", "region": "ap-northeast"}', '192.168.2.1', '2024-01-20 09:00:00', FALSE),
('guild_event', 15, 1, '{"action": "member_promoted", "target_player": 12, "new_role": "officer"}', '192.168.2.1', '2024-01-20 09:30:00', FALSE),
('logout', 1, NULL, '{"session_duration": 90, "last_game": 4}', '192.168.1.100', '2024-01-20 19:30:00', FALSE),
('error', NULL, NULL, '{"error_type": "connection_timeout", "server": "us-east-2"}', NULL, '2024-01-20 15:00:00', FALSE);

-- ===========================================
-- SEED DATA: Daily Player Stats
-- ===========================================

INSERT INTO daily_player_stats (player_id, stat_date, total_sessions, total_playtime_minutes, total_score, achievements_unlocked, items_acquired, money_spent) VALUES
(1, '2024-01-15', 1, 150, 125000, 0, 1, 0.00),
(1, '2024-01-18', 1, 120, 98000, 0, 0, 0.00),
(1, '2024-01-20', 1, 90, 8, 0, 0, 0.00),
(2, '2024-01-14', 1, 135, 45200, 0, 0, 0.00),
(2, '2024-01-19', 1, 150, 52800, 0, 1, 100.00),
(2, '2024-01-20', 1, 120, 12, 0, 0, 0.00),
(3, '2024-01-16', 1, 90, 89500, 0, 0, 0.00),
(3, '2024-01-20', 1, 60, 95000, 0, 0, 0.00),
(4, '2024-01-17', 1, 180, 215000, 0, 1, 30.00),
(4, '2024-01-20', 1, 150, 168000, 0, 0, 0.00),
(5, '2024-01-18', 1, 150, 78000, 0, 0, 0.00),
(5, '2024-01-20', 1, 90, 82000, 0, 0, 0.00),
(15, '2024-01-16', 1, 240, 425000, 0, 0, 0.00),
(15, '2024-01-17', 1, 150, 185000, 0, 0, 0.00),
(17, '2024-01-18', 1, 240, 28, 0, 1, 1250.00),
(19, '2024-01-19', 1, 240, 35, 0, 0, 0.00);

-- ===========================================
-- Completion message
-- ===========================================
DO $$
BEGIN
    RAISE NOTICE 'GameVerse database initialized successfully!';
    RAISE NOTICE 'Tables created: 14';
    RAISE NOTICE 'Sample data loaded for all tables';
END $$;
