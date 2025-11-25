# Delete Data Feature Implementation

## Overview
A comprehensive delete data feature has been added to the admin panel that allows selective or complete deletion of students and candidates from the database.

## Features Implemented

### 1. **Delete Data Button**
- Location: Admin page top navigation bar, positioned right after the RESET button
- Styling: Red border and text (`#ff4757`) to indicate destructive action
- Hover Effect: Same as RESET button - red background with glow effect

### 2. **Three-Step Modal Process**

#### Step 1: Filter Selection
- **Branch Dropdown**: Optional filter to select specific branch
- **Section Dropdown**: Optional filter to select specific section (A-J)
- **Year Dropdown**: Optional filter to select specific year (1-4)
- **Important Note Section**: Clearly explains that:
  - If NO filters are selected → ENTIRE database will be cleared
  - If ANY filters are selected → Only matching records will be deleted

#### Step 2: Warning Confirmation
- Displays dynamic warning message based on selected filters
- Shows exactly what will be deleted:
  - "ALL students and candidates from the entire database" (if no filters)
  - "students and candidates matching: Branch: X, Section: Y, Year: Z" (if filtered)
- Critical warning that action cannot be undone
- "I UNDERSTAND, PROCEED" button to continue

#### Step 3: Text Confirmation
- User must type exact phrase: `I want to delete the data and I know this cannot be undone`
- Real-time validation with error message if phrase doesn't match
- Two buttons:
  - **CANCEL**: Closes modal and cancels operation
  - **DELETE DATA**: Executes deletion (only works if phrase is correct)

### 3. **Backend Implementation** (`deleteData.jsp`)

#### Features:
- **Transaction Support**: Uses database transactions to ensure data integrity
- **Selective Deletion**: Supports filtering by branch, section, and year
- **Complete Deletion**: Deletes all records when no filters are provided
- **Dual Table Deletion**: Deletes from both `students` and `candidates` tables
- **Response Details**: Returns count of deleted students and candidates

#### SQL Logic:
```sql
-- If filters are provided:
DELETE FROM students WHERE branch = ? AND section = ? AND year = ?
DELETE FROM candidates WHERE branch = ? AND section = ? AND year = ?

-- If no filters (delete all):
DELETE FROM students
DELETE FROM candidates
```

#### Response Format:
```json
{
  "success": true/false,
  "message": "Deleted X student(s) and Y candidate(s)...",
  "studentsDeleted": X,
  "candidatesDeleted": Y
}
```

### 4. **JavaScript Functions** (in `script.js`)

- `openDeleteDataModal()`: Opens modal and resets all states
- `closeDeleteDataModal()`: Closes modal and cleans up
- `showDeleteWarning()`: Builds dynamic warning message based on filters
- `showDeleteTextInput()`: Shows final confirmation step
- `executeDelete()`: Validates phrase and sends delete request to backend

## User Flow

1. Admin clicks "DELETE DATA" button
2. Modal opens showing three filter dropdowns
3. Admin selects filters (optional) or leaves empty for full deletion
4. Admin reads the important note and clicks "NEXT"
5. Warning screen shows exactly what will be deleted
6. Admin clicks "I UNDERSTAND, PROCEED"
7. Text input screen appears
8. Admin types: "I want to delete the data and I know this cannot be undone"
9. Admin clicks "DELETE DATA"
10. Backend processes deletion
11. Success message shows count of deleted records
12. Page reloads to reflect changes

## Design Consistency

### Styling Matches Existing Modals:
- Same modal structure as RESET and PROMOTE modals
- Consistent color scheme:
  - Red (`#ff4757`) for destructive actions
  - Green (`#8ab452`) for confirmation text
  - Dark background with tech-style clip-path borders
- Same font families (Orbitron for titles, Rajdhani for body)
- Consistent button hover effects

### Button Hover Effect:
The DELETE DATA button uses the `.btn-small` class with custom red styling:
- Default: Red border and text (`border-color: #ff4757; color: #ff4757`)
- Hover: Red background glow (`background: rgba(255, 71, 87, 0.1)`)
- Same effect as RESET button hover

## Safety Features

1. **Three-step confirmation** prevents accidental deletion
2. **Clear warning messages** explain exactly what will be deleted
3. **Text phrase validation** ensures user reads and understands
4. **Transaction support** ensures database integrity
5. **Detailed feedback** shows exactly what was deleted
6. **Page reload** after deletion to show updated state

## Files Modified/Created

### Modified:
1. `admin.html` - Added Delete Data modal HTML
2. `script.js` - Added delete data JavaScript functions

### Created:
1. `deleteData.jsp` - Backend deletion handler

## Testing Checklist

- [ ] Button appears in correct position (after RESET button)
- [ ] Button has red styling and correct hover effect
- [ ] Modal opens when button is clicked
- [ ] All three dropdowns work correctly
- [ ] Important note is clearly visible
- [ ] Warning message updates based on filter selection
- [ ] Text validation works (accepts correct phrase, rejects incorrect)
- [ ] Cancel button closes modal without deleting
- [ ] Delete button only works after correct phrase is entered
- [ ] Backend correctly deletes filtered records
- [ ] Backend correctly deletes all records when no filters
- [ ] Success message shows correct counts
- [ ] Page reloads after successful deletion
- [ ] Error handling works for database errors

## Database Impact

### Tables Affected:
- `students` - Student records deleted based on filters
- `candidates` - Candidate records deleted based on filters

### Columns Used for Filtering:
- `branch` - VARCHAR
- `section` - VARCHAR
- `year` - INT

## Notes

- This feature is designed to complement the RESET feature
- RESET: Clears votes and candidates but keeps students
- DELETE: Removes actual student and candidate records
- Both features use similar UI/UX patterns for consistency
- Both require multi-step confirmation for safety
