-- ========================================
-- Database Schema Check and Fix
-- ========================================

-- Check current column types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    COLUMN_TYPE 
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'cr_election_db' 
    AND TABLE_NAME IN ('students', 'candidates')
    AND COLUMN_NAME = 'year';

-- If the above shows VARCHAR, run these commands to fix:
-- (Uncomment the lines below if year is VARCHAR)

-- ALTER TABLE students MODIFY COLUMN year INT NOT NULL;
-- ALTER TABLE candidates MODIFY COLUMN year INT NOT NULL;

-- Verify the change
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    COLUMN_TYPE 
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'cr_election_db' 
    AND TABLE_NAME IN ('students', 'candidates')
    AND COLUMN_NAME = 'year';

-- Test query to see if deletion would work
-- (This is a SELECT, not DELETE, so it's safe to run)
SELECT COUNT(*) as 'Students that would be deleted' 
FROM students 
WHERE year = 1;

SELECT COUNT(*) as 'Candidates that would be deleted' 
FROM candidates 
WHERE year = 1;
