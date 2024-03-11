#!/bin/bash

# Function to reinstall PHP
reinstall_php() {
    echo "Reinstalling PHP..."
    sudo apt-get install --reinstall php
}

# Function to check if PHP module is available and enable it if necessary
enable_php_module() {
    echo "Checking PHP module..."
    if ! sudo a2query -m php8.1 > /dev/null 2>&1; then
        echo "PHP module not available. Enabling it..."
        if ! sudo a2enmod php8.1 > /dev/null 2>&1; then
            echo "ERROR: Module php8.1 does not exist!"
            exit 1
        fi
    else
        echo "PHP module is already enabled."
    fi
}

# Function to restart Apache server
restart_apache() {
    echo "Restarting Apache server..."
    sudo systemctl restart apache2
}

# Main function to execute all steps
main() {
    reinstall_php
    enable_php_module
    restart_apache
    echo "PHP configuration fixed."
}

# Execute the main function
main
