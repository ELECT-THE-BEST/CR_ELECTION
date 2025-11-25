<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String sic = request.getParameter("sic");
if (sic == null || sic.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"SIC is required\"}");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
    
    String sql = "SELECT sic, reg_code, name, branch, year, section, image_url FROM students WHERE sic = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, sic.trim());
    rs = pstmt.executeQuery();
    
    if (rs.next()) {
        String regCode = rs.getString("reg_code");
        String name = rs.getString("name");
        String branch = rs.getString("branch");
        String year = rs.getString("year");
        String section = rs.getString("section");
        String imageUrl = rs.getString("image_url");
        
        if (regCode == null || regCode.trim().isEmpty()) regCode = "Not generated yet";
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"sic\":\"").append(sic).append("\",");
        json.append("\"reg_code\":\"").append(regCode).append("\",");
        json.append("\"name\":\"").append(name != null ? name : "").append("\",");
        json.append("\"branch\":\"").append(branch != null ? branch : "").append("\",");
        json.append("\"year\":\"").append(year != null ? year : "").append("\",");
        json.append("\"section\":\"").append(section != null ? section : "").append("\",");
        json.append("\"image_url\":\"").append(imageUrl != null ? imageUrl : "").append("\"");
        json.append("}");
        
        out.print(json.toString());
    } else {
        out.print("{\"success\":false,\"message\":\"Student not found\"}");
    }
    
} catch (Exception e) {
    out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>