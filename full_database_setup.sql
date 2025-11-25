-- Database Creation
CREATE DATABASE IF NOT EXISTS cr_election_db;
USE cr_election_db;

-- Table structure for table `students`
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial_no` varchar(50) NOT NULL,
  `roll_no` varchar(50) NOT NULL,
  `sic` varchar(50) NOT NULL,
  `reg_code` varchar(50) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `branch` varchar(100) DEFAULT NULL,
  `section` varchar(50) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `isVoted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_sic` (`sic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table structure for table `candidates`
DROP TABLE IF EXISTS `candidates`;
CREATE TABLE `candidates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sic` varchar(50) NOT NULL,
  `votes` int DEFAULT '0',
  `motiv` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sic` (`sic`),
  CONSTRAINT `fk_candidate_student` FOREIGN KEY (`sic`) REFERENCES `students` (`sic`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
