<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String sic = request.getParameter("sic");
    boolean studentFound = false;
    String studentName = "";
    String studentBranch = "";
    String studentSection = "";
    String studentYear = "";
    String imageUrl = "";
    boolean isVoted = false;
    
    String dbURL = "jdbc:mysql://localhost:3306/cr_election_db";
    String dbUser = "cr_user";
    String dbPassword = "StrongPassword123!";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        
        String sql = "SELECT sic, name, branch, section, year, image_url, isVoted FROM students WHERE sic = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sic);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            studentFound = true;
            studentName = rs.getString("name");
            studentBranch = rs.getString("branch");
            studentSection = rs.getString("section");
            studentYear = rs.getString("year");
            imageUrl = rs.getString("image_url");
            isVoted = rs.getBoolean("isVoted");
            
            // Store student data in session
            session.setAttribute("studentSic", sic);
            session.setAttribute("studentName", studentName);
            session.setAttribute("studentBranch", studentBranch);
            session.setAttribute("studentSection", studentSection);
            session.setAttribute("studentYear", studentYear);
            session.setAttribute("studentImageUrl", imageUrl);
            session.setAttribute("studentIsVoted", isVoted);
            
            // Check if student has already voted
            if (isVoted) {
                response.sendRedirect("studentAuth.html?error=alreadyvoted");
            } else {
                response.sendRedirect("voting.html");
            }
        } else {
            response.sendRedirect("studentAuth.html?error=notfound");
        }
    } catch (ClassNotFoundException e) {
        out.println("Error: MySQL JDBC Driver not found.");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("Database error: " + e.getMessage());
        e.printStackTrace();
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