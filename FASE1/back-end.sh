#!/bin/bash
set -x

#Actualizamos
apt update

#VARIABLES
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
IP_PRIVADA_FRONTEND=172.31.94.203
IP_MYSQL_SERVER=172.31.94.203

#Instalamos MySQL Server
apt install mysql-server -y

#Instalamos los módulos PHP
apt install php libapache2-mod-php php-mysql -y

#Creamos la base de datos para wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u root <<< "CREATE DATABASE $DB_NAME;"
mysql -u root <<< "CREATE USER $DB_USER@$IP_PRIVADA_FRONTEND IDENTIFIED BY '$DB_PASSWORD;'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@$IP_PRIVADA_FRONTEND;"
mysql -u root <<< "FLUSH PRIVILEGES;"