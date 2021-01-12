#!/bin/bash
set -x

#VARIABLES
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
IP_PUBLICA_BALANCEADOR=
IP_PRIVADA_MYSQL_SERVER=
IP_PRIVADA_FRONTEND_NFS_CLIENT=

#Actualizamos
apt update

#Instalamos apache
apt install apache2 -y

#Instalamos los módulos PHP
apt install php libapache2-mod-php php-mysql -y

#Copiamos el archivo info.php a /var/www/html
sudo cp /home/ubuntu/info.php /var/www/html

#Reiniciamos el servicio de Apache
systemctl restart apache2

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
sed -i "s/localhost/$IP_PRIVADA_MYSQL_SERVER/" wp-config.php

#Habilitamos las variables WP_SITEURL y WP_HOME
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'http://$IP_PUBLICA_BALANCEADOR/wordpress');" /var/www/html/wordpress/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'http://$IP_PUBLICA_BALANCEADOR');" /var/www/html/wordpress/wp-config.php

#Copiar el archivo wordpress /index.php a /var/www/html

cp /var/www/html/wordpress/index.php /var/www/html

#Editamos el archivo wordpress /index.php

sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php

#Habilitamos el módulo mod_rewrite de Apache

a2enmod rewrite

#Copiamos el archivo htaccess a /var/www/html
cd iaw-practica-8/FASE2
sudo cp htaccess /var/www/html/.htaccess

#Copiamos el archivo de configuración de Apache
cd iaw-practica-8/FASE2
sudo cp 000-default.conf /etc/apache2/sites-available/000-default.conf

#Reiniciamos Apache
systemctl restart apache2 

#Configuramos el archivo wp-config.php
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_SALT/d" /var/www/html/wordpress/wp-config.php

#Hacemos una llamada a la API de wordpress para obtener las security keys
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)

#Reemplaza el carácter / por el carácter _
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)

#Añadimos los security keys al archivo
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/wordpress/wp-config.php

# Eliminamos el archivo index.html del /var/www/html
rm -f /var/www/html/index.html

#Instalamos el servicio de NFS server
apt install nfs-kernel-server -y

#Cambiamos el propietario y el grupo al directorio /var/www/html
chown nobody:nogroup /var/www/html

#Configuramos el archivo /etc/exports
echo "/var/www/html/" $IP_PRIVADA_FRONTEND_NFS_CLIENT(rw,sync,no_root_squash,no_subtree_check) 

# Cambiamos el propietario y el grupo al directorio /var/www/html
chown www-data:www-data /var/www/html/ -R

#Reiniciamos el servicio de NFS
/etc/init.d/nfs-kernel-server restart

