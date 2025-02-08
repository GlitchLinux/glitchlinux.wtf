#!/bin/bash

# Variables
DOMAIN="glitchlinux.wtf"
WEB_ROOT="/var/www/$DOMAIN"
APACHE_CONF="/etc/apache2/sites-available/$DOMAIN.conf"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

# Update system and install Apache
echo "[+] Updating package list and installing Apache..."
apt update && apt install -y apache2 curl unzip

# Create website directory and set permissions
echo "[+] Setting up website directory..."
mkdir -p $WEB_ROOT
chown -R www-data:www-data $WEB_ROOT
chmod -R 755 $WEB_ROOT

# Download website files
echo "[+] Downloading website files..."
curl -L -o $WEB_ROOT/index.html "https://github.com/GlitchLinux/glitchlinux.html/releases/download/glitchlinux.wtf/index.html"
curl -L -o $WEB_ROOT/styles.css "https://github.com/GlitchLinux/glitchlinux.html/releases/download/glitchlinux.wtf/styles.css"

# Create Apache virtual host configuration
echo "[+] Configuring Apache virtual host..."
cat > $APACHE_CONF <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $WEB_ROOT

    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined
</VirtualHost>
EOF

# Enable site and restart Apache
echo "[+] Enabling site and restarting Apache..."
a2ensite $DOMAIN.conf
a2dissite 000-default.conf
systemctl reload apache2

# Firewall setup (optional)
echo "[+] Allowing HTTP traffic in UFW..."
ufw allow 80/tcp

# Ask user if they want HTTPS (Let's Encrypt or self-signed)
echo "Do you want to enable HTTPS with Let's Encrypt? (y/n)"
read -r enable_ssl
if [[ "$enable_ssl" == "y" ]]; then
    echo "[+] Installing Let's Encrypt Certbot..."
    apt install -y certbot python3-certbot-apache
    certbot --apache -d $DOMAIN -d www.$DOMAIN
    ufw allow 443/tcp
    echo "[+] SSL enabled with Let's Encrypt!"
else
    echo "Skipping HTTPS setup. You can manually install SSL later."
fi

# Restart Apache
echo "[+] Restarting Apache..."
systemctl restart apache2

echo "[✓] Apache setup completed! Visit: http://$DOMAIN"
