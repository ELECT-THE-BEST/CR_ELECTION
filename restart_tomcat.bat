@echo off
echo ========================================
echo Restarting Tomcat Server
echo ========================================
echo.

echo Stopping Tomcat...
net stop Tomcat9
timeout /t 3

echo Starting Tomcat...
net start Tomcat9
timeout /t 5

echo.
echo ========================================
echo Tomcat has been restarted!
echo Please wait 10 seconds for it to fully start
echo Then try the delete operation again
echo ========================================
pause
