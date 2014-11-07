#!/bin/bash

# Install Drupal 8 Development Environment

# update apt
# use ppa:ondrej/php5 for latest packages 
# https://launchpad.net/~ondrej/+archive/ubuntu/php5
sudo apt-get update -y
sudo apt-get install python-software-properties build-essential -y
sudo add-apt-repository ppa:ondrej/php5 -y
sudo apt-get update -y

# install development tools
sudo apt-get install curl git vim -y

# apache 
sudo apt-get install apache2 -y
sudo a2enmod rewrite
sudo sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html\n\t<Directory /var/www/html>\n\t\tAllowOverride All\n\t</Directory>#' /etc/apache2/sites-available/000-default.conf
#sudo awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' /etc/apache2/sites-available/default > /tmp/default
#sudo mv /tmp/default /etc/apache2/sites-available/default

# mysql
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"
sudo apt-get install mysql-server -y

# php
sudo apt-get install php5-common php5-dev libapache2-mod-php5 -y
sudo apt-get install php5-curl php5-mysql php5-gd php5-mcrypt php5-xdebug -y

# install Drupal tools
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
source $HOME/.bashrc
composer global require drush/drush:dev-master

# download and install Drupal
cd /var/www/html
rm -f index.html
drush dl drupal-8
cd drupal-8.0.0-beta2
drush site-install --account-pass=admin --db-url=mysql://root:$1@localhost/d8 -y

# Restart MySQL and Apache.
sudo service mysql restart
sudo service apache2 restart

