#!/bin/bash

# Apache の設定とログディレクトリの確認
mkdir -p /var/log/apache2
chown www-data:www-data /var/log/apache2

# MovableType ディレクトリの権限設定
chown -R www-data:www-data /var/www/cgi-bin/mt
chown -R www-data:www-data /var/www/html/mt-static
chown -R www-data:www-data /var/www/html/uploads

# Apache を起動
exec apache2ctl -D FOREGROUND