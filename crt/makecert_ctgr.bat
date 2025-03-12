@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo  XAMPP Virtual Host SSL Configuration Guide
echo  ----- Codethuegiare.com -----
echo ==========================================
echo.

echo Make sure you have copied the "crt" folder to the xampp/apache directory in your XAMPP installation path.
echo Make sure the "makecert_ctgr.bat" and "cert.conf" files are in the "crt" folder.
echo Please open the makecert_ctgr.bat file from the crt folder to continue.
echo.
set /p continue="If everything is ready, press 'y' to continue or any other key to exit: "

if /i not "%continue%"=="y" (
    echo Program terminated.
    goto :eof
)

set /p domain="Enter Domain: "

REM Create directory for the domain if it doesn't exist
if not exist ".\%domain%" mkdir ".\%domain%"

REM Create temporary config file by replacing {{DOMAIN}} with the entered domain
(for /f "delims=" %%A in (cert.conf) do (
    set "line=%%A"
    set "line=!line:{{domain}}=%domain%!"
    echo !line!
)) > cert_temp.conf

REM Generate private key
echo Generating private key...
..\bin\openssl genrsa -out %domain%.key 2048

REM Generate certificate signing request
echo Generating certificate request...
..\bin\openssl req -new -key %domain%.key -out %domain%.csr -config cert_temp.conf -batch

REM Generate self-signed certificate
echo Creating self-signed certificate...
..\bin\openssl x509 -req -days 1825 -in %domain%.csr -signkey %domain%.key -out %domain%.crt -extensions x509_ext -extfile cert_temp.conf

REM Move generated files to domain folder
echo Moving files to domain folder...
move "%domain%.key" ".\%domain%\server.key"
move "%domain%.crt" ".\%domain%\server.crt"

REM Clean up temporary files
echo Cleaning up temporary files...
del cert_temp.conf
if exist %domain%.csr del %domain%.csr

echo.
echo SSL certificate for %domain% has been created and saved in .\%domain% folder
echo.
echo Certificate installation instructions:
echo 1. Double-click on .\crt\%domain%\server.crt
echo 2. Click "Install Certificate..."
echo 3. Select "Local Machine" and click "Next"
echo 4. Choose "Place all certificates in the following store" and click "Browse"
echo 5. Select "Trusted Root Certification Authorities" and click "OK"
echo 6. Click "Next" and then "Finish"
echo.

echo.
echo Step 1: Open the file httpd-vhosts.conf
echo   Path: xampp\apache\conf\extra\httpd-vhosts.conf
echo.

echo Step 2: Add the following configuration to the file:
echo The DocumentRoot matches the path for your domain setup.

echo ----------------------------------------------
echo ^<VirtualHost *:80^>
echo     ServerAdmin webmaster@%domain%
echo     DocumentRoot "I:/xampp/htdocs/%domain%/public_html"
echo     ServerName %domain%
echo     ServerAlias www.%domain%
echo     ErrorLog "logs/%domain%-error.log"
echo.
echo     RewriteEngine On
echo     RewriteCond ^%%{SERVER_NAME} =www.%domain% [OR]
echo     RewriteCond ^%%{SERVER_NAME} =%domain%
echo     RewriteRule ^ https://%%{SERVER_NAME}%%{REQUEST_URI} [END,NE,R=permanent]
echo.
echo     CustomLog "logs/%domain%-access.log" common
echo ^</VirtualHost^>

echo.

echo ^<VirtualHost *:443^>
echo     DocumentRoot "I:/xampp/htdocs/%domain%/public_html"
echo     ServerName %domain%
echo     ServerAlias www.%domain%
echo.
echo     SSLEngine on
echo     SSLCertificateFile "crt/%domain%/server.crt"
echo     SSLCertificateKeyFile "crt/%domain%/server.key"
echo.
echo     ErrorLog "logs/%domain%-ssl-error.log"
echo     CustomLog "logs/%domain%-ssl-access.log" common
echo ^</VirtualHost^>
echo ----------------------------------------------
echo.

echo Step 3: Enable SSL in httpd.conf
echo   - Open xampp\apache\conf\httpd.conf
echo   - Uncomment the following lines (remove the # symbol):
echo     LoadModule ssl_module modules/mod_ssl.so
echo     Include conf/extra/httpd-ssl.conf
echo.

echo Step 4: Add the domain to your hosts file
echo   - Open C:\Windows\System32\drivers\etc\hosts with Administrator privileges.
echo   - Add these lines:
echo     127.0.0.1   %domain%
echo     127.0.0.1   www.%domain%
echo.

echo Step 5: Restart Apache using XAMPP Control Panel
echo   - Click [Stop] on Apache, then click [Start] again.
echo.

echo ==========================================
echo    Configuration Guide Completed!
echo 	Codethuegiare.com
echo ==========================================
pause