<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    Connection conn = null;
    PreparedStatement pstmt1 = null;
    PreparedStatement pstmt2 = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
        conn.setAutoCommit(false);
        
        String resetVotesSQL = "UPDATE students SET isvoted = 0";
        pstmt1 = conn.prepareStatement(resetVotesSQL);
        int votesReset = pstmt1.executeUpdate();
        
        String deleteCandidatesSQL = "DELETE FROM candidates";
        pstmt2 = conn.prepareStatement(deleteCandidatesSQL);
        int candidatesDeleted = pstmt2.executeUpdate();
        
        conn.commit();
        
        out.print("{\"success\":true,\"message\":\"Reset completed successfully!\\n\\n- " + votesReset + " student voting statuses reset\\n- " + candidatesDeleted + " candidates deleted\"}");
        
    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        e.printStackTrace();
    } finally {
        if (pstmt1 != null) try { pstmt1.close(); } catch (Exception e) {}
        if (pstmt2 != null) try { pstmt2.close(); } catch (Exception e) {}
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception e) {}
        }
    }
%>