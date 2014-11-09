#!/bin/bash

# Install Drupal 8 Development Environment

# Update apt 
sudo apt-get update -y

# Install development tools
sudo apt-get install git debconf-utils curl vim -y > /dev/null

# Install Apache: 
sudo apt-get install apache2 apache2-mpm-prefork -y

# Enable mod_rewrite:
sudo a2enmod rewrite

# AllowOverride must be set to All to enable .htaccess
sudo cat <<EOF > /tmp/000-default.conf
<VirtualHost *:80>
  DocumentRoot /var/www/html
  <Directory />
    Options FollowSymLinks
    AllowOverride None
  </Directory>
  <Directory /var/www/html>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
sudo mv /tmp/000-default.conf /etc/apache2/sites-available/

# Install MySQL: 
echo "mysql-server mysql-server/root_password password $1" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $1" | sudo debconf-set-selections
sudo apt-get install mysql-server -y > /dev/null

# Install PHP: 
sudo apt-get install php5 php5-mcrypt php5-mysql php5-gd php5-curl -y > /dev/null
sudo apt-get install php5-common libapache2-mod-php5 -y

# Install Composer: 
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
source $HOME/.bashrc

# Install Drush using Composer:
composer global require drush/drush:dev-master

# Clear the web root directory
cd /var/www/html
sudo chmod -R u+w .
sudo rm -rf *
sudo rm -rf .* 2> /dev/null

# Clone the latest Drupal 8:
git clone --branch 8.0.x http://git.drupal.org/project/drupal.git html

# Use Drush to install Drupal 8:
cd html 
drush site-install --site-name="$2" --account-pass=admin --db-url=mysql://root:$1@localhost/d8 -y

# Restart MySQL and Apache:
sudo service mysql restart
sudo service apache2 restart

# Show the IP address this VM is using:
echo "Your Drupal 8 site is at: http://`ip addr show scope global eth1 | grep inet | cut -d' ' -f6 | cut -d/ -f1`"


