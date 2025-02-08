#!/bin/bash

# Define temporary directory
TEMP_DIR="/tmp/glitchlinux.wtf"
WEB_ROOT="/var/www/html"

# Create temporary directory and navigate to it
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Clone the GitHub repository
git clone https://github.com/GlitchLinux/glitchlinux.wtf.git

# Move the files to the correct Apache location (excluding splash.png)
cp $TEMP_DIR/glitchlinux.html/index.html $WEB_ROOT/index.html
cp $TEMP_DIR/glitchlinux.html/styles.css $WEB_ROOT/styles.css

# Set correct ownership and permissions for Apache to access the files
sudo chown -R www-data:www-data $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT

# Restart Apache to apply the changes
sudo systemctl restart apache2

# Clean up the temporary directory
rm -rf $TEMP_DIR

# Script complete
echo "Deployment complete and Apache restarted!"
