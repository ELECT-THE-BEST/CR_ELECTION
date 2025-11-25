<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test getWinner.jsp</title>
</head>
<body>
    <h1>Testing getWinner.jsp</h1>
    
    <h2>Test 1: Database Connection</h2>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
        out.println("<p style='color: green;'>✓ Database connection successful!</p>");
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color: red;'>✗ Database connection failed: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
    %>
    
    <h2>Test 2: Check Candidates Table</h2>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
        
        String sql = "SELECT COUNT(*) as count FROM candidates";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int count = rs.getInt("count");
            out.println("<p style='color: green;'>✓ Candidates table exists. Total candidates: " + count + "</p>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color: red;'>✗ Error querying candidates: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
    %>
    
    <h2>Test 3: Sample Query (CSE, A, 2)</h2>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
        
        String sql = "SELECT c.id, c.sic, c.votes, s.name, s.branch, s.section, s.year " +
                     "FROM candidates c " +
                     "JOIN students s ON c.sic = s.sic " +
                     "WHERE s.branch = ? AND s.section = ? AND s.year = ? " +
                     "ORDER BY c.votes DESC";
        
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "CSE");
        pstmt.setString(2, "A");
        pstmt.setString(3, "2");
        
        ResultSet rs = pstmt.executeQuery();
        
        out.println("<table border='1' style='border-collapse: collapse;'>");
        out.println("<tr><th>SIC</th><th>Name</th><th>Branch</th><th>Section</th><th>Year</th><th>Votes</th></tr>");
        
        int count = 0;
        while (rs.next()) {
            count++;
            out.println("<tr>");
            out.println("<td>" + rs.getString("sic") + "</td>");
            out.println("<td>" + rs.getString("name") + "</td>");
            out.println("<td>" + rs.getString("branch") + "</td>");
            out.println("<td>" + rs.getString("section") + "</td>");
            out.println("<td>" + rs.getString("year") + "</td>");
            out.println("<td>" + rs.getInt("votes") + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
        
        if (count == 0) {
            out.println("<p style='color: orange;'>⚠ No candidates found for CSE, Section A, Year 2</p>");
        } else {
            out.println("<p style='color: green;'>✓ Found " + count + " candidate(s)</p>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color: red;'>✗ Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
    %>
    
    <h2>Test 4: Direct getWinner.jsp Call</h2>
    <p>Click the button below to test getWinner.jsp directly:</p>
    <button onclick="testGetWinner()">Test getWinner.jsp</button>
    <pre id="result"></pre>
    
    <script>
    async function testGetWinner() {
        try {
            const response = await fetch('getWinner.jsp?branch=CSE&section=A&year=2');
            const text = await response.text();
            document.getElementById('result').textContent = text;
            
            try {
                const json = JSON.parse(text);
                console.log('Parsed JSON:', json);
            } catch (e) {
                console.error('Failed to parse as JSON:', e);
            }
        } catch (error) {
            document.getElementById('result').textContent = 'Error: ' + error.message;
        }
    }
    </script>
</body>
</html>
