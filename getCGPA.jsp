<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*"%>
<%
String sic = request.getParameter("sic");
if (sic == null || sic.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"SIC is required\"}");
    return;
}

// Remove SITBBS prefix if present
String shortSic = sic.toUpperCase().replace("SITBBS", "");

try {
    // Call Flask API to get CGPA
    String flaskUrl = "http://localhost:5000/download";
    URL url = new URL(flaskUrl);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json");
    conn.setDoOutput(true);
    conn.setConnectTimeout(10000); // 10 second connection timeout
    conn.setReadTimeout(300000); // 5 minute read timeout (for PDF download + parsing)
    
    // Send SIC to Flask
    String jsonInput = "{\"sic\":\"" + shortSic + "\"}";
    OutputStream os = conn.getOutputStream();
    os.write(jsonInput.getBytes("UTF-8"));
    os.close();
    
    // Read response
    int responseCode = conn.getResponseCode();
    BufferedReader reader;
    
    if (responseCode == 200) {
        reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    } else {
        reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
    }
    
    StringBuilder responseBody = new StringBuilder();
    String inputLine;
    while ((inputLine = reader.readLine()) != null) {
        responseBody.append(inputLine);
    }
    reader.close();
    
    if (responseCode == 200) {
        // Parse the Flask response manually (avoid JSONObject dependency)
        String responseStr = responseBody.toString();
        
        // Extract CGPA from JSON response
        String cgpa = "Not found";
        int cgpaIndex = responseStr.indexOf("\"cgpa\"");
        if (cgpaIndex != -1) {
            int colonIndex = responseStr.indexOf(":", cgpaIndex);
            int commaIndex = responseStr.indexOf(",", colonIndex);
            int braceIndex = responseStr.indexOf("}", colonIndex);
            
            int endIndex = (commaIndex != -1 && commaIndex < braceIndex) ? commaIndex : braceIndex;
            if (endIndex != -1) {
                String cgpaValue = responseStr.substring(colonIndex + 1, endIndex).trim();
                // Remove quotes if present
                cgpaValue = cgpaValue.replace("\"", "").trim();
                if (!cgpaValue.isEmpty() && !cgpaValue.equals("null")) {
                    cgpa = cgpaValue;
                }
            }
        }
        
        // Build JSON response manually
        StringBuilder result = new StringBuilder();
        result.append("{");
        result.append("\"success\":true,");
        result.append("\"sic\":\"").append(sic).append("\",");
        result.append("\"cgpa\":\"").append(cgpa).append("\"");
        result.append("}");
        
        out.print(result.toString());
    } else {
        out.print("{\"success\":false,\"message\":\"Failed to fetch CGPA from ERP (HTTP " + responseCode + ")\"}");
    }
    
} catch (java.net.ConnectException e) {
    out.print("{\"success\":false,\"message\":\"Cannot connect to Flask API. Please ensure it is running on port 5000.\"}");
} catch (java.net.SocketTimeoutException e) {
    out.print("{\"success\":false,\"message\":\"Request timeout. Flask API is taking too long to respond.\"}");
} catch (Exception e) {
    String errMsg = e.getMessage();
    if (errMsg != null) errMsg = errMsg.replace("\"", "\\\"").replace("\\", "\\\\").replace("\n", " ").replace("\r", "");
    out.print("{\"success\":false,\"message\":\"" + (errMsg != null ? errMsg : "Unknown error") + "\"}");
    e.printStackTrace();
}
%>
