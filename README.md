# Dockerize your wordpress website

## Step 0: Prerequisites

1. Your already has a mysql server that act as this wordpress database
2. Inside the wp-config.php, setup the connection to your mysql server

```
<?php

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'your_db_name');

/** Database username */
define('DB_USER', 'your_db_user');

/** Database password */
define('DB_PASSWORD', 'your_db_password');

/** Database hostname */
define('DB_HOST', 'your_db_host');

/** Database charset to use in creating database tables. */
define('DB_CHARSET', 'utf');

/** The database collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define('WP_DEBUG', false);

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

```

3. Replace the the content of `wordpress` folder to your own custom wordpress.

## Step 1: Build and Run Your Wordpress container

Run the following command to build your wordpress image

```
docker build -t your-custom-wordpress .
```

After the image is built, use this command to run the docker compose

```
docker-compose up -d
```

You can access your wordpress in port 8000, the port number can be changed in `docker-compose.yaml` file.

At this point, you can use your custom wordpress through localhost (assuming your machine has access to the remote database)

## Step 2: Setup HTTPS on your domain name

If you want to migrate the wordpress to another server and dockerize it, you can do the following.

In your host server nginx, add this server block to your nginx.conf, replace _your_domain.com_ with your own domain

```
server {
    server_name your_domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header    Host                $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto   $scheme;
        proxy_set_header    Accept-Encoding     "";
        proxy_set_header    Proxy               "";
    }
}
```

Relaod the nginx

```
sudo systemctl reload nginx
```

Secure your domain using certbot

```
sudo certbot --nginx -d yourdomain.com
```

Inside `nginx-conf/nginx.conf`, replace the server_name with your domain.name

```
server {
        listen 80;
        listen [::]:80;

        client_max_body_size 20M;

        server_name yourdomain.com; # replace _ with yourdomain.com

        index index.php index.html index.htm;

        root /var/www/html;

        location ~ /.well-known/acme-challenge {
                allow all;
                root /var/www/html;
        }

        location / {
                try_files $uri $uri/ /index.php$is_args$args;
        }

        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass wordpress:9000;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param PATH_INFO $fastcgi_path_info;
        }

        location ~ /\.ht {
                deny all;
        }

        location = /favicon.ico {
                log_not_found off; access_log off;
        }
        location = /robots.txt {
                log_not_found off; access_log off; allow all;
        }
        location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
                expires max;
                log_not_found off;
        }
}
```

After that, you have successfully dockerized your wordpress website.

### Troubleshooting

If after setting up https://your_domain.com keeping redirect 301 to itself, add `$_SERVER['HTTPS'] = 'on';` into your `wp-config.php`.
