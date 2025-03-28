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
    echo " "
    echo "Starting webserver..."
    sudo systemctl start apache2
    echo "Webserver started successfully."
    echo " "
}

# Function to stop Apache
stop_webserver() {
    echo " "
    echo "Stopping webserver..."
    sudo systemctl stop apache2
    echo "Webserver stopped."
    echo " "
}

# Function to restart Apache
reboot_webserver() {
    echo " "
    echo "Restarting webserver..."
    sudo systemctl restart apache2
    echo "Webserver restarted successfully."
    echo " "
}

# Function to backup webserver files
backup_webserver() {
    echo "Creating backup of webserver files (excluding FILES directory)..."
    BACKUP_PATH="/home/$USER/Desktop/Apache-Full-Backup.zip"
    sudo zip -r $BACKUP_PATH /etc/apache2 /var/www/glitchlinux.wtf -x "/var/www/glitchlinux.wtf/FILES/*"
    echo "Backup created at $BACKUP_PATH (FILES directory excluded)."
}

# Function to verify Apache configuration
verify_apache_config() {
    echo " "
    echo "Verifying Apache configuration..."
    echo " "
    sudo apachectl configtest
}

# Function to undo last update
undo_last_update() {
    echo "Restoring previous website configuration from backup..."
    if [ -d "/etc/apache-undo/glitchlinux.wtf" ]; then
        sudo rsync -a --exclude='FILES/' /etc/apache-undo/glitchlinux.wtf/ /var/www/glitchlinux.wtf/ --delete
        sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
        sudo systemctl restart apache2
        echo " "
        echo "Previous configuration restored successfully."
        echo " "
    else
        echo "Error: No backup found to restore!"
    fi
}

# Function to update the website
update_website() {
    echo "Backing up current website files..."
    sudo mkdir -p /etc/apache-undo/glitchlinux.wtf
    sudo rsync -a --exclude='FILES/' /var/www/glitchlinux.wtf/ /etc/apache-undo/glitchlinux.wtf/ --delete

    TEMP_DIR="/tmp/glitchlinux.wtf"
    sudo rm -rf $TEMP_DIR
    sudo mkdir -p $TEMP_DIR
    cd $TEMP_DIR

    echo "Cloning repository..."
    sudo git clone https://github.com/GlitchLinux/glitchlinux.wtf.git $TEMP_DIR

    echo "Updating website files..."
    sudo rsync -a --exclude='FILES/' $TEMP_DIR/ /var/www/glitchlinux.wtf/ --exclude=.git --exclude=README.md --delete

    if [ -f "$TEMP_DIR/glitch-icon.zip" ]; then
        echo "Processing glitch-icon.zip..."
        sudo mkdir -p /var/www/glitchlinux.wtf/glitch-icon
        sudo unzip -o "$TEMP_DIR/glitch-icon.zip" -d /var/www/glitchlinux.wtf/glitch-icon/
        echo "glitch-icon.zip extracted successfully."
    fi

    if [ -f "/var/www/glitchlinux.wtf/apache-utility.sh" ]; then
        echo "Updating apache-utility.sh in home directory..."
        sudo cp -f /var/www/glitchlinux.wtf/apache-utility.sh /home/$USER/
        sudo chown $USER:$USER /home/$USER/apache-utility.sh
        sudo chmod +x /home/$USER/apache-utility.sh
        echo "apache-utility.sh updated in home directory."
    fi

    sudo chown -R www-data:www-data /var/www/glitchlinux.wtf
    sudo chmod -R 755 /var/www/glitchlinux.wtf
    sudo rm -rf $TEMP_DIR
    sudo systemctl restart apache2
    echo "Website successfully updated, previous configuration has been saved!"
}

# Main menu
main_menu() {
    while true; do
        echo " "
        echo -e "\e[38;2;255;0;240mGLITCHLINUX.WTF\e[0m"
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
            1) update_website ;;
            2) undo_last_update ;;
            3) check_apache_status ;;
            4) reboot_webserver ;;
            5) backup_webserver ;;
            6) verify_apache_config ;;
            7) start_webserver ;;
            8) stop_webserver ;;
            9) echo "Exiting script."; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

ask_for_password
main_menu
