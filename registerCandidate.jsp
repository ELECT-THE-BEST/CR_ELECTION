<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String sic = request.getParameter("sic");
String motiv = request.getParameter("motiv");

if (sic == null || sic.trim().isEmpty() || motiv == null || motiv.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"SIC and motivation are required\"}");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
    
    String sql = "INSERT INTO candidates (sic, votes, motiv) VALUES (?, 0, ?)";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, sic.trim());
    pstmt.setString(2, motiv.trim());
    
    int rowsAffected = pstmt.executeUpdate();
    
    if (rowsAffected > 0) {
        out.print("{\"success\":true,\"message\":\"Candidate registered successfully!\"}");
    } else {
        out.print("{\"success\":false,\"message\":\"Failed to register candidate\"}");
    }
    
} catch (SQLIntegrityConstraintViolationException e) {
    out.print("{\"success\":false,\"message\":\"This candidate is already registered!\"}");
} catch (Exception e) {
    out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
    e.printStackTrace();
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>