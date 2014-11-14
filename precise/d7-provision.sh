#!/bin/bash

# Install Drupal 7 Development Environment

# Update apt
sudo apt-get update -y

# Install development tools:
sudo apt-get install curl git vim -y

# Install Apache:
sudo apt-get install apache2 -y

# Enable mod_rewrite
sudo a2enmod rewrite

# AllowOverride must be set to All to enable .htacess file
sudo awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' /etc/apache2/sites-available/default > /tmp/default
sudo mv /tmp/default /etc/apache2/sites-available/default

# Install MySQL and set default root password: 
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"
sudo apt-get install mysql-server -y

# Install PHP:
sudo apt-get install php5-common php5-dev libapache2-mod-php5 -y
sudo apt-get install php5-curl php5-mysql php5-gd php5-mcrypt -y

# Install Composer:
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
source $HOME/.bashrc

# Install Drush using Composer:
composer global require drush/drush:6.*

# Clear out any existing files from root web directory
sudo chmod -R u+w /var/www/
sudo find /var/www -name * -exec rm -f {} \;

# Use Drush to download and install Drupal 7
drush dl drupal --destination=/var/www --drupal-project-rename=d7
cd /var/www/d7
drush site-install --site-name="$2" --account-pass=admin --db-url=mysql://root:$1@localhost/d7 -y

# Restart MySQL and Apache:
sudo service mysql restart
sudo service apache2 restart

# Show the IP address this VM is using:
echo "Your Drupal 7 site is at: http://`ip addr show scope global eth1 | grep inet | cut -d' ' -f6 | cut -d/ -f1`/d7"
