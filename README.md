# XAMPP Virtual Host SSL Configuration Guide

Welcome to the **XAMPP Virtual Host SSL Configuration Guide** provided by **Codethuegiare.com**.

## Prerequisites
- Ensure that the `crt` folder is copied to the `xampp/apache` directory within your XAMPP installation path.
- Ensure that both `makecert_ctgr.bat` and `cert.conf` files are located inside the `crt` folder.
- Open the `makecert_ctgr.bat` file from the `crt` folder to proceed.

## How to Use
1. **Start the Script**  
   Open the `makecert_ctgr.bat` file.

2. **Proceed Confirmation**  
   You'll be prompted:
   > If everything is ready, press 'y' to continue or any other key to exit.

3. **Enter Domain**  
   Input your domain name when prompted.

4. **Certificate Creation**
   The script will:
   - Generate a private key.
   - Create a Certificate Signing Request (CSR).
   - Generate a self-signed certificate.
   - Move the generated key and certificate into a folder named after the domain.

5. **Certificate Installation Instructions**
   - Double-click on `.\crt\<your-domain>\server.crt`.
   - Click **Install Certificate...**.
   - Select **Local Machine** and click **Next**.
   - Choose **Place all certificates in the following store** and click **Browse**.
   - Select **Trusted Root Certification Authorities** and click **OK**.
   - Click **Next** and then **Finish**.

## Apache Configuration Steps

1. **Update `httpd-vhosts.conf`**
   - Path: `xampp/apache/conf/extra/httpd-vhosts.conf`
   - Add the following configuration:

```apache
<VirtualHost *:80>
    ServerAdmin webmaster@<your-domain>
    DocumentRoot "I:/xampp/htdocs/<your-domain>/public_html"
    ServerName <your-domain>
    ServerAlias www.<your-domain>
    ErrorLog "logs/<your-domain>-error.log"

    RewriteEngine On
    RewriteCond %{SERVER_NAME} =www.<your-domain> [OR]
    RewriteCond %{SERVER_NAME} =<your-domain>
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

    CustomLog "logs/<your-domain>-access.log" common
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot "I:/xampp/htdocs/<your-domain>/public_html"
    ServerName <your-domain>
    ServerAlias www.<your-domain>

    SSLEngine on
    SSLCertificateFile "crt/<your-domain>/server.crt"
    SSLCertificateKeyFile "crt/<your-domain>/server.key"

    ErrorLog "logs/<your-domain>-ssl-error.log"
    CustomLog "logs/<your-domain>-ssl-access.log" common
</VirtualHost>
```

2. **Enable SSL in `httpd.conf`**
   - Open `xampp/apache/conf/httpd.conf`.
   - Uncomment the following lines (remove the `#` symbol):
     ```apache
     LoadModule ssl_module modules/mod_ssl.so
     Include conf/extra/httpd-ssl.conf
     ```

3. **Update the Hosts File**
   - Open `C:\Windows\System32\drivers\etc\hosts` as Administrator.
   - Add the following lines:
     ```
     127.0.0.1   <your-domain>
     127.0.0.1   www.<your-domain>
     ```

4. **Restart Apache**
   - Open the XAMPP Control Panel.
   - Click **Stop** on Apache, then click **Start** to restart.

## Completion
Upon successful setup, your SSL configuration for the domain is completed.

**Codethuegiare.com** wishes you success!

