<?php
define( 'DB_NAME', '${MYSQL_DATABASE}' );
define( 'DB_USER', '${MYSQL_USER}' );
define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );
define( 'DB_HOST', '${DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         '+=;_zCjALJ%ZN~$u9}iFKKrW|Y.u1!Y6-vY##0Th3G6^3]oE&F=w+8LQ| |HQjUy' );
define( 'SECURE_AUTH_KEY',  '9SXLVKH!K_IIDr:E}uX=-%ax0!<i4A.u=#@(d|S+yJ(_-wCkdng::Ac];5iO!sYN' );
define( 'LOGGED_IN_KEY',    'sO9#Ucf&y8Ps3u+idwH)2,YnS:`yHD{ce8!1L.qj{+uvQ-U5IKPq8w~t<J9#O/>+' );
define( 'NONCE_KEY',        '~x352s1E0J|4mU?*V,,P{=]4b3wOp+FNH-]ekDzlHQ?lb}:_yAv}< !78}g@-Rs.' );
define( 'AUTH_SALT',        ');2hz3Rp+3Y~gS@lyr#|c%?dn;J@Ioj2gqAE B%zJb&-.5Mp:0ehJ%2O;!hZw*d=' );
define( 'SECURE_AUTH_SALT', 'Vk.O{^k< L^IIyAT2^*W7[*X(>H>m`}J[>ww^`cG- I+v:O?k56PC]TTkHe@?c+g' );
define( 'LOGGED_IN_SALT',   '|([6B-Ba$8eN`+e}em_8~tFH(^iagP/2+L!,^*hTxO_k?4n K:QRoYMesxAY &$J' );
define( 'NONCE_SALT',       'afF# MbDy-i>d}%H+Pnn^ H{S$:bM^0r>44qmequ%Hy{W?-- 9yo.e&gVYeQ5N[q' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';