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

# Main menu
main_menu() {
    echo "Choose an option:"
    echo "[1] UPDATE WEBSITE"
    echo "[2] UNDO LAST UPDATE"
    echo "[3] WEBSERVER STATUS"
    echo "[4] WEBSERVER BACKUP"
    echo "[5] WEBSERVER VERIFY"  # Checks Apache configuration
    echo "[6] WEBSERVER MIGRATE"  # Moves server to a new system
    echo "[7] WEBSERVER STOP"
    echo "[8] EXIT"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            update_website
            main_menu
            ;;
        2)
            undo_last_update
            main_menu
            ;;
        3)
            check_apache_status
            main_menu
            ;;
        4)
            backup_webserver
            main_menu
            ;;
        5)
            verify_apache_config
            main_menu
            ;;
        6)
            migrate_webserver
            main_menu
            ;;
        7)
            stop_webserver
            main_menu
            ;;
        8)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            main_menu
            ;;
    esac
}

# Ask for root password at the start
ask_for_password

# Run the main menu
main_menu
