#!/bin/bash
set -e

# Function to read password from file
read_password_file() {
    if [ -f "$1" ]; then
        cat "$1" | tr -d '\n'
    else
        echo "Error: Password file $1 not found" >&2
        exit 1
    fi
}

# Read passwords from files
MYSQL_PASSWORD=$(read_password_file "$MYSQL_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(read_password_file "$WP_ADMIN_PASSWORD_FILE")
WP_USER_PASSWORD=$(read_password_file "$WP_USER_PASSWORD_FILE")

# Fix permissions for bind mount
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

if [ ! -f wp-config.php ]; then
    echo "WordPress not found. Downloading..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create         --dbname=${MYSQL_DATABASE}         --dbuser=${MYSQL_USER}         --dbpass=${MYSQL_PASSWORD}         --dbhost=mariadb:3306         --allow-root
    
    echo "Waiting for database connection..."
    until wp db check --allow-root; do
        echo "Waiting for database..."
        sleep 3
    done
    
    echo "Installing WordPress..."
    wp core install         --url=${WP_URL}         --title="${WP_TITLE}"         --admin_user=${WP_ADMIN_USER}         --admin_password=${WP_ADMIN_PASSWORD}         --admin_email=${WP_ADMIN_EMAIL}         --allow-root
    
    echo "Creating additional user..."
    wp user create ${WP_USER} ${WP_USER_EMAIL}         --user_pass=${WP_USER_PASSWORD}         --role=author         --allow-root
    
    echo "WordPress setup complete!"
    
    # Final permission fix
    chown -R www-data:www-data /var/www/html
fi

# Always ensure correct URLs are set
echo "Updating WordPress URLs..."
wp option update siteurl "${WP_URL}" --allow-root
wp option update home "${WP_URL}" --allow-root

# Execute PHP-FPM as root so it can properly manage www-data workers
exec "$@"
