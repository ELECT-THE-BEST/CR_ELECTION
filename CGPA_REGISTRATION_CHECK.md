# CGPA Eligibility Check at Registration

## Overview
CGPA eligibility check has been moved from the results phase to the candidate registration phase. Now, candidates with CGPA < 8.5 cannot be registered at all.

## How It Works

### User Flow:

```
Admin clicks "+ ADD NEW" button
    ↓
Modal opens with candidate form
    ↓
Admin enters SIC
    ↓
System auto-fetches student details (name, branch, year, section, photo)
    ↓
"CHECK ELIGIBILITY" button becomes enabled (dark/clickable)
    ↓
Admin clicks "CHECK ELIGIBILITY"
    ↓
System fetches CGPA from ERP (2-3 minutes)
    ↓
┌─────────────────────┴─────────────────────┐
↓                                           ↓
CGPA >= 8.5                            CGPA < 8.5
✅ ELIGIBLE                            ❌ NOT ELIGIBLE
    ↓                                           ↓
Green success message                  Red error message
"Meets minimum requirement"            "Cannot be registered"
    ↓                                           ↓
Admin fills motivation                 Admin CANNOT proceed
    ↓                                   (Submit button blocked)
Admin clicks "SUBMIT CANDIDATE"
    ↓
System checks eligibility again
    ↓
If eligible → Candidate registered
If not → Error message shown
```

## UI Elements

### 1. **CHECK ELIGIBILITY Button**
- **Initial State**: Disabled (grayed out, opacity 0.5)
- **After SIC entered**: Enabled (bright, clickable)
- **While checking**: Shows "⏳ CHECKING... (2-3 minutes)"
- **After check**:
  - ✅ ELIGIBLE (green background)
  - ❌ NOT ELIGIBLE (red background)
  - ⚠️ CGPA NOT FOUND (yellow background)
  - ❌ ERROR - RETRY (red background, clickable)

### 2. **CGPA Display Area**
Shows one of these messages:

#### **✅ Eligible (CGPA >= 8.5)**
```
┌─────────────────────────────────────┐
│  ✅ ELIGIBLE FOR CR POSITION        │
│                                     │
│  CGPA: 8.75                         │
│  ✓ Meets minimum requirement of 8.5│
└─────────────────────────────────────┘
```

#### **❌ Not Eligible (CGPA < 8.5)**
```
┌─────────────────────────────────────┐
│  ❌ NOT ELIGIBLE FOR CR POSITION    │
│                                     │
│  CGPA: 7.85                         │
│  ✗ Below minimum requirement of 8.5│
│  This student cannot be registered  │
└─────────────────────────────────────┘
```

#### **⚠️ CGPA Not Found**
```
┌─────────────────────────────────────┐
│  ⚠️ CGPA NOT FOUND                  │
│  Could not retrieve CGPA from ERP   │
│                                     │
│  Possible reasons:                  │
│  • Student has no results in ERP    │
│  • SIC is incorrect                 │
│  • ERP system is down               │
│                                     │
│  Cannot proceed without verification│
└─────────────────────────────────────┘
```

## Validation Rules

### Before Submission:
1. ✅ SIC must be entered
2. ✅ Student data must be fetched
3. ✅ **CGPA eligibility must be checked and passed**
4. ✅ Motivation must be filled

### If User Tries to Submit Without Checking:
```
⚠️ CGPA Eligibility Check Required!

You must click 'CHECK ELIGIBILITY' button and verify 
that the candidate has CGPA >= 8.5 before proceeding.

Only eligible candidates can be registered.
```

## Benefits

### ✅ **Prevents Ineligible Candidates**
- No more discovering ineligibility during results
- Saves time during tie-breaking
- Ensures only qualified candidates participate

### ✅ **Clear Feedback**
- Admin knows immediately if student is eligible
- Visual indicators (green/red) make it obvious
- Detailed error messages help troubleshoot

### ✅ **Enforced Requirement**
- Cannot bypass the check
- Submit button validates eligibility
- Database only contains eligible candidates

## Technical Implementation

### Files Modified:

1. **admin.html**
   - Added CGPA Eligibility Check section
   - Added "CHECK ELIGIBILITY" button
   - Added CGPA display area
   - Added hidden `isEligible` field

2. **script.js**
   - Added `checkCGPAEligibility()` function
   - Added `resetEligibilityCheck()` function
   - Modified `fetchStudentData()` to enable button
   - Modified `clearCandidateForm()` to reset eligibility
   - Modified `handleCandidateSubmit()` to validate eligibility

### Key Functions:

#### `checkCGPAEligibility()`
- Fetches CGPA from `getCGPA.jsp`
- Validates CGPA >= 8.5
- Updates UI with result
- Sets `isEligible` hidden field

#### `resetEligibilityCheck()`
- Resets button to disabled state
- Hides CGPA display area
- Sets `isEligible` to "false"

#### `handleCandidateSubmit()`
- Checks if `isEligible === "true"`
- Blocks submission if not eligible
- Shows error message if check not done

## Testing Scenarios

### Test 1: Eligible Candidate (CGPA >= 8.5)
1. Enter SIC of student with CGPA >= 8.5
2. Click "CHECK ELIGIBILITY"
3. Wait 2-3 minutes
4. Should show green "✅ ELIGIBLE" message
5. Fill motivation
6. Click "SUBMIT CANDIDATE"
7. Should successfully register

### Test 2: Ineligible Candidate (CGPA < 8.5)
1. Enter SIC of student with CGPA < 8.5
2. Click "CHECK ELIGIBILITY"
3. Wait 2-3 minutes
4. Should show red "❌ NOT ELIGIBLE" message
5. Try to click "SUBMIT CANDIDATE"
6. Should show error: "CGPA Eligibility Check Required!"
7. Cannot proceed

### Test 3: CGPA Not Found
1. Enter SIC of student with no ERP results
2. Click "CHECK ELIGIBILITY"
3. Wait 2-3 minutes
4. Should show yellow "⚠️ CGPA NOT FOUND" message
5. Try to click "SUBMIT CANDIDATE"
6. Should show error: "CGPA Eligibility Check Required!"
7. Cannot proceed

### Test 4: Skip Eligibility Check
1. Enter SIC
2. Fill motivation
3. Try to click "SUBMIT CANDIDATE" without checking eligibility
4. Should show error: "CGPA Eligibility Check Required!"
5. Cannot proceed

### Test 5: Change SIC After Check
1. Enter SIC, check eligibility (pass)
2. Change SIC to different student
3. Eligibility should reset
4. Button should become enabled again
5. Must re-check for new student

## Troubleshooting

### Button Stays Disabled
**Cause**: Student data not fetched  
**Solution**: Enter valid SIC and wait for auto-fetch

### "CGPA NOT FOUND" Error
**Cause**: Student has no results in ERP  
**Solution**: Verify SIC is correct, check if student has completed exams

### "Request timeout" Error
**Cause**: Flask API taking too long  
**Solution**: Ensure Flask API is running, check timeout settings

### Can't Submit Even After Passing
**Cause**: Hidden field not updated  
**Solution**: Check browser console, refresh page and try again

## Comparison: Before vs After

### Before (Eligibility Check at Results):
```
Register Candidate → Vote → Tie → Fetch CGPA → Discover Ineligible → Wasted Time
```

### After (Eligibility Check at Registration):
```
Enter SIC → Check CGPA → If Ineligible: STOP
                      → If Eligible: Register → Vote → Tie → Auto-resolve
```

## Future Enhancements

1. **Cache CGPA**: Store CGPA temporarily to avoid re-fetching
2. **Batch Check**: Check multiple candidates at once
3. **Manual Override**: Allow admin to override in special cases
4. **CGPA History**: Log all eligibility checks for audit

---

**Last Updated**: 2025-11-25  
**Minimum CGPA**: 8.5  
**Check Required**: Yes (Mandatory)
