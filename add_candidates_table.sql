-- ==============================================================
--  SQL script to add the candidates table to existing database
--  Run this in MySQL Workbench if you already have the database set up
-- ==============================================================

-- 1️⃣ Switch to your database
USE cr_election_db;

-- 2️⃣ Add an index to the sic column in students table (required for foreign key)
ALTER TABLE students ADD INDEX idx_sic (sic);

-- 3️⃣ Create the candidates table
CREATE TABLE IF NOT EXISTS candidates (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    sic        VARCHAR(50) NOT NULL UNIQUE,
    votes      INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sic) REFERENCES students(sic) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3️⃣ Optional: Insert sample candidate data (uncomment to use)
-- INSERT INTO candidates (sic, votes) VALUES ('SIC001', 0);
-- INSERT INTO candidates (sic, votes) VALUES ('SIC002', 0);

-- 4️⃣ Verify the table was created
SHOW TABLES;

-- 5️⃣ View the table structure
DESCRIBE candidates;

-- ==============================================================
--  End of script
-- ==============================================================
