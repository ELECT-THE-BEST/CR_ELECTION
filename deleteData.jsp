<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    // Set response type to JSON
    response.setContentType("application/json");
    
    // Get filter parameters
    String branch = request.getParameter("branch");
    String section = request.getParameter("section");
    String year = request.getParameter("year");
    
    // Database connection details
    String dbURL = "jdbc:mysql://localhost:3306/cr_election_db";
    String dbUser = "root";
    String dbPassword = "";
    
    Connection conn = null;
    PreparedStatement pstmtStudents = null;
    PreparedStatement pstmtCandidates = null;
    JSONObject jsonResponse = new JSONObject();
    
    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Establish connection
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        conn.setAutoCommit(false); // Start transaction
        
        // Build WHERE clause based on filters
        StringBuilder whereClause = new StringBuilder();
        boolean hasFilters = false;
        
        if (branch != null && !branch.trim().isEmpty()) {
            whereClause.append("branch = ?");
            hasFilters = true;
        }
        
        if (section != null && !section.trim().isEmpty()) {
            if (hasFilters) whereClause.append(" AND ");
            whereClause.append("section = ?");
            hasFilters = true;
        }
        
        if (year != null && !year.trim().isEmpty()) {
            if (hasFilters) whereClause.append(" AND ");
            whereClause.append("year = ?");
            hasFilters = true;
        }
        
        // Prepare SQL statements
        String sqlStudents;
        String sqlCandidates;
        
        if (hasFilters) {
            sqlStudents = "DELETE FROM students WHERE " + whereClause.toString();
            sqlCandidates = "DELETE FROM candidates WHERE " + whereClause.toString();
        } else {
            // Delete all records if no filters
            sqlStudents = "DELETE FROM students";
            sqlCandidates = "DELETE FROM candidates";
        }
        
        // Log the SQL for debugging
        jsonResponse.put("debug_sql_students", sqlStudents);
        jsonResponse.put("debug_sql_candidates", sqlCandidates);
        jsonResponse.put("debug_branch", branch);
        jsonResponse.put("debug_section", section);
        jsonResponse.put("debug_year", year);
        
        // Execute deletion for students
        pstmtStudents = conn.prepareStatement(sqlStudents);
        if (hasFilters) {
            int paramIndex = 1;
            if (branch != null && !branch.trim().isEmpty()) {
                pstmtStudents.setString(paramIndex++, branch);
            }
            if (section != null && !section.trim().isEmpty()) {
                pstmtStudents.setString(paramIndex++, section);
            }
            if (year != null && !year.trim().isEmpty()) {
                try {
                    int yearInt = Integer.parseInt(year);
                    pstmtStudents.setInt(paramIndex++, yearInt);
                    jsonResponse.put("debug_year_parsed", yearInt);
                } catch (NumberFormatException nfe) {
                    throw new Exception("Invalid year format: " + year + ". Year must be a number.");
                }
            }
        }
        int studentsDeleted = pstmtStudents.executeUpdate();
        
        // Execute deletion for candidates
        pstmtCandidates = conn.prepareStatement(sqlCandidates);
        if (hasFilters) {
            int paramIndex = 1;
            if (branch != null && !branch.trim().isEmpty()) {
                pstmtCandidates.setString(paramIndex++, branch);
            }
            if (section != null && !section.trim().isEmpty()) {
                pstmtCandidates.setString(paramIndex++, section);
            }
            if (year != null && !year.trim().isEmpty()) {
                int yearInt = Integer.parseInt(year);
                pstmtCandidates.setInt(paramIndex++, yearInt);
            }
        }
        int candidatesDeleted = pstmtCandidates.executeUpdate();
        
        // Commit transaction
        conn.commit();
        
        // Build success message
        String message;
        if (hasFilters) {
            message = "Deleted " + studentsDeleted + " student(s) and " + candidatesDeleted + " candidate(s) matching the selected criteria.";
        } else {
            message = "Deleted ALL data: " + studentsDeleted + " student(s) and " + candidatesDeleted + " candidate(s).";
        }
        
        jsonResponse.put("success", true);
        jsonResponse.put("message", message);
        jsonResponse.put("studentsDeleted", studentsDeleted);
        jsonResponse.put("candidatesDeleted", candidatesDeleted);
        
    } catch (Exception e) {
        // Rollback transaction on error
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error deleting data: " + e.getMessage());
        jsonResponse.put("error_type", e.getClass().getName());
        jsonResponse.put("error_stack", e.toString());
        e.printStackTrace();
    } finally {
        // Close resources
        try {
            if (pstmtStudents != null) pstmtStudents.close();
            if (pstmtCandidates != null) pstmtCandidates.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Send JSON response
    out.print(jsonResponse.toString());
%>
