-- ==============================================================
--  SQL script to create the CR_Election database and required table
-- ==============================================================

-- 1️⃣ Create the database (replace `cr_election_db` with your preferred name)
CREATE DATABASE IF NOT EXISTS cr_election_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2️⃣ Create a MySQL user (optional – you can use an existing user)
--    Replace 'cr_user' and 'StrongPassword123!' with your own credentials.
--    COMMENT THIS SECTION OUT IF YOU ALREADY HAVE A USER.
CREATE USER IF NOT EXISTS 'cr_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON cr_election_db.* TO 'cr_user'@'localhost';
FLUSH PRIVILEGES;

-- 3️⃣ Switch to the newly created database
USE cr_election_db;

-- 4️⃣ Create the `students` table – matches the columns expected by upload.jsp
CREATE TABLE IF NOT EXISTS students (
    serial_no VARCHAR(50) NOT NULL,
    roll_no   VARCHAR(50) NOT NULL,
    sic       VARCHAR(50) NOT NULL PRIMARY KEY,
    reg_code  VARCHAR(50),
    image_url VARCHAR(255),
    name      VARCHAR(100),
    branch    VARCHAR(100),
    section   VARCHAR(50),
    year      VARCHAR(10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5️⃣ Create the `candidates` table – stores CR candidates and their vote counts
CREATE TABLE IF NOT EXISTS candidates (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    sic        VARCHAR(50) NOT NULL UNIQUE,
    votes      INT DEFAULT 0,
    motiv      TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sic) REFERENCES students(sic) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6️⃣ Optional: Insert a dummy row to verify everything works
INSERT INTO students (serial_no, roll_no, sic, reg_code, image_url, name, branch, section, year)
VALUES ('1', '2023001', 'SIC001', 'REG001', 'https://example.com/photo.jpg', 'John Doe', 'CSE', 'A', '1');

-- ==============================================================
--  End of script
-- ==============================================================
