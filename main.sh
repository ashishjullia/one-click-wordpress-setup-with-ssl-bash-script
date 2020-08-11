#!/bin/bash

#Specify the appropriate values to variables
WORDPRESS_ROOT_PASSWORD=password
WORDPRESS_DB_NAME=wordpress
WORDPRESS_USER=wordpressuser
WORDPRESS_USER_PASSWORD=password
WEBSITE_NAME=example.com
WEBSITE_NAME_WITH_WWW=www.example.com
EMAIL=your_email_id
#If you want, you can change the values for the variables below
CLIENT_MAX_BODY_SIZE_NGINX="client_max_body_size 256M;"
UPLOAD_MAX_FILESIZE_PHP="upload_max_filesize = 256M"
POST_MAX_SIZE_PHP="post_max_size = 256M"

#Install nginx and mysql-server
sudo apt update -y && sudo apt install -y nginx && sudo apt install -y mysql-server

#Setting up the mysql
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WORDPRESS_ROOT_PASSWORD';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

#Install php-fpm and php-mysql
sudo apt install -y php-fpm php-mysql

#Setting up the nginx by creating a new configuration file named as "website"
sudo touch /etc/nginx/sites-available/website
sudo cat default.conf > /etc/nginx/sites-available/website
sudo ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

#Setting up database for wordpress
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "CREATE DATABASE $WORDPRESS_DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
#sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "GRANT ALL ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_USER_PASSWORD';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "CREATE USER '$WORDPRESS_USER'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WORDPRESS_USER_PASSWORD';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_USER'@'localhost';"
sudo mysql -u root -p$WORDPRESS_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

#Installing required packages for php
sudo apt install -y php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

#Setting up nginx.conf file
sudo sed -i '55 s|#||' /etc/nginx/nginx.conf
sudo sed -i "23 a $CLIENT_MAX_BODY_SIZE_NGINX" /etc/nginx/nginx.conf

#Setting up php.ini file
sudo sed -i "s/upload_max_filesize = 2M/$UPLOAD_MAX_FILESIZE_PHP/g" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/$POST_MAX_SIZE_PHP/g" /etc/php/7.4/fpm/php.ini

sudo systemctl restart php7.4-fpm
sudo systemctl reload nginx

#Download latest wordpress
cd /tmp && curl -LO https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php

#Preparing wordpress
sudo cp -a /tmp/wordpress/. /var/www/html
sudo chown -R www-data:www-data /var/www/html

#Setting up wp-config.php for database
sudo sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$WORDPRESS_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$WORDPRESS_USER_PASSWORD/g" /var/www/html/wp-config.php
sudo sed -i '38 a define('FS_METHOD', 'direct');' /var/www/html/wp-config.php

#Securing wordpress
sudo curl http://api.wordpress.org/secret-key/1.1/salt/ > /var/www/html/wp_keys
sudo sed -i.bak -e '/AUTH_KEY/d' -e '/SECURE_AUTH_KEY/d' -e '/LOGGED_IN_KEY/d' -e '/NONCE_KEY/d' -e '/AUTH_SALT/d' -e '/SECURE_AUTH_SALT/d' -e '/LOGGED_IN_SALT/d' -e '/NONCE_SALT/d' /var/www/html/wp-config.php
sudo rm /var/www/html/wp_keys

#Setting up SSL for the domain
sudo add-apt-repository universe -y
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt update -y
sudo apt install -y certbot
sudo apt install -y certbot python3-certbot-nginx
sudo sed -i "s|server_name|server_name $WEBSITE_NAME $WEBSITE_NAME_WITH_WWW;|g" /etc/nginx/sites-available/website
sudo certbot --nginx --noninteractive --redirect --agree-tos --no-eff-email -m ${EMAIL} -d ${WEBSITE_NAME} -d ${WEBSITE_NAME_WITH_WWW}
