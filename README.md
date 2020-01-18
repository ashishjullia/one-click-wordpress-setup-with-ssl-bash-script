#  One Click Docker Wordpress LEMP Set-up (With SSL)
One click production website in wordpress with SSL <br>

In order to achieve the same, firstly clone/download this repository and after that follow the steps below:<br>

<strong>Note:</strong> All the settings mentioned below are made to <strong><em>main.sh</em></strong>.<br>

<strong>Step 1:</strong> Change the <strong><em>WORDPRESS_ROOT_PASSWORD</em></strong> as per your password requirments.<br>

<strong>Step 2:</strong> Change the <strong><em>WORDPRESS_DB_NAME</em></strong> as per your desired requirments.<br>

<strong>Step 3:</strong> Change the <strong><em>WORDPRESS_USER</em></strong> as per your requirments.<br>

<strong>Step 4:</strong> Change the <strong><em>WORDPRESS_USER_PASSWORD</em></strong> as per your requirments.<br>

<strong>Step 5:</strong> Change the <strong><em>WEBSITE_NAME</em></strong> as per your requirments.<br>

<strong>Step 6:</strong> Change the <strong><em>WEBSITE_NAME_WITH_WWW</em></strong> as per your requirments.<br>

<strong>Step 7:</strong> Change the <strong><em>EMAIL</em></strong> as per your requirments.<br>

For further configurations, you can also change the following variable values for "PHP" and "NGINX" configurations.<br>

<strong>Step 8:</strong> Change the <strong><em>CLIENT_MAX_BODY_SIZE_NGINX</em></strong> as per your needs.<br>

<strong>Step 9:</strong> Change the <strong><em>UPLOAD_MAX_FILESIZE_PHP</em></strong> as per your needs.<br>

<strong>Step 10:</strong> Change the <strong><em>POST_MAX_SIZE_PHP</em></strong> as per your needs.<br>

After doing all the steps, make sure you have the <strong><em>docker</em></strong> installed.<br>

After that, you just have to run the following commands:<br>

<strong>Note:</strong> The commands are only to work from the cloned repository directory, also in which <strong><em>main.sh</em></strong> and <strong><em>default.conf</em></strong> are present.

<strong>Command:</strong> sudo docker-compose up -d
