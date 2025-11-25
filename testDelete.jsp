<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Data Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #0a0e12;
            color: #fff;
        }
        .test-section {
            background: rgba(138, 180, 82, 0.1);
            border: 1px solid #8ab452;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .success { color: #8ab452; }
        .error { color: #ff4757; }
        pre {
            background: #000;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        button {
            background: #8ab452;
            color: #0a0e12;
            border: none;
            padding: 10px 20px;
            font-weight: bold;
            cursor: pointer;
            border-radius: 5px;
            margin: 5px;
        }
        button:hover {
            background: #9fc961;
        }
    </style>
</head>
<body>
    <h1>🔍 Delete Data Diagnostic Test</h1>
    
    <div class="test-section">
        <h2>Test 1: Database Connection</h2>
        <%
            String dbURL = "jdbc:mysql://localhost:3306/cr_election_db";
            String dbUser = "root";
            String dbPassword = "";
            Connection testConn = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                testConn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                out.println("<p class='success'>✓ Database connection successful!</p>");
            } catch (Exception e) {
                out.println("<p class='error'>✗ Database connection failed: " + e.getMessage() + "</p>");
            } finally {
                if (testConn != null) testConn.close();
            }
        %>
    </div>
    
    <div class="test-section">
        <h2>Test 2: Check Year Column Type</h2>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                testConn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                
                String sql = "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS " +
                            "WHERE TABLE_SCHEMA = 'cr_election_db' AND TABLE_NAME IN ('students', 'candidates') " +
                            "AND COLUMN_NAME = 'year'";
                
                Statement stmt = testConn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                
                out.println("<pre>");
                while (rs.next()) {
                    String colName = rs.getString("COLUMN_NAME");
                    String dataType = rs.getString("DATA_TYPE");
                    String colType = rs.getString("COLUMN_TYPE");
                    
                    out.println("Column: " + colName);
                    out.println("Data Type: " + dataType);
                    out.println("Column Type: " + colType);
                    out.println("---");
                    
                    if (!dataType.toLowerCase().contains("int")) {
                        out.println("<p class='error'>⚠️ WARNING: Year column is " + dataType + ", should be INT!</p>");
                    } else {
                        out.println("<p class='success'>✓ Year column type is correct (INT)</p>");
                    }
                }
                out.println("</pre>");
                
                rs.close();
                stmt.close();
            } catch (Exception e) {
                out.println("<p class='error'>✗ Error checking column type: " + e.getMessage() + "</p>");
            } finally {
                if (testConn != null) testConn.close();
            }
        %>
    </div>
    
    <div class="test-section">
        <h2>Test 3: Test DELETE Query (DRY RUN)</h2>
        <p>This will show what would be deleted without actually deleting:</p>
        <%
            String testBranch = request.getParameter("testBranch");
            String testSection = request.getParameter("testSection");
            String testYear = request.getParameter("testYear");
            
            if (testBranch != null || testSection != null || testYear != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    testConn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                    
                    StringBuilder whereClause = new StringBuilder();
                    boolean hasFilters = false;
                    
                    if (testBranch != null && !testBranch.trim().isEmpty()) {
                        whereClause.append("branch = ?");
                        hasFilters = true;
                    }
                    
                    if (testSection != null && !testSection.trim().isEmpty()) {
                        if (hasFilters) whereClause.append(" AND ");
                        whereClause.append("section = ?");
                        hasFilters = true;
                    }
                    
                    if (testYear != null && !testYear.trim().isEmpty()) {
                        if (hasFilters) whereClause.append(" AND ");
                        whereClause.append("year = ?");
                        hasFilters = true;
                    }
                    
                    String sql = "SELECT COUNT(*) as count FROM students" + (hasFilters ? " WHERE " + whereClause.toString() : "");
                    
                    out.println("<p><strong>SQL Query:</strong></p>");
                    out.println("<pre>" + sql + "</pre>");
                    
                    PreparedStatement pstmt = testConn.prepareStatement(sql);
                    
                    if (hasFilters) {
                        int paramIndex = 1;
                        if (testBranch != null && !testBranch.trim().isEmpty()) {
                            pstmt.setString(paramIndex++, testBranch);
                            out.println("<p>Parameter " + (paramIndex-1) + ": branch = '" + testBranch + "'</p>");
                        }
                        if (testSection != null && !testSection.trim().isEmpty()) {
                            pstmt.setString(paramIndex++, testSection);
                            out.println("<p>Parameter " + (paramIndex-1) + ": section = '" + testSection + "'</p>");
                        }
                        if (testYear != null && !testYear.trim().isEmpty()) {
                            try {
                                int yearInt = Integer.parseInt(testYear);
                                pstmt.setInt(paramIndex++, yearInt);
                                out.println("<p>Parameter " + (paramIndex-1) + ": year = " + yearInt + " (INT)</p>");
                            } catch (NumberFormatException nfe) {
                                out.println("<p class='error'>✗ Invalid year format: " + testYear + "</p>");
                                throw nfe;
                            }
                        }
                    }
                    
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        int count = rs.getInt("count");
                        out.println("<p class='success'>✓ Query executed successfully!</p>");
                        out.println("<p><strong>Students that would be deleted: " + count + "</strong></p>");
                    }
                    
                    rs.close();
                    pstmt.close();
                    
                } catch (Exception e) {
                    out.println("<p class='error'>✗ Error executing test query: " + e.getMessage() + "</p>");
                    out.println("<pre>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    out.println("</pre>");
                } finally {
                    if (testConn != null) testConn.close();
                }
            } else {
                out.println("<p>Use the form below to test a query:</p>");
            }
        %>
        
        <form method="GET" action="testDelete.jsp">
            <label>Branch: <input type="text" name="testBranch" placeholder="e.g., CSE"></label><br><br>
            <label>Section: <input type="text" name="testSection" placeholder="e.g., A"></label><br><br>
            <label>Year: <input type="text" name="testYear" placeholder="e.g., 1"></label><br><br>
            <button type="submit">Test Query</button>
        </form>
    </div>
    
    <div class="test-section">
        <h2>Quick Actions</h2>
        <a href="admin.html"><button>← Back to Admin</button></a>
        <button onclick="location.reload()">🔄 Refresh Tests</button>
    </div>
</body>
</html>
