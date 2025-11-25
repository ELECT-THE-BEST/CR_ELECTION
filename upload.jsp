<%@ page import="java.io.*, java.sql.*, java.util.*, java.nio.file.Paths, jakarta.servlet.http.Part" %>
<%@ page import="org.apache.poi.ss.usermodel.*, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFWorkbook" %>
<%@ page import="com.opencsv.CSVReader" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    final String DB_URL = "jdbc:mysql://localhost:3306/cr_election_db?useSSL=false&allowPublicKeyRetrieval=true";
    final String DB_USER = "cr_user";
    final String DB_PASS = "StrongPassword123!";
    
    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
%>

<%
    Part filePart = request.getPart("excelFile");
    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
    InputStream fileStream = filePart.getInputStream();
    boolean isCsv = fileName.toLowerCase().endsWith(".csv");
    List<String[]> rows = new ArrayList<>();

    try {
        if (isCsv) {
            CSVReader csvReader = new CSVReader(new InputStreamReader(fileStream, "UTF-8"));
            String[] nextLine;
            while ((nextLine = csvReader.readNext()) != null) {
                rows.add(nextLine);
            }
            csvReader.close();
        } else {
            Workbook workbook = null;
            if (fileName.toLowerCase().endsWith(".xlsx")) {
                workbook = new XSSFWorkbook(fileStream);
            } else {
                workbook = new HSSFWorkbook(fileStream);
            }
            Sheet sheet = workbook.getSheetAt(0);
            for (Row row : sheet) {
                String[] cols = new String[9];
                for (int i = 0; i < 9; i++) {
                    Cell cell = row.getCell(i, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    cols[i] = cell.toString().trim();
                }
                rows.add(cols);
            }
            workbook.close();
        }
    } catch (Exception e) {
        String errorMsg = e.getMessage();
        if (errorMsg != null && errorMsg.contains("Strict OOXML")) {
%>
            <h3 style='color:#e74c3c;'>Excel File Format Not Supported</h3>
            <p style='color:#fff;'>Your Excel file uses Strict OOXML format which is not currently supported.</p>
            <p style='color:#fff;'><strong>Solutions:</strong></p>
            <ul style='color:#fff;'>
                <li>Save your Excel file as <strong>CSV</strong> format and upload again</li>
                <li>Or in Excel: File Save As Excel Workbook (.xlsx) not Strict Open XML</li>
            </ul>
            <a href='admin.html' style='color:#8ab452;'>Back to Admin</a>
<%
        } else {
%>
            <h3 style='color:#e74c3c;'>Error parsing file: <%= errorMsg %></h3>
            <a href='admin.html' style='color:#8ab452;'>Back to Admin</a>
<%
        }
        return;
    }

    String insertSQL = "INSERT INTO students (serial_no, roll_no, sic, reg_code, image_url, name, branch, section, year) VALUES (?,?,?,?,?,?,?,?,?)";
    int success = 0;
    int fail = 0;
    StringBuilder failMsg = new StringBuilder();

    try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(insertSQL)) {
        conn.setAutoCommit(false);
        for (String[] cols : rows) {
            if (cols.length < 9) {
                fail++;
                failMsg.append("Row with insufficient columns skipped.<br />");
                continue;
            }
            try {
                ps.setString(1, cols[0]);  // serial_no
                ps.setString(2, cols[1]);  // roll_no
                ps.setString(3, cols[2]);  // sic
                ps.setString(4, cols[3]);  // reg_code
                ps.setString(5, cols[4]);  // image_url
                ps.setString(6, cols[5]);  // name
                ps.setString(7, cols[6]);  // branch
                ps.setString(8, cols[7]);  // section
                
                // Parse year as integer
                String yearStr = cols[8].trim();
                int year = 0;
                
                // Handle different year formats
                if (yearStr.isEmpty()) {
                    fail++;
                    failMsg.append("Error on row: Year is empty - " + java.util.Arrays.toString(cols) + "<br />");
                    continue;
                }
                
                // Remove any decimal points (e.g., "2.0" becomes "2")
                if (yearStr.contains(".")) {
                    yearStr = yearStr.substring(0, yearStr.indexOf("."));
                }
                
                try {
                    year = Integer.parseInt(yearStr);
                    
                    // Validate year range (1-4 for typical undergraduate years)
                    if (year < 1 || year > 4) {
                        fail++;
                        failMsg.append("Error on row: Invalid year value (" + year + ") - must be between 1 and 4 - " + java.util.Arrays.toString(cols) + "<br />");
                        continue;
                    }
                    
                    ps.setInt(9, year);  // year as integer
                    ps.addBatch();
                    success++;
                } catch (NumberFormatException nfe) {
                    fail++;
                    failMsg.append("Error on row: Year must be a number (found '" + yearStr + "') - " + java.util.Arrays.toString(cols) + "<br />");
                    continue;
                }
            } catch (Exception ex) {
                fail++;
                failMsg.append("Error on row: " + ex.getMessage() + " - " + java.util.Arrays.toString(cols) + "<br />");
            }
        }
        ps.executeBatch();
        conn.commit();
    } catch (SQLException sqle) {
%>
        <h3 style='color:#e74c3c;'>Database error: <%= sqle.getMessage() %></h3>
        <a href='admin.html' style='color:#8ab452;'>Back to Admin</a>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Upload Result</title>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: #0a0e12;
            color: #fff;
            padding: 2rem;
        }
        .card {
            background: #1a1e24;
            padding: 1.5rem;
            border-radius: 8px;
            max-width: 600px;
            margin: auto;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }
        .success {
            color: #27ae60;
        }
        .error {
            color: #e74c3c;
        }
        a {
            color: #8ab452;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Upload Summary</h2>
        <p class="success">Successfully inserted <strong><%= success %></strong> records.</p>
        <% if (fail > 0) { %>
            <p class="error">Failed: <strong><%= fail %></strong> rows.</p>
            <div class="error"><%= failMsg.toString() %></div>
        <% } %>
        <a href="admin.html">Back to Admin</a>
    </div>
</body>
</html>
