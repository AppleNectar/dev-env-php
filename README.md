# Docker environment for PHP application

Docker container stack for a web service development using PHP.  
The stack consists of Nginx / php-fpm / MySQL / Redis, each container is based on Debina.  
It's only for local development, please don't use it in a server environment (EC2, ECS, etc).

## Usage

1. Clone this repository.
2. Rename .env.example to .env and refer to the comment to set the value.
3. Create the app directory at the same level as the build directory.( `app` is mounted as `/var/www/html/app` )  
Do you want to change the document root under `app` directory?  
In that case, copy `/docker/web/conf/default.conf` to any location in your project directory, change the `root` directive, and bind-mount it as `/etc/nginx/conf.d/default.conf`.
4. Execute the `docker compose up -d` command.
5. Create an `index.php` file and put `<?php php phpinfo();` to file in the `app` directory of your project root, and access `https://localhost:8443` from your browser! (Please ignore the certificate error as it is due to self-certification and continue)
5. Let's develop it freely!:)

## Containers detail

- Use a common TimeZone for all containers (this can be specified in `.env`)
- In the `app` and `web` containers, the system language is changed based on the `.env` configuration value.

### app
- Use the official image of PHP 8.0
- Xdebug extension is valid (Listen on port `9003` | Default ide key `IDEKEY` | Start with request trigger)
- PHP's extension that Laravel depends on is installed
- Composer is installed in system global (from composer official image)
- If you want to change php settings, bind mount any `php.ini` to `/usr/local/etc/php/php.ini`
- If you want to change php-fpm settings, mount any `zzz-www.conf` to `/usr/local/etc/php-fpm.d/zzz-www.conf`
- The `app` directory in the project root will be bind mounted as `/var/www/html/app`

### web
- Use the official image of Nginx 1.21
- SSL with self-certificate for localhost is valid (Automatic generation of certificate files by `mkcert`)
- Cooperation with php-fpm container is valid (Communicate with php-fpm on TCP port 9000)
- If you want to change nginx settings, bind mount any `default.conf` to `/etc/nginx/conf.d/default.conf`, `nginx.conf` to `/etc/nginx/nginx.conf`
- The `app` directory in the project root will be bind mounted as `/var/www/html/app` (This is the default document root)

### db
- Use the official image of MySQL 8.0.26
- The root password, initial database name, default username, and user password are passed to the container as environment variables (The actual values are defined in the .env file)
- The data is persisted by `mysql-data` volume

### kvs
- Use the official image of redis 6.2.5
- This container does not persist data

### smtp
- Use the official image of mailhog 1.0.1
- It can be used as a destination for sending test mails via SMTP (open http://localhost:8025 to check the mail)
- The data is persisted by `mail-data` volume

## License
MIT