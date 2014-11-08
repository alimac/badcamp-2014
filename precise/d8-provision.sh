#!/bin/bash

# Install Drupal 8 Development Environment

# Update apt
# Use ppa:ondrej/php5 for latest PHP packages:
# https://launchpad.net/~ondrej/+archive/ubuntu/php5
sudo apt-get update -y
sudo apt-get install python-software-properties build-essential -y
sudo add-apt-repository ppa:ondrej/php5 -y
sudo apt-get update -y

# Install development tools:
sudo apt-get install curl git vim -y

# Install Apache:
sudo apt-get install apache2 apache2-mpm-prefork -y

# Enable mod_rewrite
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

# Install Drush:
composer global require drush/drush:dev-master

# Clear out any existing files from root web directory
sudo find /var/www -name * -exec rm -f {} \;

# Use Drush to download and install Drupal 8:
drush dl drupal-8 --destination=/var/www --drupal-project-rename=html
cd /var/www/html
drush site-install --site-name="$2" --account-pass=admin --db-url=mysql://root:$1@localhost/d8 -y

# Restart MySQL and Apache:
sudo service mysql restart
sudo service apache2 restart

# Show the IP address this VM is using:
echo "Your Drupal 8 site is at: http://`ip addr show scope global eth1 | grep inet | cut -d' ' -f6 | cut -d/ -f1`"
