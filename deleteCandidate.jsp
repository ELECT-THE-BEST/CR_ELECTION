<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <% String sic=request.getParameter("sic"); if (sic==null || sic.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"SIC is required\"}"); return; } Connection conn=null;
            PreparedStatement pstmt=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
            conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/cr_election_db", "cr_user"
            , "StrongPassword123!" ); String sql="DELETE FROM candidates WHERE sic = ?" ;
            pstmt=conn.prepareStatement(sql); pstmt.setString(1, sic.trim()); int rowsAffected=pstmt.executeUpdate(); if
            (rowsAffected> 0) {
            out.print("{\"success\":true,\"message\":\"Candidate deleted successfully\"}");
            } else {
            out.print("{\"success\":false,\"message\":\"Candidate not found\"}");
            }

            } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
            e.printStackTrace();
            } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
            %>