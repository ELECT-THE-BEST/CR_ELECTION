-- ==============================================================
--  SQL script to modify students table and create candidates table
--  Run this in MySQL Workbench
-- ==============================================================

-- 1️⃣ Switch to your database
USE cr_election_db;

-- 2️⃣ Modify the students table to make sic the primary key
-- First, drop the existing primary key
ALTER TABLE students DROP PRIMARY KEY;

-- Then, make sic NOT NULL and set it as the primary key
ALTER TABLE students MODIFY sic VARCHAR(50) NOT NULL;
ALTER TABLE students ADD PRIMARY KEY (sic);

-- 3️⃣ Create the candidates table with foreign key reference to students
CREATE TABLE IF NOT EXISTS candidates (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    sic        VARCHAR(50) NOT NULL UNIQUE,
    votes      INT DEFAULT 0,
    motiv      TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sic) REFERENCES students(sic) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4️⃣ Verify the changes
DESCRIBE students;
DESCRIBE candidates;

-- 5️⃣ Optional: View all tables
SHOW TABLES;

-- ==============================================================
--  End of script
-- ==============================================================
