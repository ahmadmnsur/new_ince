#!/bin/bash
set -eo pipefail

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
MYSQL_ROOT_PASSWORD=$(read_password_file "$MYSQL_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(read_password_file "$MYSQL_PASSWORD_FILE")

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
fi

if [ ! -f "/var/lib/mysql/.configured" ]; then
    echo "Configuring MariaDB..."
    mysqld --user=mysql --bootstrap << EOSQL
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';

DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
    echo "MariaDB configured successfully"
    touch /var/lib/mysql/.configured
fi

exec "$@"
