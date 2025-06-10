#!/bin/bash

# Apache の設定とログディレクトリの確認
mkdir -p /var/log/apache2
chown www-data:www-data /var/log/apache2

# MovableType ファイルが空の場合、Docker イメージからコピー
if [ ! -f "/var/www/cgi-bin/mt/mt.cgi" ]; then
    echo "MovableType ファイルをコピーしています..."
    # Docker イメージ内のバックアップからコピー
    if [ -d "/tmp/movabletype-backup" ]; then
        cp -r /tmp/movabletype-backup/* /var/www/cgi-bin/mt/
    fi
fi

# MovableType ディレクトリの権限設定
chown -R www-data:www-data /var/www/cgi-bin/mt
chown -R www-data:www-data /var/www/html/mt-static
chown -R www-data:www-data /var/www/html/uploads

# Apache を起動
exec apache2ctl -D FOREGROUND