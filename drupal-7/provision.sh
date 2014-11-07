#!/bin/bash

# Install Drupal 7 Development Environment

# update apt
sudo apt-get update -y

# install development tools
sudo apt-get install curl git vim -y

# apache 
sudo apt-get install apache2 -y
sudo a2enmod rewrite
sudo awk '/<Directory \/var\/www\/>/,/AllowOverride None/{sub("None", "All",$0)}{print}' /etc/apache2/sites-available/default > /tmp/default
sudo mv /tmp/default /etc/apache2/sites-available/default

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
composer global require drush/drush:6.*

# download and install Drupal
cd /var/www
rm -f index.html
drush dl drupal
cd drupal-7.32
drush site-install --account-pass=admin --db-url=mysql://root:$1@localhost/d7 -y

# Restart MySQL and Apache.
sudo service mysql restart
sudo service apache2 restart

