<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    
    // Get student data from session
    String studentSic = (String) session.getAttribute("studentSic");
    String studentSection = (String) session.getAttribute("studentSection");
    String studentBranch = (String) session.getAttribute("studentBranch");
    String studentYear = (String) session.getAttribute("studentYear");
    Boolean isVoted = (Boolean) session.getAttribute("studentIsVoted");
    
    // Get candidate SIC from request (null if "None of the Below")
    String candidateSic = request.getParameter("candidateSic");
    
    // Check if student is authenticated
    if (studentSic == null) {
        out.print("{\"success\": false, \"message\": \"Not authenticated. Please log in again.\"}");
        return;
    }
    
    // Check if student has already voted
    if (isVoted != null && isVoted) {
        out.print("{\"success\": false, \"message\": \"You have already voted.\"}");
        return;
    }
    
    String dbURL = "jdbc:mysql://localhost:3306/cr_election_db";
    String dbUser = "cr_user";
    String dbPassword = "StrongPassword123!";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        // Start transaction
        conn.setAutoCommit(false);
        
        // If a candidate was selected (not "None of the Below")
        if (candidateSic != null && !candidateSic.trim().isEmpty()) {
            // Verify candidate is from the same section, branch, and year
            String verifySql = "SELECT c.id FROM candidates c " +
                             "JOIN students s ON c.sic = s.sic " +
                             "WHERE c.sic = ? AND s.section = ? AND s.branch = ? AND s.year = ?";
            PreparedStatement verifyStmt = conn.prepareStatement(verifySql);
            verifyStmt.setString(1, candidateSic);
            verifyStmt.setString(2, studentSection);
            verifyStmt.setString(3, studentBranch);
            verifyStmt.setString(4, studentYear);
            ResultSet rs = verifyStmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                out.print("{\"success\": false, \"message\": \"Invalid candidate selection. Candidate must be from your class (Branch: " + studentBranch + ", Year: " + studentYear + ", Section: " + studentSection + ").\"}");
                rs.close();
                verifyStmt.close();
                return;
            }
            rs.close();
            verifyStmt.close();
            
            // Increment candidate's vote count
            String updateVoteSql = "UPDATE candidates SET votes = votes + 1 WHERE sic = ?";
            pstmt = conn.prepareStatement(updateVoteSql);
            pstmt.setString(1, candidateSic);
            pstmt.executeUpdate();
            pstmt.close();
        }
        
        // Mark student as voted
        String updateStudentSql = "UPDATE students SET isVoted = 1 WHERE sic = ?";
        pstmt = conn.prepareStatement(updateStudentSql);
        pstmt.setString(1, studentSic);
        pstmt.executeUpdate();
        
        // Commit transaction
        conn.commit();
        
        // Update session
        session.setAttribute("studentIsVoted", true);
        
        out.print("{\"success\": true, \"message\": \"Vote cast successfully.\"}");
        
    } catch (ClassNotFoundException e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        out.print("{\"success\": false, \"message\": \"Database driver error.\"}");
        e.printStackTrace();
    } catch (SQLException e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
