-- Tic Tac Toe Multiplayer Platform - MySQL Schema
-- --------------------------------------------------
-- Users, Games, Moves, Leaderboard Tables
-- --------------------------------------------------

-- USERS table: handles authentication and stores basic info
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME DEFAULT NULL,
    wins INT DEFAULT 0,
    losses INT DEFAULT 0,
    draws INT DEFAULT 0
);

-- GAMES table: represents ongoing or finished games
CREATE TABLE IF NOT EXISTS games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_x_id INT NOT NULL,
    player_o_id INT,
    winner_id INT,  -- NULL if draw or unfinished
    status ENUM('waiting', 'active', 'finished') NOT NULL DEFAULT 'waiting',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    finished_at DATETIME DEFAULT NULL,
    FOREIGN KEY (player_x_id) REFERENCES users(id),
    FOREIGN KEY (player_o_id) REFERENCES users(id),
    FOREIGN KEY (winner_id) REFERENCES users(id)
);

-- MOVES table: represents each move in a game, for both game state and history
CREATE TABLE IF NOT EXISTS moves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    player_id INT NOT NULL,
    move_number INT NOT NULL, -- 1 to 9
    row INT NOT NULL,         -- 0, 1, 2 (for a 3x3 board)
    col INT NOT NULL,         -- 0, 1, 2 (for a 3x3 board)
    symbol CHAR(1) NOT NULL,  -- 'X' or 'O'
    move_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES users(id)
);

-- LEADERBOARD view: shows current leader ranks by wins, then draws, then losses
CREATE OR REPLACE VIEW leaderboard AS
SELECT
    u.id AS user_id,
    u.username,
    u.wins,
    u.losses,
    u.draws,
    (u.wins * 3 + u.draws) AS points,
    (u.wins + u.losses + u.draws) AS games_played
FROM users u
ORDER BY points DESC, wins DESC, draws DESC, losses ASC, username ASC;

-- For quick lookup, add some indices
CREATE INDEX IF NOT EXISTS idx_games_status ON games (status);
CREATE INDEX IF NOT EXISTS idx_moves_game_id ON moves (game_id);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- --------------------------------------------------
-- Example admin user creation (remove or adjust in production)
-- --------------------------------------------------
-- INSERT INTO users (username, email, password_hash) VALUES ('admin', 'admin@example.com', '<hashed_password_here>');
