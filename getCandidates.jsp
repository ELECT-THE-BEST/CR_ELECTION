
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String branch = request.getParameter("branch");
String section = request.getParameter("section");
String year = request.getParameter("year");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
    
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT c.id, c.sic, c.votes, c.motiv, s.name, s.branch, s.section, s.year, s.image_url ");
    sql.append("FROM candidates c ");
    sql.append("JOIN students s ON c.sic = s.sic ");
    sql.append("WHERE 1=1 ");
    
    if (branch != null && !branch.trim().isEmpty()) {
        sql.append("AND s.branch = ? ");
    }
    if (section != null && !section.trim().isEmpty()) {
        sql.append("AND s.section = ? ");
    }
    if (year != null && !year.trim().isEmpty()) {
        sql.append("AND s.year = ? ");
    }
    
    sql.append("ORDER BY c.votes DESC, s.name ASC");
    
    pstmt = conn.prepareStatement(sql.toString());
    
    int paramIndex = 1;
    if (branch != null && !branch.trim().isEmpty()) {
        pstmt.setString(paramIndex++, branch);
    }
    if (section != null && !section.trim().isEmpty()) {
        pstmt.setString(paramIndex++, section);
    }
    if (year != null && !year.trim().isEmpty()) {
        // FIX: Use setInt() for year parameter since year column is INT
        pstmt.setInt(paramIndex++, Integer.parseInt(year));
    }
    
    rs = pstmt.executeQuery();
    
    StringBuilder json = new StringBuilder();
    json.append("{\"success\":true,\"candidates\":[");
    
    boolean first = true;
    while (rs.next()) {
        if (!first) json.append(",");
        first = false;
        
        int id = rs.getInt("id");
        String candidateSic = rs.getString("sic");
        String name = rs.getString("name");
        String candidateBranch = rs.getString("branch");
        String candidateSection = rs.getString("section");
        int candidateYear = rs.getInt("year");  // Changed to getInt
        String motiv = rs.getString("motiv");
        String imageUrl = rs.getString("image_url");
        int votes = rs.getInt("votes");
        
        if (name != null) name = name.replace("\"", "\\\"");
        if (motiv != null) motiv = motiv.replace("\"", "\\\"");
        if (imageUrl != null) imageUrl = imageUrl.replace("\"", "\\\"");
        
        String motivShort = "";
        if (motiv != null && motiv.length() > 0) {
            motivShort = motiv.substring(0, Math.min(50, motiv.length()));
        }
        
        json.append("{");
        json.append("\"id\":").append(id).append(",");
        json.append("\"sic\":\"").append(candidateSic).append("\",");
        json.append("\"name\":\"").append(name != null ? name : "").append("\",");
        json.append("\"branch\":\"").append(candidateBranch != null ? candidateBranch : "").append("\",");
        json.append("\"section\":\"").append(candidateSection != null ? candidateSection : "").append("\",");
        json.append("\"year\":").append(candidateYear).append(",");  // Changed to output as number
        json.append("\"motiv\":\"").append(motivShort).append("\",");
        json.append("\"image_url\":\"").append(imageUrl != null ? imageUrl : "").append("\",");
        json.append("\"votes\":").append(votes);
        json.append("}");
    }
    
    json.append("]}");
    out.print(json.toString());
    
} catch (Exception e) {
    out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
