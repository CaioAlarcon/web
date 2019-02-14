#
# Install WordPress on a Debian/Ubuntu VPS
#
# Create MySQL database
read -p "Enter your MySQL root password: " rootpass
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser: " userpass
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "New MySQL database is successfully created"
# Download, unpack and configure WordPress
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www --transform s/wordpress/html/
chown www-data: -R /var/www/html && cd /var/www/html
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php
mkdir uploads
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php
# Create Apache virtual host
echo "
ServerName html
ServerAlias www.html
DocumentRoot /var/www/html
DirectoryIndex index.php
Options FollowSymLinks
AllowOverride All
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
" > /etc/apache2/sites-available/html
# Enable the site
a2ensite html
chown www-data:www-data /var/www/html
chmod -R  777 /var/www/html
service apache2 restart
# Output
WPVER=$(grep "wp_version = " /var/www/html/wp-includes/version.php |awk -F\' '{print $2}')
echo -e "\nWordPress version $WPVER is successfully installed!"
echo "Agora, antes de instalar o WP, muda a config do PHP para aumentar o upload e o POST"
php -i | grep "Loaded Configuration File"

