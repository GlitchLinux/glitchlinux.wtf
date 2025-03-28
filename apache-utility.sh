#!/bin/bash

# Function to ask for root password (using sudo for subsequent commands)
ask_for_password() {
    sudo -v
}

# Function to check Apache status
check_apache_status() {
    systemctl status apache2
}

# Function to start Apache
start_webserver() {
    echo "Starting webserver..."
    sudo systemctl start apache2
    echo "Webserver started successfully."
}

# Function to update the website
update_website() {
    echo "Backing up current website files..."

    # Create backup directory if it doesn't exist
    sudo mkdir -p /etc/apache-undo/glitchlinux.wtf

    # Backup all files from glitchlinux.wtf except FILES directory
    echo "Backing up /var/www/glitchlinux.wtf to /etc/apache-undo/glitchlinux.wtf (excluding FILES)..."
    sudo rsync -a --exclude='FILES/' /var/www/glitchlinux.wtf/ /etc/apache-undo/glitchlinux.wtf/ --delete

    # Define temporary directory for cloning the repository
    TEMP_DIR="/tmp/glitchlinux.wtf"
    sudo rm -rf $TEMP_DIR  # Remove any existing temp directory
    sudo mkdir -p $TEMP_DIR
    cd $TEMP_DIR

    # Clone the GitHub repository
    echo "Cloning repository..."
    sudo git clone https://github.com/GlitchLinux/glitchlinux.wtf.git $TEMP_DIR

    # Copy all files from the repository to the website directory, excluding FILES
    echo "Updating website files (preserving FILES directory)..."
    sudo rsync -a --exclude='FILES/' $TEMP_DIR/ /var/www/glitchlinux.wtf/ --exclude=.git --exclude=README.md --delete

    # Set correct ownership and permissions for Apache to access the files
    sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/glitchlinux.wtf

    # Clean up the temporary directory
    sudo rm -rf $TEMP_DIR

    # Restart Apache to apply the changes
    sudo systemctl restart apache2

    # Confirm update
    echo "Website successfully updated, previous configuration has been saved (FILES directory preserved)!"
}

# Function to undo the last update
undo_last_update() {
    echo "Restoring the previous website configuration from backup (preserving FILES directory)..."

    # Check if backup exists
    if [ ! -d "/etc/apache-undo/glitchlinux.wtf" ]; then
        echo "Error: No backup found to restore!"
        return 1
    fi

    # Restore all files from backup except FILES directory
    sudo rsync -a --exclude='FILES/' /etc/apache-undo/glitchlinux.wtf/ /var/www/glitchlinux.wtf/ --delete

    # Set correct ownership and permissions
    sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/glitchlinux.wtf

    # Restart Apache to apply the changes
    sudo systemctl restart apache2

    # Confirm restoration
    echo "Previous configuration was successfully restored from backup (FILES directory preserved)."
}

# Function to reboot the webserver
reboot_webserver() {
    echo "Rebooting webserver..."
    sudo systemctl restart apache2
    echo "Webserver rebooted successfully."
}

# Function to backup webserver files
backup_webserver() {
    echo "Creating backup of webserver files (excluding FILES directory)..."
    BACKUP_PATH="/home/$USER/Desktop/Apache-Full-Backup.zip"
    
    # Create backup of both Apache config and website files, excluding FILES
    sudo zip -r $BACKUP_PATH /etc/apache2 /var/www/glitchlinux.wtf -x "/var/www/glitchlinux.wtf/FILES/*"
    
    echo "Backup created at $BACKUP_PATH (FILES directory excluded)."
}

# Function to verify Apache configuration
verify_apache_config() {
    echo "Verifying Apache configuration..."
    sudo apachectl configtest
}

# Function to stop the webserver
stop_webserver() {
    echo "Stopping webserver..."
    sudo systemctl stop apache2
    echo "Webserver stopped. You can start it using option [8]."
}

# Main menu
main_menu() {
    echo " "
    echo -e "\e[38;2;255;0;240mGLITCHLINUX.WTF\e[0m"	
    echo " "
    echo "Choose an option:"
    echo " "
    echo -e "[\e[38;2;255;0;240m1\e[0m] WEBSITE UPDATE"
    echo -e "[\e[38;2;255;0;240m2\e[0m] UNDO LAST UPDATE"
    echo -e "[\e[38;2;255;0;240m3\e[0m] APACHE STATUS"
    echo -e "[\e[38;2;255;0;240m4\e[0m] APACHE RESTART"
    echo -e "[\e[38;2;255;0;240m5\e[0m] CREATE BACKUP"
    echo -e "[\e[38;2;255;0;240m6\e[0m] SYNTAX VERIFY"
    echo -e "[\e[38;2;255;0;240m7\e[0m] APACHE STOP"
    echo -e "[\e[38;2;255;0;240m8\e[0m] APACHE START"
    echo -e "[\e[38;2;255;0;240m9\e[0m] EXIT"
    echo " "

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
            reboot_webserver
            main_menu
            ;;
        5)
            backup_webserver
            main_menu
            ;;
        6)
            verify_apache_config
            main_menu
            ;;
        7)
            stop_webserver
            main_menu
            ;;
        8)
            start_webserver
            main_menu
            ;;
        9)
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
