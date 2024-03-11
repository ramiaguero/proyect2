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
sudo systemctl reload apache2

echo "Stage 1 (init) completed successfully."

# Step 1: Clone or pull the application repository
APP_REPO_URL="https://github.com/ramiaguero/proyect2.git"
APP_FOLDER="/var/www/html/devops-travel"

if [ ! -d "$APP_FOLDER" ]; then
    echo "Cloning application repository..."
    git clone "$APP_REPO_URL" "$APP_FOLDER"
else
    echo "Pulling latest changes from application repository..."
    cd "$APP_FOLDER"
    git pull origin master
fi

# Step 2: Move to the Apache configuration directory
APACHE_CONFIG_DIR="/etc/apache2/sites-available"

# Assuming your Apache configuration file is named devops-travel.conf
APACHE_CONFIG_FILE="$APACHE_CONFIG_DIR/devops-travel.conf"

# Assuming your Apache root directory is /var/www/html
APACHE_ROOT="/var/www/html"

# Step 3: Test the existence of the application code
if [ -d "$APP_FOLDER" ]; then
    echo "Application code found."
else
    echo "Error: Application code not found."
    exit 1
fi

# Step 4: Adjust PHP configuration
echo "Adjusting PHP configuration..."
echo "Adding index.php to DirectoryIndex directive..."

# Adjust the DirectoryIndex directive to prioritize index.php
sed -i 's/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g' "$APACHE_CONFIG_FILE"

# Step 5: Test compatibility
echo "Testing PHP compatibility..."
echo "<?php phpinfo(); ?>" > "$APACHE_ROOT/info.php"

# Step 6: Access PHP informational screen
echo "PHP info available at: http://localhost/info.php"
