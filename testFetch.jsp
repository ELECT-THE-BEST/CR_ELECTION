<%@ page import="java.sql.*" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Test Student Fetch</title>
        <style>
            body {
                font-family: Arial;
                padding: 20px;
                background: #0a0e12;
                color: #fff;
            }

            .result {
                background: #1a1e22;
                padding: 20px;
                margin: 20px 0;
                border: 1px solid #8ab452;
            }

            input {
                padding: 10px;
                margin: 10px 0;
                width: 300px;
            }

            button {
                padding: 10px 20px;
                background: #8ab452;
                border: none;
                cursor: pointer;
            }

            img {
                max-width: 200px;
                border: 2px solid #8ab452;
                margin-top: 10px;
            }
        </style>
    </head>

    <body>
        <h1>Test Student Data Fetch</h1>
        <form method="GET">
            <input type="text" name="sic" placeholder="Enter SIC" value="<%= request.getParameter(" sic") !=null ?
                request.getParameter("sic") : "" %>">
            <button type="submit">Fetch Student</button>
        </form>

        <% String sic=request.getParameter("sic"); if (sic !=null && !sic.trim().isEmpty()) { Connection conn=null;
            PreparedStatement pstmt=null; ResultSet rs=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
            conn=DriverManager.getConnection( "jdbc:mysql://localhost:3306/cr_election_db" , "cr_user"
            , "StrongPassword123!" ); String sql="SELECT * FROM students WHERE sic = ?" ;
            pstmt=conn.prepareStatement(sql); pstmt.setString(1, sic.trim()); rs=pstmt.executeQuery(); if (rs.next()) {
            // Store all values in variables first String studentSic=rs.getString("sic"); String
            studentName=rs.getString("name"); String studentBranch=rs.getString("branch"); String
            studentSection=rs.getString("section"); String studentYear=rs.getString("year"); String
            studentRegCode=rs.getString("reg_code"); String studentImageUrl=rs.getString("image_url"); %>
            <div class="result">
                <h2>Student Found!</h2>
                <p><strong>SIC:</strong>
                    <%= studentSic %>
                </p>
                <p><strong>Name:</strong>
                    <%= studentName %>
                </p>
                <p><strong>Branch:</strong>
                    <%= studentBranch %>
                </p>
                <p><strong>Section:</strong>
                    <%= studentSection %>
                </p>
                <p><strong>Year:</strong>
                    <%= studentYear %>
                </p>
                <p><strong>Reg Code:</strong>
                    <%= studentRegCode !=null ? studentRegCode : "Not generated" %>
                </p>
                <p><strong>Image URL:</strong>
                    <%= studentImageUrl %>
                </p>
                <% if (studentImageUrl !=null && !studentImageUrl.isEmpty()) { %>
                    <p><img src="<%= studentImageUrl %>" alt="Student Photo"></p>
                    <% } %>
            </div>
            <% } else { %>
                <div class="result" style="border-color: #ff4757;">
                    <h2>Student Not Found</h2>
                    <p>No student with SIC '<%= sic %>' found in database.</p>
                </div>
                <% } } catch (Exception e) { %>
                    <div class="result" style="border-color: #ff4757;">
                        <h2>Error</h2>
                        <p>
                            <%= e.getMessage() %>
                        </p>
                    </div>
                    <% e.printStackTrace(); } finally { if (rs !=null) try { rs.close(); } catch (Exception e) {} if
                        (pstmt !=null) try { pstmt.close(); } catch (Exception e) {} if (conn !=null) try {
                        conn.close(); } catch (Exception e) {} } } %>
    </body>

    </html>