#!/bin/bash

# Function to ask for root password (using sudo for subsequent commands)
ask_for_password() {
    sudo -v
}

# Function to check Apache status
check_apache_status() {
    systemctl status apache2
}

# Function to update the website
update_website() {
    echo "Backing up current website files..."

    # Ensure backup directories exist
    sudo mkdir -p /etc/apache-undo/html/html
    sudo mkdir -p /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf

    # Backup only files, not directories
    sudo cp /var/www/html/index.html /etc/apache-undo/html/html/index.html
    sudo cp /var/www/html/styles.css /etc/apache-undo/html/html/styles.css
    sudo cp /var/www/glitchlinux.wtf/index.html /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/index.html
    sudo cp /var/www/glitchlinux.wtf/styles.css /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/styles.css

    # Define temporary directory for cloning the repository
    TEMP_DIR="/tmp/glitchlinux.wtf"
    sudo rm -rf $TEMP_DIR  # Remove any existing temp directory
    sudo mkdir -p $TEMP_DIR
    cd $TEMP_DIR

    # Clone the GitHub repository
    sudo git clone https://github.com/GlitchLinux/glitchlinux.wtf.git $TEMP_DIR

    # Overwrite existing files with new ones if they exist
    if [[ -f "$TEMP_DIR/index.html" ]]; then
        sudo cp $TEMP_DIR/index.html /var/www/html/index.html
        sudo cp $TEMP_DIR/index.html /var/www/glitchlinux.wtf/index.html
    else
        echo "Error: index.html not found!"
    fi

    if [[ -f "$TEMP_DIR/styles.css" ]]; then
        sudo cp $TEMP_DIR/styles.css /var/www/html/styles.css
        sudo cp $TEMP_DIR/styles.css /var/www/glitchlinux.wtf/styles.css
    else
        echo "Error: styles.css not found!"
    fi

    # Clean up the temporary directory
    sudo rm -rf $TEMP_DIR

    # Set correct ownership and permissions for Apache to access the files
    sudo chown -R www-data:www-data /var/www/html
    sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/html
    sudo chmod -R 755 /var/www/glitchlinux.wtf

    # Restart Apache to apply the changes
    sudo systemctl restart apache2

    # Confirm update
    echo "Website successfully updated, previous configuration has been saved!"
}

# Function to undo the last update
undo_last_update() {
    echo "Restoring the previous website configuration from backup..."

    # Check if backup files exist before restoring
    if [[ ! -f "/etc/apache-undo/html/html/index.html" || ! -f "/etc/apache-undo/html/html/styles.css" ]]; then
        echo "No backup files exist"
        main_menu  # Prompt back to menu
    fi

    if [[ ! -f "/etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/index.html" || ! -f "/etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/styles.css" ]]; then
        echo "No backup files exist"
        main_menu  # Prompt back to menu
    fi

    # Restore files if they exist
    sudo cp /etc/apache-undo/html/html/index.html /var/www/html/index.html
    sudo cp /etc/apache-undo/html/html/styles.css /var/www/html/styles.css
    sudo cp /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/index.html /var/www/glitchlinux.wtf/index.html
    sudo cp /etc/apache-undo/glitchlinux.wtf/glitchlinux.wtf/styles.css /var/www/glitchlinux.wtf/styles.css

    # Set correct ownership and permissions
    sudo chown -R www-data:www-data /var/www/html
    sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/html
    sudo chmod -R 755 /var/www/glitchlinux.wtf

    # Restart Apache to apply the changes
    sudo systemctl restart apache2

    # Confirm restoration
    echo "Previous configuration was successfully restored from backup."
}

# Main menu
main_menu() {
    echo "Choose an option:"
    echo "[1] UPDATE WEBSITE"
    echo "[2] UNDO LAST UPDATE"
    echo "[3] WEBSERVER STATUS"
    echo "[4] EXIT"

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
