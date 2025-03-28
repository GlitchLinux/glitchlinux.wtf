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

    # Handle glitch-icon.zip if it exists in the repo
    if [ -f "$TEMP_DIR/glitch-icon.zip" ]; then
        echo "Processing glitch-icon.zip..."
        # Create target directory if it doesn't exist
        sudo mkdir -p /var/www/glitchlinux.wtf/glitch-icon
        # Unzip to target directory
        sudo unzip -o "$TEMP_DIR/glitch-icon.zip" -d /var/www/glitchlinux.wtf/glitch-icon/
        echo "glitch-icon.zip extracted successfully."
    fi

    # Copy apache-utility.sh to home directory if it exists
    if [ -f "/var/www/glitchlinux.wtf/apache-utility.sh" ]; then
        echo "Updating apache-utility.sh in home directory..."
        sudo cp -f /var/www/glitchlinux.wtf/apache-utility.sh /home/$USER/
        sudo chown $USER:$USER /home/$USER/apache-utility.sh
        sudo chmod +x /home/$USER/apache-utility.sh
        echo "apache-utility.sh updated in home directory."
    fi

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

# [Rest of the script remains exactly the same...]

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
    echo -e "[\e[38;2;255;0;240m7\e[0m] APACHE START"
    echo -e "[\e[38;2;255;0;240m8\e[0m] APACHE STOP"
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
            start_webserver
            main_menu
            ;;
        8)
            stop_webserver
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
