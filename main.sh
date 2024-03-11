#!/bin/bash

# Function to check if a package is installed
package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to install a package
install_package() {
    echo "Installing $1..."
    sudo apt-get install -y "$1"
}

# Function to enable and start services
enable_service() {
    echo "Enabling and starting $1 service..."
    sudo systemctl enable "$1"
    sudo systemctl start "$1"
}

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install Git
if ! package_installed git; then
    install_package git
else
    echo "Git is already installed."
fi

# Install MariaDB
if ! package_installed mariadb-server; then
    install_package mariadb-server
    enable_service mariadb
else
    echo "MariaDB is already installed."
fi

# Install Apache
if ! package_installed apache2; then
    install_package apache2
    enable_service apache2
else
    echo "Apache is already installed."
fi

# Install PHP
if ! package_installed php; then
    install_package php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
else
    echo "PHP is already installed."
fi

# Install curl
if ! package_installed curl; then
    install_package curl
else
    echo "curl is already installed."
fi

# Validate PHP installation
echo "Validating PHP installation..."
php -v

# Configure Apache to support PHP extension
echo "Configuring Apache to support PHP extension..."
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /etc/apache2/mods-enabled/dir.conf
if [ ! -f "/etc/apache2/sites-available/devops-travel.conf" ]; then
    echo "Creating Apache configuration file for DevOps Travel application..."
    sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/devops-travel.conf
    sudo sed -i 's/\/var\/www\/html/\/var\/www\/html\/devops-travel/g' /etc/apache2/sites-available/devops-travel.conf
    sudo a2ensite devops-travel.conf
fi
sudo systemctl reload apache2

echo "Stage 1 (init) completed successfully."

# Define the repository URL
REPO_URL="https://github.com/ramiaguero/proyect2/tree/master/app-295devops-travel"

# Define the destination directory
DEST_DIR="/var/www/html/"

# Clone or pull the repository
if [ -d "$DEST_DIR" ]; then
    echo "Destination directory already exists."
    echo "Pulling latest changes from the repository..."
    cd "$DEST_DIR"
    if [ -d ".git" ]; then
        git pull origin master
    else
        echo "Error: Not a Git repository or Git repository not found."
    fi
else
    echo "Destination directory does not exist."
    echo "Cloning the repository..."
    git clone "$REPO_URL" "$DEST_DIR"
fi

# Test if the application code exists
if [ -d "$DEST_DIR" ]; then
    echo "Application code is successfully deployed."
else
    echo "Error: Application code deployment failed."
fi

# Adjust PHP config to support dynamic php files
echo "Adjusting PHP configuration..."
PHP_CONFIG_FILE="/etc/apache2/mods-enabled/dir.conf"
PHP_CONFIG_LINE="DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm"
sudo sed -i "s|^.*DirectoryIndex.*\$|$PHP_CONFIG_LINE|" "$PHP_CONFIG_FILE"
echo "PHP configuration adjusted."

# Reload Apache
echo "Reloading Apache server..."
sudo systemctl reload apache2
echo "Apache server reloaded."

# Validate if the Apache service is running
APACHE_STATUS=$(systemctl is-active apache2)
if [ "$APACHE_STATUS" = "active" ]; then
    echo "Apache service is running."
else
    echo "Error: Apache service is not running."
    exit 1
fi

# Reload Apache server
echo "Reloading Apache server..."
sudo systemctl reload apache2
echo "Apache server reloaded."

# Access the DevOps Travel application
echo "Accessing the DevOps Travel application..."
curl -s -o /dev/null http://localhost && echo "Application is available for end users." || echo "Error: Application is not available for end users."


# Define variables
WEBHOOK_URL="https://discord.com/api/webhooks/1216807096176345188/jttU4wdLrdZtIklYcrfFhqHlOFMFzBUAFP72nmJ3IArm7LaPGUUfxqLqMAVK7_OKGcaP"

# Get the author of the last commit
AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null)

# Get the commit message
COMMIT=$(git log -1 --pretty=format:"%s" 2>/dev/null)

# Get the repository name
REPOSITORY=$(basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null)

if [ -z "$REPOSITORY" ]; then
    REPOSITORY="Unknown"
fi

# Define the status
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

# Define the message
MESSAGE="Author: $AUTHOR | Commit: $COMMIT | Repository: $REPOSITORY | Status: $STATUS"

# Send the message to Discord webhook
curl -H "Content-Type: application/json" -d "{\"content\":\"$MESSAGE\"}" $WEBHOOK_URL
