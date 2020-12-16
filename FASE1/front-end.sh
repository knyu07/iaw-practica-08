#!/bin/bash
set -x

#Actualizamos
apt update

#Instalamos apache
apt install apache2 -y

#Instalamos los módulos PHP
apt install php libapache2-mod-php php-mysql -y

#Reiniciamos el servicio de Apache
systemctl restart apache2

#Copiamos el archivo info.php a /var/www/html
cp /var/www/html

#Añadimos la URL del Wordpress
cd /var/www/html
wget http://wordpress.org/latest.tar.gz

#Descomprimimos el .tar.gz
tar -xzvf latest.tar.gz

#Eliminamos el tar.gz
rm latest.tar.gz

#Configuramos  el archivo de configuración de Wordpress
cd /var/www/html/wordpress
mv wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sed -i "s/username_here/$DB_USER/" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$IP_MYSQL_SERVER/" wp-config.php
