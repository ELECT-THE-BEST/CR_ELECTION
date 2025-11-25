# Debugging Guide: Delete Data Error

## Problem
Getting "Error deleting data. Please try again." when trying to delete data with specific filters.

## Steps to Debug and Fix

### Step 1: Check Browser Console for Detailed Error
1. Open the admin page in your browser
2. Press F12 to open Developer Tools
3. Go to the "Console" tab
4. Try to delete data again
5. Look for any error messages in red
6. **Copy the full error message and check what it says**

### Step 2: Check Tomcat Server Logs
1. Navigate to your Tomcat installation directory (usually `C:\Program Files\Apache Software Foundation\Tomcat X.X\`)
2. Go to the `logs` folder
3. Open the latest `catalina.YYYY-MM-DD.log` file
4. Look for any error messages or stack traces
5. **Check for the actual error that occurred**

### Step 3: Clear Tomcat Work Directory (Force JSP Recompilation)
The issue might be that Tomcat is using the old compiled version of deleteData.jsp.

**To fix this:**
1. Stop Tomcat server
2. Navigate to: `C:\Program Files\Apache Software Foundation\Tomcat X.X\work\Catalina\localhost\[your-app-name]\org\apache\jsp\`
3. Delete the files: `deleteData_jsp.java` and `deleteData_jsp.class`
4. Start Tomcat server again

### Step 4: Test with Debug Version
I've updated `deleteData.jsp` with enhanced debugging. When you try to delete now, you'll get more detailed error information including:
- The exact SQL being executed
- The parameters being passed
- The specific error type and message

### Step 5: Verify Database Column Types
Run this SQL query in your MySQL database to verify the column types:

```sql
DESCRIBE students;
DESCRIBE candidates;
```

Make sure the `year` column is of type `INT` or `TINYINT`, not `VARCHAR`.

### Step 6: Manual Test
Try running this SQL directly in MySQL to see if it works:

```sql
-- Test deletion with year filter
DELETE FROM students WHERE year = 1;
DELETE FROM candidates WHERE year = 1;
```

If this works, the issue is in the JSP code. If it doesn't work, the issue is in the database schema.

## Common Issues and Solutions

### Issue 1: Year column is still VARCHAR
**Solution:** Change the column type to INT:
```sql
ALTER TABLE students MODIFY COLUMN year INT;
ALTER TABLE candidates MODIFY COLUMN year INT;
```

### Issue 2: Tomcat hasn't reloaded the JSP
**Solution:** Clear Tomcat work directory (see Step 3 above)

### Issue 3: Database connection issue
**Solution:** Check if MySQL is running and the credentials in deleteData.jsp are correct

### Issue 4: Foreign key constraints
**Solution:** Check if there are any foreign key constraints preventing deletion

## What to Do Next

1. **First**, try clearing the Tomcat work directory and restarting Tomcat
2. **Then**, try the delete operation again
3. **Check** the browser console (F12) for the detailed error message
4. **Share** the error message you see so I can provide a more specific fix

## Quick Fix Commands

If you need to quickly clear Tomcat cache and restart:

```batch
REM Stop Tomcat
net stop Tomcat9

REM Clear work directory (adjust path to your Tomcat installation)
del /S /Q "C:\Program Files\Apache Software Foundation\Tomcat 9.0\work\Catalina\localhost\*"

REM Start Tomcat
net start Tomcat9
```

---

**Note:** The updated deleteData.jsp now includes detailed debugging information. When you try to delete data, check the browser console to see the full error response including SQL queries and parameters being used.
