<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    StringBuilder json = new StringBuilder();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/cr_election_db",
            "cr_user",
            "StrongPassword123!"
        );
        
        int totalStudents = 0;
        int totalCandidates = 0;
        int totalSections = 0;
        int votedCount = 0;
        int totalCount = 0;
        
        // Get total students count
        pstmt = conn.prepareStatement("SELECT COUNT(*) as count FROM students");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalStudents = rs.getInt("count");
        }
        rs.close();
        pstmt.close();
        
        // Get total candidates count
        pstmt = conn.prepareStatement("SELECT COUNT(*) as count FROM candidates");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalCandidates = rs.getInt("count");
        }
        rs.close();
        pstmt.close();
        
        // Get total sections count (distinct year, branch, section combinations)
        pstmt = conn.prepareStatement("SELECT COUNT(DISTINCT CONCAT(year, '-', branch, '-', section)) as count FROM students");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalSections = rs.getInt("count");
        }
        rs.close();
        pstmt.close();
        
        // Get participation percentage (students who have voted)
        pstmt = conn.prepareStatement("SELECT COUNT(*) as voted FROM students WHERE isVoted = 1");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            votedCount = rs.getInt("voted");
        }
        rs.close();
        pstmt.close();
        
        pstmt = conn.prepareStatement("SELECT COUNT(*) as total FROM students");
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalCount = rs.getInt("total");
        }
        
        double participationPercentage = 0;
        if (totalCount > 0) {
            participationPercentage = (votedCount * 100.0) / totalCount;
        }
        long roundedParticipation = Math.round(participationPercentage);
        
        // Manually construct JSON response
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"totalStudents\":").append(totalStudents).append(",");
        json.append("\"totalCandidates\":").append(totalCandidates).append(",");
        json.append("\"totalSections\":").append(totalSections).append(",");
        json.append("\"participationPercentage\":").append(roundedParticipation);
        json.append("}");
        
        out.print(json.toString());
        
    } catch (Exception e) {
        // Manually construct error JSON response
        json = new StringBuilder();
        json.append("{");
        json.append("\"success\":false,");
        json.append("\"error\":\"").append(e.getMessage().replace("\"", "\\\"")).append("\"");
        json.append("}");
        out.print(json.toString());
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
