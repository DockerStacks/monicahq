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
    #Create an empty document root folder where Monica should be installed.
    mkdir -p /var/www/monica
    #Navigate to the document root folder.
    cd /var/www/monica
    #Clone the Monica repository to it.
    git clone https://github.com/monicahq/monica.git .
    #Run the following to create your own version of the environment variables needed for the project.
    cp /usr/local/bin/.env /var/www/monica/
    #sed 's/127.0.0.1/mariadb/g' .env
    #sed 's/homestead/root/gI' .env
    #Install all packages.
    composer install --no-interaction --no-suggest --no-dev --ignore-platform-reqs
    #Install all the front-end dependencies and tools needed to compile assets.
    npm install yarn
    npm install
    #Generate an application key. This will set APP_KEY to the correct value automatically.
    php artisan key:generate
    #Run the migrations and seed the database and symlink folders. 
    php artisan migrate
    #Change ownership of the /var/www/monica directory to www-data.
    sudo chown -R www-data:www-data /var/www/monica

fi
echo "Thanks for using monica......................................................."

exec "$@"
