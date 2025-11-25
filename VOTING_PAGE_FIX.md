# ✅ FIXED: "Error deleting data" in Voting Page

## The Real Problem

The error message "Error deleting data. Please try again." was appearing in the **voting page** (not the admin page) when you clicked to view candidates by branch, section, and year.

### Root Cause
The error was coming from `getCandidates.jsp`, which is called when the voting page loads candidates. The file was using `setString()` for the `year` parameter, but the database `year` column is of type `INT`. This type mismatch caused the SQL query to fail.

The error message was misleading because it said "Error deleting data" when it was actually an error **loading** candidates data.

## What Was Fixed

### File: `getCandidates.jsp`

**Before (Line ~42):**
```java
if (year != null && !year.trim().isEmpty()) {
    pstmt.setString(paramIndex++, year);  // ❌ WRONG - year is INT in database
}
```

**After:**
```java
if (year != null && !year.trim().isEmpty()) {
    pstmt.setInt(paramIndex++, Integer.parseInt(year));  // ✅ CORRECT
}
```

Also changed:
- `rs.getString("year")` → `rs.getInt("year")` when reading from database
- JSON output for year changed from string to number

## Files That Were Fixed

1. ✅ **`deleteData.jsp`** - Fixed year parameter handling for delete operations
2. ✅ **`getCandidates.jsp`** - Fixed year parameter handling for loading candidates (THIS WAS THE VOTING PAGE ISSUE)

## How to Test

### Step 1: Restart Tomcat
**IMPORTANT:** You MUST restart Tomcat for the changes to take effect!

1. Right-click `restart_tomcat.bat` → Run as administrator
   OR
2. Restart Tomcat manually through Services

### Step 2: Test the Voting Page
1. Go to `http://localhost:8080/CR_Election/studentAuth.html`
2. Login with a student SIC
3. The voting page should now load candidates correctly
4. You should see candidates filtered by your branch, section, and year
5. No more "Error deleting data" message!

### Step 3: Test the Admin Delete (Bonus)
1. Go to `http://localhost:8080/CR_Election/admin.html`
2. Click the DELETE button
3. Select filters (branch, section, year)
4. The delete operation should also work now

## Why This Happened

The database schema has the `year` column as `INT`:
```sql
year INT NOT NULL
```

But the JSP files were treating it as a string:
```java
pstmt.setString(paramIndex++, year);  // ❌ Type mismatch!
```

This caused SQL errors whenever the year filter was used.

## Summary

- ✅ Fixed `getCandidates.jsp` (voting page candidate loading)
- ✅ Fixed `deleteData.jsp` (admin delete functionality)
- ✅ Both files now correctly use `setInt()` for year parameters
- ✅ Error message will no longer appear in voting page

**Action Required:** Restart Tomcat and test!

---

**Note:** The confusing error message "Error deleting data" was actually coming from the generic error handler in the JSP. The actual issue was with loading/querying data, not deleting it.
