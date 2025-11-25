<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    response.setContentType("application/json");
    
    String sic = (String) session.getAttribute("studentSic");
    String name = (String) session.getAttribute("studentName");
    String branch = (String) session.getAttribute("studentBranch");
    String section = (String) session.getAttribute("studentSection");
    String year = (String) session.getAttribute("studentYear");
    String imageUrl = (String) session.getAttribute("studentImageUrl");
    Boolean isVoted = (Boolean) session.getAttribute("studentIsVoted");
    
    if (sic == null || name == null) {
        out.print("{\"authenticated\": false}");
    } else {
        out.print("{");
        out.print("\"authenticated\": true,");
        out.print("\"sic\": \"" + sic + "\",");
        out.print("\"name\": \"" + name + "\",");
        out.print("\"branch\": \"" + (branch != null ? branch : "") + "\",");
        out.print("\"section\": \"" + (section != null ? section : "") + "\",");
        out.print("\"year\": \"" + (year != null ? year : "") + "\",");
        out.print("\"imageUrl\": \"" + (imageUrl != null ? imageUrl : "") + "\",");
        out.print("\"isVoted\": " + (isVoted != null ? isVoted : false));
        out.print("}");
    }
%>