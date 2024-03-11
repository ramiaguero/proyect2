#!/bin/bash

# Stop Apache service if running
sudo systemctl stop apache2

# Remove Apache2 package
sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common

# Remove Apache configuration files and directories
sudo rm -rf /etc/apache2

# Remove Apache log files
sudo rm -rf /var/log/apache2

# Remove Apache web root directory
sudo rm -rf /var/www/html

# Remove any remaining Apache user and group
sudo deluser --remove-home www-data
sudo delgroup www-data
