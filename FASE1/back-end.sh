#!/bin/bash
set -x

#VARIABLES
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
IP_PRIVADA_FRONTEND="%"
IP_PRIVADA_BACK=

#Actualizamos
apt update

#Instalamos MySQL Server
apt install mysql-server -y

#Creamos la base de datos para wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u root <<< "CREATE DATABASE $DB_NAME;"
mysql -u root <<< "CREATE USER $DB_USER@'$IP_PRIVADA_FRONTEND' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_PRIVADA_FRONTEND';"
mysql -u root <<< "FLUSH PRIVILEGES;"

# Modificamos el valor de bind-address para permitir conexiones remotas
sed -i "s/127.0.0.1/$IP_PRIVADA_BACK/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciamos mysql
systemctl restart mysql
