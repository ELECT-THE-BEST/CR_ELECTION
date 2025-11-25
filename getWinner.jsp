<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="java.sql.*" %><%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String branch = request.getParameter("branch");
String section = request.getParameter("section");
String year = request.getParameter("year");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user", "StrongPassword123!");
    
    String sql = "SELECT c.id, c.sic, c.votes, c.motiv, s.name, s.branch, s.section, s.year, s.image_url, s.reg_code FROM candidates c JOIN students s ON c.sic = s.sic WHERE s.branch = ? AND s.section = ? AND s.year = ? ORDER BY c.votes DESC";
    
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, branch);
    pstmt.setString(2, section);
    pstmt.setString(3, year);
    rs = pstmt.executeQuery();
    
    int maxVotes = -1;
    java.util.List<java.util.Map<String, Object>> allCandidates = new java.util.ArrayList<>();
    
    while (rs.next()) {
        int votes = rs.getInt("votes");
        if (maxVotes == -1) maxVotes = votes;
        
        java.util.Map<String, Object> candidate = new java.util.HashMap<>();
        candidate.put("id", rs.getInt("id"));
        candidate.put("sic", rs.getString("sic"));
        candidate.put("name", rs.getString("name"));
        candidate.put("branch", rs.getString("branch"));
        candidate.put("section", rs.getString("section"));
        candidate.put("year", rs.getString("year"));
        candidate.put("votes", votes);
        candidate.put("motiv", rs.getString("motiv"));
        candidate.put("image_url", rs.getString("image_url"));
        candidate.put("reg_code", rs.getString("reg_code"));
        allCandidates.add(candidate);
    }
    
    rs.close();
    pstmt.close();
    
    String totalSql = "SELECT SUM(c.votes) as total_votes FROM candidates c JOIN students s ON c.sic = s.sic WHERE s.branch = ? AND s.section = ? AND s.year = ?";
    pstmt = conn.prepareStatement(totalSql);
    pstmt.setString(1, branch);
    pstmt.setString(2, section);
    pstmt.setString(3, year);
    rs = pstmt.executeQuery();
    
    int totalVotes = 0;
    if (rs.next()) totalVotes = rs.getInt("total_votes");
    
    StringBuilder json = new StringBuilder("{\"success\":true,\"candidates\":[");
    boolean first = true;
    int tieCount = 0;
    
    for (java.util.Map<String, Object> c : allCandidates) {
        int votes = (Integer) c.get("votes");
        if (votes == maxVotes) {
            if (!first) json.append(",");
            first = false;
            tieCount++;
            
            String name = (String) c.get("name");
            String motiv = (String) c.get("motiv");
            String imageUrl = (String) c.get("image_url");
            String regCode = (String) c.get("reg_code");
            
            if (name != null) name = name.replace("\"", "\\\"").replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "");
            if (motiv != null) motiv = motiv.replace("\"", "\\\"").replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "");
            if (imageUrl != null) imageUrl = imageUrl.replace("\"", "\\\"").replace("\\", "\\\\");
            if (regCode != null) regCode = regCode.replace("\"", "\\\"").replace("\\", "\\\\");
            
            json.append("{");
            json.append("\"id\":").append(c.get("id")).append(",");
            json.append("\"sic\":\"").append(c.get("sic") != null ? c.get("sic") : "").append("\",");
            json.append("\"name\":\"").append(name != null ? name : "").append("\",");
            json.append("\"branch\":\"").append(c.get("branch") != null ? c.get("branch") : "").append("\",");
            json.append("\"section\":\"").append(c.get("section") != null ? c.get("section") : "").append("\",");
            json.append("\"year\":\"").append(c.get("year") != null ? c.get("year") : "").append("\",");
            json.append("\"votes\":").append(votes).append(",");
            json.append("\"motiv\":\"").append(motiv != null ? motiv : "").append("\",");
            json.append("\"image_url\":\"").append(imageUrl != null ? imageUrl : "").append("\",");
            json.append("\"reg_code\":\"").append(regCode != null ? regCode : "").append("\"");
            json.append("}");
        }
    }
    
    json.append("],\"totalVotes\":").append(totalVotes).append(",\"isTie\":").append(tieCount > 1).append("}");
    out.print(json.toString());
    
} catch (Exception e) {
    String errMsg = e.getMessage();
    if (errMsg != null) errMsg = errMsg.replace("\"", "\\\"").replace("\\", "\\\\").replace("\n", " ").replace("\r", "");
    out.print("{\"success\":false,\"message\":\"" + (errMsg != null ? errMsg : "Unknown error") + "\"}");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>
