#!/bin/bash

#
#   Actualizar
#

echo -e "\n--- Actualizando el indice de paquetes ---\n"

sudo apt-get update
sudo apt-get upgrade -y

#
#   Apache
#

echo -e "\n--- Instalando Apache2 ---\n"

sudo apt-get install -y apache2

#
#   PHP
#

echo -e "\n--- Instalando PHP 8.1 ---\n"

sudo apt-get install -y software-properties-common
sudo apt-get install -y language-pack-en-base
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt install -y php8.1 libapache2-mod-php8.1 php8.1-common php8.1-mbstring php8.1-xmlrpc php8.1-soap \
    php8.1-gd php8.1-xml php8.1-intl php8.1-mysql php8.1-cli php8.1-mcrypt php8.1-zip php8.1-curl php8.1-xdebug

echo -e "\n--- Configurando PHP 8.1 ---\n"
sed -i 's/max_execution_time = .*/max_execution_time = 60/' /etc/php/8.1/apache2/php.ini
sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/8.1/apache2/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 1G/' /etc/php/8.1/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.1/apache2/php.ini

echo -e "\n--- Creando Virtual Host ---\n"

VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerName local.dev
    ServerAlias www.local.dev
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

echo -e "\n--- Creando info.php ---\n"

sudo rm /var/www/html/info.php
sudo touch /var/www/html/info.php
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

echo -e "\n--- Activando mod_rewrite ---\n"

sudo a2enmod rewrite

echo -e "\n--- Reiniciando Apache ---\n"

sudo service apache2 restart

#
#   MySQL
#

echo -e "\n--- Instalando MySQL ---\n"

PASSWORD='akua'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server

# Permite acceso remoto
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service

echo -e "\n--- Reiniciando MySQL ---\n"

#
#   phpMyadmin
#

echo -e "\n--- Instalando phpMyAdmin ---\n"

sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

#
#   Adminer 4.8.1
#

echo -e "\n--- Instalando adminer ---\n"

wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php
mv adminer-4.8.1-mysql-en.php /var/www/html/adminer.php

#
#   Git
#

echo -e "\n--- Instalando GIT ---\n"

sudo apt-get -y install git

#
#   Composer
#

echo -e "\n--- Instalando Composer ---\n"

curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#
#   ngrok
#

echo -e "\n--- Instalando Ngrok ---\n"

sudo snap install ngrok 
ngrok authtoken 1h0idkeM9Bk2X4MfAjnxSdlrQTx_7xLtZNdAesFWF6araXd35

#
#   Finalizando
#

echo -e "\n--- Limpiamos ---\n"

sudo apt-get autoremove

echo -e "\n--- Hecho ---\n"