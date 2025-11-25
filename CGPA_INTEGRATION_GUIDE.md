# CGPA Integration Guide

## Overview
This document explains the CGPA-based candidate eligibility and automatic tie-breaking system implemented for the CR Election platform.

## Features Implemented

### 1. **Automatic CGPA Fetching**
When there's a tie in voting results, the system automatically:
- Fetches CGPA data from the ERP system via the Flask API
- Displays loading state while retrieving data
- Shows CGPA for all tied candidates

### 2. **CGPA Eligibility Check (>= 8.5)**
- Candidates with CGPA < 8.5 are marked as **INELIGIBLE**
- Only candidates with CGPA >= 8.5 can be selected as CR
- Ineligible candidates are clearly highlighted in red

### 3. **Automatic Winner Determination**
When all CGPAs are successfully fetched:
- System automatically identifies the candidate with highest CGPA
- If there's a clear winner (highest CGPA among eligible candidates):
  - Displays winner announcement with crown emoji 👑
  - Shows all candidates with their CGPA and eligibility status
  - Provides "CONTINUE TO CERTIFICATE" button
  - Automatically proceeds to certificate display with countdown

### 4. **Tie Handling**
If multiple candidates have the same highest CGPA:
- System displays warning about persisting tie
- Shows all candidates with their CGPA
- Requires manual selection (future enhancement)

### 5. **Fallback for CGPA Fetch Errors**
If CGPA cannot be automatically fetched for some candidates:
- Displays error messages
- Allows manual CGPA entry
- Requires verification checkbox before proceeding

## Files Created/Modified

### New Files:
1. **`getCGPA.jsp`** - JSP endpoint that calls Flask API to fetch CGPA
   - Accepts SIC parameter
   - Calls Flask service on `http://localhost:5000/download`
   - Returns JSON with CGPA value

### Modified Files:
1. **`script.js`** - Updated tie-breaking logic
   - `showTieBreakModal()` - Now async, automatically fetches CGPA
   - Implements eligibility checking
   - Automatic winner determination
   - Enhanced UI with status indicators

## How It Works

### Flow Diagram:
```
User clicks "RESULTS" → Selects Branch/Section/Year → Clicks "DECLARE RESULTS"
                                    ↓
                        getWinner.jsp checks for ties
                                    ↓
                    ┌───────────────┴───────────────┐
                    ↓                               ↓
              No Tie Found                    Tie Detected
                    ↓                               ↓
         Show Certificate                 showTieBreakModal()
            Directly                              ↓
                                    Fetch CGPA for all tied candidates
                                                  ↓
                                    ┌─────────────┴─────────────┐
                                    ↓                           ↓
                            All CGPAs Fetched          Some CGPAs Failed
                                    ↓                           ↓
                        Check Eligibility (>= 8.5)    Show Manual Entry
                                    ↓
                        ┌───────────┴───────────┐
                        ↓                       ↓
                No Eligible Candidates    Has Eligible Candidates
                        ↓                       ↓
                Show Error Message      Sort by CGPA Descending
                                               ↓
                                    ┌──────────┴──────────┐
                                    ↓                     ↓
                            Single Winner          Multiple with Same CGPA
                                    ↓                     ↓
                        Show Winner + Continue    Show Tie Warning
                                    ↓
                        User Clicks Continue
                                    ↓
                        Certificate with Countdown
```

## Prerequisites

### 1. Flask API Must Be Running
```bash
cd "Download or View CGPA"
python app.py
```
The Flask API should be running on `http://localhost:5000`

### 2. ERP Credentials
Ensure `.env` file exists in `Download or View CGPA` folder:
```
ERP_USERNAME=your_username
ERP_PASSWORD=your_password
```

### 3. JSON Library for JSP
Ensure `json-java.jar` is in `WEB-INF/lib/` directory

## Testing the Feature

### Test Scenario 1: Clear Winner
1. Create a tie (2+ candidates with same votes)
2. Ensure one candidate has CGPA > 8.5 and higher than others
3. Click "RESULTS" → Select filters → "DECLARE RESULTS"
4. System should automatically show winner with highest CGPA
5. Click "CONTINUE TO CERTIFICATE"

### Test Scenario 2: Ineligible Candidates
1. Create a tie where some candidates have CGPA < 8.5
2. System should mark them as ineligible (red)
3. Winner should be selected from eligible candidates only

### Test Scenario 3: All Ineligible
1. Create a tie where all candidates have CGPA < 8.5
2. System should show "NO ELIGIBLE CANDIDATES" error

### Test Scenario 4: CGPA Fetch Error
1. Stop Flask API
2. Create a tie
3. System should show error and allow manual entry

## UI Indicators

### Colors:
- **Green (#8ab452)**: Eligible candidate, Winner
- **Red (#ff4757)**: Ineligible candidate (CGPA < 8.5)
- **Yellow (#ffc107)**: Tie persists warning
- **Gray**: Loading/neutral state

### Icons:
- 👑 - Winner
- ✓ - Eligible
- ✗ - Ineligible
- ⏳ - Loading
- ⚠️ - Warning
- ❌ - Error

## Important Notes

1. **CGPA is NOT stored in database** - It's fetched in real-time during tie-breaking
2. **Flask API must be running** - Otherwise manual entry is required
3. **Minimum CGPA requirement: 8.5** - This is hardcoded in `script.js`
4. **SIC format**: System removes "SITBBS" prefix before calling Flask API
5. **Countdown**: After winner determination, 5-second countdown before certificate

## Customization

### Change Minimum CGPA Requirement:
In `script.js`, line ~775:
```javascript
const eligibleCandidates = candidatesWithCGPA.filter(c => c.cgpa >= 8.5);
```
Change `8.5` to your desired threshold.

### Change Flask API URL:
In `getCGPA.jsp`, line ~18:
```java
String flaskUrl = "http://localhost:5000/download";
```

### Change Countdown Duration:
In `script.js`, `showCertificate()` function:
```javascript
let count = 5; // Change this value
```

## Troubleshooting

### Issue: "CGPA not found in ERP"
**Solution**: 
- Verify SIC is correct
- Check if student has results in ERP
- Ensure Flask API is running
- Check ERP credentials in `.env`

### Issue: "Failed to fetch CGPA from ERP"
**Solution**:
- Start Flask API: `python app.py`
- Check Flask console for errors
- Verify network connectivity

### Issue: JSON parsing error
**Solution**:
- Ensure `json-java.jar` is in `WEB-INF/lib/`
- Restart Tomcat server

### Issue: Certificate not showing
**Solution**:
- Check browser console (F12) for JavaScript errors
- Verify `certificateOverlay` element exists in HTML
- Check if `tiedCandidatesData` is populated

## Future Enhancements

1. **Cache CGPA data** - Store fetched CGPA temporarily to avoid repeated API calls
2. **Batch CGPA fetch** - Fetch all CGPAs in parallel instead of sequentially
3. **Admin CGPA override** - Allow admin to manually set CGPA if API fails
4. **CGPA history** - Log CGPA values used in tie-breaking for audit purposes
5. **Multiple tie-breaking criteria** - Add attendance, previous CR experience, etc.

## Support

For issues or questions:
1. Check browser console (F12) for JavaScript errors
2. Check Flask API console for backend errors
3. Check Tomcat logs for JSP errors
4. Verify all prerequisites are met

---

**Last Updated**: 2025-11-25
**Version**: 1.0
