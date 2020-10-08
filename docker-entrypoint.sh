#!/bin/bash

set -e

# wait for the database to start
waitfordb() {
    HOST=${DB_HOST:-mariadb}
    PORT=${DB_PORT:-3306}
    echo "Connecting to ${HOST}:${PORT}"

    attempts=0
    max_attempts=30
    while [ $attempts -lt $max_attempts ]; do
        busybox nc -w 1 "${HOST}:${PORT}" && break
        echo "Waiting for ${HOST}:${PORT}..."
        sleep 1
        let "attempts=attempts+1"
    done

    if [ $attempts -eq $max_attempts ]; then
        echo "Unable to contact your database at ${HOST}:${PORT}"
        exit 1
    fi

    echo "Waiting for database to settle..."
    sleep 3
}


if expr "$1" : "web" 1>/dev/null || [ "$1" = "php-fpm" ]; then

    MONICADIR=/var/www/
    mkdir -p /var/www/monica
    cd /var/www/monica
    git clone https://github.com/monicahq/monica.git .
    cp /usr/local/bin/.env /var/www/monica/
    #sed 's/127.0.0.1/mariadb/g' .env
    #sed 's/homestead/root/gI' .env
    composer install --no-interaction --no-suggest --no-dev --ignore-platform-reqs
    npm install yarn
    npm install
    #npm run production
    php artisan key:generate
    #php artisan setup:production 
    php artisan migrate
    sudo chown -R www-data:www-data /var/www/monica

fi
echo "Thanks for using monica......................................................."

exec "$@"
