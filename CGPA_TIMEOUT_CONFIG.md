# CGPA Fetch Timeout Configuration

## Current Settings

### getCGPA.jsp Timeouts:
- **Connection Timeout**: 10 seconds (time to establish connection to Flask API)
- **Read Timeout**: 5 minutes (300 seconds) - time to wait for Flask response

### Why 5 Minutes?
The Flask API takes **2-3 minutes per candidate** because it:
1. Logs into ERP system (erp.silicon.ac.in)
2. Navigates to results page
3. Downloads PDF file for the student
4. Extracts CGPA from the last page of PDF
5. Returns the result

For **multiple tied candidates**, the total time is:
- 2 candidates: 4-6 minutes
- 3 candidates: 6-9 minutes
- 4 candidates: 8-12 minutes

## User Experience Improvements

### Progress Indicator:
The system now shows:
```
⏳ Fetching CGPA Data...
Processing 1 of 3
Current: John Doe (SITBBS12345678)
⚠️ This may take 2-3 minutes per candidate
(Downloading and parsing result PDFs from ERP)
```

This updates for each candidate being processed.

## Adjusting Timeouts (if needed)

### If Flask API is slower (>5 minutes):
Edit `getCGPA.jsp` line 21:
```java
conn.setReadTimeout(600000); // 10 minutes
```

### If Flask API is faster (<2 minutes):
Edit `getCGPA.jsp` line 21:
```java
conn.setReadTimeout(180000); // 3 minutes
```

## Optimization Ideas (Future)

### 1. Parallel Fetching (Fastest - Recommended)
Instead of fetching one-by-one, fetch all CGPAs in parallel:

**Pros:**
- 3 candidates = 2-3 minutes total (instead of 6-9 minutes)
- Much better user experience

**Cons:**
- Multiple simultaneous Chrome instances
- Higher server load

**Implementation:**
Modify Flask API to handle multiple requests simultaneously.

### 2. Pre-fetch CGPA on Candidate Registration
Fetch and cache CGPA when candidate registers:

**Pros:**
- Instant tie-breaking
- No waiting during results

**Cons:**
- CGPA might change if student has new results
- Requires database storage (you said no storage)

### 3. Background Processing
Start CGPA fetch in background, show results when ready:

**Pros:**
- Non-blocking UI
- User can do other things while waiting

**Cons:**
- More complex implementation
- User might navigate away

## Current Flow Timeline

### Example: 3 Tied Candidates

```
00:00 - User clicks "DECLARE RESULTS"
00:01 - Tie detected, modal opens
00:02 - Start fetching Candidate 1 CGPA
        [Progress: Processing 1 of 3]
02:30 - Candidate 1 CGPA received (8.75)
02:31 - Start fetching Candidate 2 CGPA
        [Progress: Processing 2 of 3]
05:00 - Candidate 2 CGPA received (8.45)
05:01 - Start fetching Candidate 3 CGPA
        [Progress: Processing 3 of 3]
07:30 - Candidate 3 CGPA received (8.90)
07:31 - Display results:
        • Candidate 3: 8.90 ✓ Winner 👑
        • Candidate 1: 8.75 ✓ Eligible
        • Candidate 2: 8.45 ✗ Ineligible
07:32 - User clicks "CONTINUE TO CERTIFICATE"
07:37 - Certificate displayed (after 5s countdown)
```

**Total Time: ~7.5 minutes for 3 candidates**

## Troubleshooting

### "Request timeout" error still appearing:
1. Check Flask API logs - is it actually taking longer than 5 minutes?
2. Increase timeout in `getCGPA.jsp`
3. Check if ERP system is slow/down

### Flask API is too slow:
1. Check internet connection speed
2. Check if ERP system is under heavy load
3. Consider running Flask on a faster machine
4. Optimize PDF parsing (use faster PDF library)

### Browser timeout (different from server timeout):
Browsers also have timeouts. If the page shows "Connection timed out":
- This is usually 2-5 minutes in most browsers
- User needs to wait patiently
- Consider implementing progress bar with estimated time

## Recommended: Parallel Fetching Implementation

To reduce wait time from 6-9 minutes to 2-3 minutes for 3 candidates:

### Modify Flask API (app.py):
```python
# Add threading support
from concurrent.futures import ThreadPoolExecutor

@app.route('/download_batch', methods=["POST"])
def download_batch_handler():
    data = request.get_json()
    sics = data.get("sics", [])  # Array of SICs
    
    with ThreadPoolExecutor(max_workers=3) as executor:
        results = list(executor.map(download_and_extract_cgpa, sics))
    
    return jsonify({"results": results}), 200
```

### Modify getCGPA.jsp:
Accept array of SICs, call `/download_batch` endpoint

### Modify script.js:
Send all SICs at once instead of one-by-one

**Result:** 3 candidates processed in parallel = ~3 minutes total instead of 9 minutes!

---

**Last Updated**: 2025-11-25
**Current Timeout**: 5 minutes (300 seconds)
