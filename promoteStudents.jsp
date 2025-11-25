<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    String branch = request.getParameter("branch");
    String section = request.getParameter("section");
    String year = request.getParameter("year");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
        
        // Build the UPDATE SQL query - Simple increment since year is now INT
        StringBuilder sql = new StringBuilder();
        sql.append("UPDATE students SET year = year + 1 WHERE 1=1");
        
        // Add filters if provided
        if (branch != null && !branch.trim().isEmpty()) {
            sql.append(" AND branch = ?");
        }
        if (section != null && !section.trim().isEmpty()) {
            sql.append(" AND section = ?");
        }
        if (year != null && !year.trim().isEmpty()) {
            sql.append(" AND year = ?");
        }
        
        pstmt = conn.prepareStatement(sql.toString());
        
        // Set parameters
        int paramIndex = 1;
        if (branch != null && !branch.trim().isEmpty()) {
            pstmt.setString(paramIndex++, branch);
        }
        if (section != null && !section.trim().isEmpty()) {
            pstmt.setString(paramIndex++, section);
        }
        if (year != null && !year.trim().isEmpty()) {
            pstmt.setInt(paramIndex++, Integer.parseInt(year));
        }
        
        int studentsPromoted = pstmt.executeUpdate();
        
        // Build success message
        String message = studentsPromoted + " student(s) promoted successfully!";
        if (branch != null && !branch.trim().isEmpty()) {
            message += "\\nBranch: " + branch;
        }
        if (section != null && !section.trim().isEmpty()) {
            message += "\\nSection: " + section;
        }
        if (year != null && !year.trim().isEmpty()) {
            int nextYear = Integer.parseInt(year) + 1;
            message += "\\nFrom Year: " + year + " to Year: " + nextYear;
        }
        
        out.print("{\"success\":true,\"message\":\"" + message + "\"}");
        
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
