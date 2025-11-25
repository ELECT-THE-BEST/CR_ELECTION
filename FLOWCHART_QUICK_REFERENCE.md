# 🎯 CR ELECTION SYSTEM - FLOWCHART QUICK REFERENCE

## 📂 Files Created

| File | Purpose | How to Use |
|------|---------|------------|
| `UPDATED_FLOWCHART.md` | Mermaid source code | Copy to mermaid.live or GitHub |
| `updated_flowchart.html` | Interactive viewer | Open in any browser |
| `FLOWCHART_DOCUMENTATION.md` | Complete guide | Read for detailed info |

## 🎨 Visual Design

### Theme Colors
- **Background**: `#0a0e12` (Dark)
- **Panels**: `#1a1e24` (Slightly lighter)
- **Primary**: `#8ab452` (Green - matches your project)
- **Text**: `#ffffff` (White)

### Component Colors
| Component | Color | Stroke |
|-----------|-------|--------|
| 🏠 Landing | Dark Gray | Green |
| 🎓 Student | Dark | Blue |
| ⚙️ Admin | Dark | Red |
| ❓ Decision | Dark Yellow | Gold |
| ❌ Error | Dark Red | Red |
| ✅ Success | Dark Green | Green |
| 🗄️ Database | Dark Orange | Orange (dashed) |

## 🆕 New Features Included

### 1. Statistics System
- **Files**: `getStats.jsp`
- **Shows**: Total Students, Candidates, Sections, Participation %
- **Location**: Landing page + Admin dashboard

### 2. Import System
- **Files**: `upload.jsp`
- **Supports**: .xlsx, .xls, .csv
- **Validates**: 9 columns, year as integer (1-4)
- **Location**: Admin → Import Data tab

### 3. Delete System
- **Files**: `deleteData.jsp`
- **Features**: Optional filters, type "DELETE" confirmation
- **Deletes**: Students + Candidates
- **Location**: Admin → Delete Data tab

### 4. Promotion System
- **Files**: `promoteStudents.jsp`
- **Action**: Increments year by 1
- **Features**: Optional filters, irreversible warning
- **Location**: Admin → Promote tab

### 5. Session Management
- **Files**: `getStudentData.jsp`
- **Purpose**: Retrieve student session data
- **Location**: Voting page

## 🔄 Complete User Flows

### Student Journey
```
1. Visit index.html
2. Click "START VOTING"
3. Enter SIC in studentAuth.html
4. System checks: Student exists? Already voted?
5. If valid → Create session → voting.html
6. Load student data + filtered candidates
7. Click VOTE → Confirm
8. System validates match → Updates DB
9. Show success → Disable buttons
```

### Admin Journey
```
1. Visit index.html
2. Click "ADMIN"
3. Enter ID (2323) & Key (1234)
4. If valid → admin.html
5. View statistics
6. Select tab:
   - Candidates: Add/Edit/Delete
   - Import: Upload Excel/CSV
   - Results: View winner
   - Promote: Advance students
   - Delete: Remove data
   - Reset: Clear votes
```

## 📊 Database Operations

### Read Operations
- `getStats.jsp` → Count students, candidates, sections
- `getCandidates.jsp` → Fetch candidates with filters
- `getStudentBySic.jsp` → Fetch student by SIC
- `getStudentData.jsp` → Get session data
- `getWinner.jsp` → Calculate election winner

### Write Operations
- `authenticateStudent.jsp` → Create session
- `castVote.jsp` → Increment votes + mark voted
- `registerCandidate.jsp` → Add candidate
- `updateCandidateMotivation.jsp` → Update motivation
- `deleteCandidate.jsp` → Remove candidate
- `upload.jsp` → Batch insert students
- `promoteStudents.jsp` → Increment year
- `deleteData.jsp` → Delete students/candidates
- `resetDatabase.jsp` → Reset votes + clear candidates

## 🎮 Interactive Features (HTML Version)

### Controls
- **Zoom In**: Click button or scroll up
- **Zoom Out**: Click button or scroll down
- **Reset**: Click reset button
- **Download**: Save as SVG
- **Pan**: Click and drag

### Legend
- 8 color-coded component types
- Clear visual indicators
- Matches project theme

## 📱 Viewing Options

### Best for Presentations
→ Open `updated_flowchart.html` in browser

### Best for Documentation
→ Export SVG from HTML version

### Best for Editing
→ Use `UPDATED_FLOWCHART.md` in mermaid.live

### Best for GitHub
→ Push `.md` file (auto-renders)

## 🔍 Key Differences from Original

### Added:
✅ Statistics dashboard  
✅ Excel/CSV import  
✅ Delete data feature  
✅ Promote students  
✅ Session management  
✅ Enhanced error handling  
✅ Transaction support  
✅ Before/after confirmations  

### Updated:
🔄 Year field (VARCHAR → INT)  
🔄 Better validation flows  
🔄 More detailed processes  
🔄 Improved visual design  

## 🎯 Quick Tips

1. **Open HTML file** for best experience
2. **Use zoom** to focus on specific sections
3. **Follow color coding** to understand component types
4. **Check legend** if unsure about colors
5. **Download SVG** for presentations

## 📞 Support

If you need to modify the flowchart:
1. Edit `UPDATED_FLOWCHART.md`
2. Test at https://mermaid.live/
3. Update HTML file if needed

---

**Quick Start**: Just open `updated_flowchart.html` in your browser! 🚀
