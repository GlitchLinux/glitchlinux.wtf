#!/bin/bash

# Function to ask for root password (using sudo for subsequent commands)
ask_for_password() {
    sudo -v
}

# Function to check Apache status
check_apache_status() {
    systemctl status apache2
}

# Function to verify Apache configuration files
verify_apache_config() {
    echo "Checking Apache configuration for errors..."
    sudo apachectl configtest
}

# Function to stop Apache webserver
stop_webserver() {
    echo "Stopping Apache webserver..."
    sudo systemctl stop apache2
    echo "Webserver stopped."
}

# Function to migrate Apache to a new system
migrate_webserver() {
    read -p "Enter the destination server IP or hostname: " destination
    echo "Migrating Apache configuration and website files to $destination..."
    
    # Creating backup archive
    BACKUP_FILE="/tmp/apache_migration.tar.gz"
    sudo tar -czf $BACKUP_FILE /etc/apache2 /var/www/html /var/www/glitchlinux.wtf
    
    # Transferring backup to the new system
    scp $BACKUP_FILE $destination:/tmp/
    
    echo "Backup transferred. Extract it on the new system using:"
    echo "sudo tar -xzf /tmp/apache_migration.tar.gz -C /"
    echo "Then restart Apache on the new system with: sudo systemctl restart apache2"
}

# Function to update the website
update_website() {
    echo "Backing up current website files..."
    sudo mkdir -p /etc/apache-undo/html/html
    sudo mkdir -p /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf
    sudo cp /var/www/html/* /etc/apache-undo/html/html/
    sudo cp /var/www/glitchlinux.wtf/* /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/
    
    TEMP_DIR="/tmp/glitchlinux.wtf"
    sudo rm -rf $TEMP_DIR
    sudo mkdir -p $TEMP_DIR
    cd $TEMP_DIR
    sudo git clone https://github.com/GlitchLinux/glitchlinux.wtf.git $TEMP_DIR
    sudo cp $TEMP_DIR/* /var/www/html/
    sudo cp $TEMP_DIR/* /var/www/glitchlinux.wtf/
    sudo rm -rf $TEMP_DIR
    sudo chown -R www-data:www-data /var/www/html /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/html /var/www/glitchlinux.wtf
    sudo systemctl restart apache2
    echo "Website successfully updated!"
}

# Function to undo the last update
undo_last_update() {
    echo "Restoring the previous website configuration from backup..."
    sudo cp /etc/apache-undo/html/html/* /var/www/html/
    sudo cp /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/* /var/www/glitchlinux.wtf/
    sudo chown -R www-data:www-data /var/www/html /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/html /var/www/glitchlinux.wtf
    sudo systemctl restart apache2
    echo "Previous configuration was successfully restored."
}

# Function to reboot the webserver
reboot_webserver() {
    echo "Rebooting webserver..."
    sudo systemctl restart apache2
    echo "Webserver rebooted successfully."
}

# Function to backup webserver files
backup_webserver() {
    echo "Creating backup of webserver files..."
    BACKUP_PATH="/home/$USER/Desktop/Apache-Full-Backup.zip"
    sudo zip -r $BACKUP_PATH /etc/apache2 /var/www/html /var/www/glitchlinux.wtf -x "/var/www/glitchlinux.wtf/FILES/*"
    echo "Backup created at $BACKUP_PATH."
}

# Main menu
main_menu() {
    echo "Choose an option:"
    echo "[1] WEBSERVER UPDATE"
    echo "[2] UNDO LAST UPDATE"
    echo "[3] WEBSERVER STATUS"
    echo "[4] WEBSERVER RESTART"
    echo "[5] WEBSERVER BACKUP"   # local backup only
    echo "[6] WEBSERVER VERIFY"   # Checks Apache configuration
    echo "[7] WEBSERVER MIGRATE"  # Moves server to a new system
    echo "[8] WEBSERVER STOP"
    echo "[9] EXIT"

    read -p "Enter your choice: " choice

    case $choice in
        1) update_website ; main_menu ;;
        2) undo_last_update ; main_menu ;;
        3) check_apache_status ; main_menu ;;
        4) reboot_webserver ; main_menu ;;
        5) backup_webserver ; main_menu ;;
        6) verify_apache_config ; main_menu ;;
        7) migrate_webserver ; main_menu ;;
        8) stop_webserver ; main_menu ;;
        9) echo "Exiting script." ; exit 0 ;;
        *) echo "Invalid choice. Please try again." ; main_menu ;;
    esac
}

# Ask for root password at the start
ask_for_password

# Run the main menu
main_menu
