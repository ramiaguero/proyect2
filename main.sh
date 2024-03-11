#!/bin/bash

# Function to install required packages
install_packages() {
    local packages=("apache2" "php" "mariadb-server" "git" "curl")

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q $pkg; then
            sudo apt-get install -y $pkg
        else
            echo "$pkg is already installed."
        fi
    done
}

# Function to validate installation
validate_installation() {
    local services=("apache2" "mysql" "php")
    local errors=0

    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet $service; then
            echo "Error: $service is not running."
            ((errors++))
        fi
    done

    if [ $errors -eq 0 ]; then
        echo "All services are running."
    else
        echo "There are errors. Please check the services."
    fi
}

# Function to clone or pull repository
clone_or_pull_repository() {
    local repo_url="https://github.com/ramiaguero/proyect2"
    local repo_dir="/var/www/html/devops-travel"
    
    if [ -d "$repo_dir/.git" ]; then
        echo "Repository exists. Pulling latest changes..."
        cd $repo_dir || exit
        git pull origin main
    else
        echo "Cloning repository..."
        sudo git clone $repo_url $repo_dir
    fi
}

# Function to move application code
move_application_code() {
    local repo_dir="/var/www/html/devops-travel"

    if [ -d "$repo_dir" ]; then
        echo "Moving application code to Apache directory..."
        sudo cp -r $repo_dir/* /var/www/html
    else
        echo "Error: Repository directory not found."
    fi
}

# Function to adjust PHP configuration
adjust_php_configuration() {
    echo "Adjusting PHP configuration..."

    # Check if dir.conf is properly enabled
    if [ ! -e /etc/apache2/mods-enabled/dir.conf ]; then
        echo "Enabling dir.conf..."
        sudo ln -s /etc/apache2/mods-available/dir.conf /etc/apache2/mods-enabled/dir.conf
    else
        echo "dir.conf is already enabled."
    fi

    # Update DirectoryIndex directive
    sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
}

# Function to reload Apache server
reload_apache_server() {
    echo "Reloading Apache server..."
    sudo systemctl reload apache2
}

# Function to test application
test_application() {
    echo "Testing application..."
    if curl -s http://localhost/info.php | grep -q "PHP Version"; then
        echo "Application test successful."
    else
        echo "Error: Application test failed."
    fi
}

# Function to send notification to Discord
send_discord_notification() {
    local webhook_url="$1"
    local author="$2"
    local commit_description="$3"
    local group="$4"
    local status="$5"
    
    local message="Commit by: $author\nDescription: $commit_description\nGroup: $group\nStatus: $status"
    
    echo "Sending Discord notification..."
    curl -X POST -H "Content-Type: application/json" -d "{\"content\":\"$message\"}" "$webhook_url" >/dev/null 2>&1
    echo "Discord notification sent."
}

# Main function
main() {
    install_packages
    validate_installation
    clone_or_pull_repository
    move_application_code
    adjust_php_configuration
    reload_apache_server
    test_application

    # Discord webhook details
    webhook_url="https://discord.com/api/webhooks/1216807096176345188/jttU4wdLrdZtIklYcrfFhqHlOFMFzBUAFP72nmJ3IArm7LaPGUUfxqLqMAVK7_OKGcaP"
    author="ramiaguero"
    commit_description="testing proyect"
    group="default"
    status="Deployment successful"

    # Send Discord notification
    send_discord_notification "$webhook_url" "$author" "$commit_description" "$group" "$status"
}

# Execute main function
main
