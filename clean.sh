#!/bin/bash

# Remove existing Apache configuration and application files
remove_existing_data() {
    echo "Removing existing Apache configuration and application files..."
    sudo rm -rf /etc/apache2/sites-available/* /etc/apache2/sites-enabled/* /var/www/html/*
}

# Main function
main() {
    remove_existing_data
    echo "Cleanup complete. Ready to run the deployment script."
}

# Execute main function
main
