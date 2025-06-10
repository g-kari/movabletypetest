FROM ubuntu:22.04

# 環境変数設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# 基本パッケージの更新とインストール
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    perl \
    libdbd-mysql-perl \
    libcgi-pm-perl \
    libfile-spec-perl \
    libcrypt-ssleay-perl \
    libmime-tools-perl \
    libmail-sendmail-perl \
    libimage-magick-perl \
    libxml-atom-perl \
    libxml-parser-perl \
    libsoap-lite-perl \
    libauthen-sasl-perl \
    libnet-smtp-ssl-perl \
    libio-socket-ssl-perl \
    libnet-ssleay-perl \
    libyaml-perl \
    libarchive-zip-perl \
    libdigest-sha-perl \
    libcache-memcached-perl \
    libredis-perl \
    libgd-perl \
    libjson-perl \
    libcrypt-cbc-perl \
    libcrypt-des-ede3-perl \
    php8.1 \
    libapache2-mod-php8.1 \
    php8.1-mysql \
    php8.1-gd \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-zip \
    curl \
    wget \
    unzip \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Apache モジュールの有効化
RUN a2enmod rewrite cgi perl php8.1 ssl headers

# MovableType 最新版のダウンロードとインストール
WORKDIR /tmp
RUN wget https://github.com/movabletype/movabletype/archive/refs/heads/develop.zip \
    && unzip develop.zip \
    && mv movabletype-develop /var/www/cgi-bin/mt \
    && chown -R www-data:www-data /var/www/cgi-bin/mt \
    && chmod -R 755 /var/www/cgi-bin/mt

# 静的ファイルディレクトリの作成
RUN mkdir -p /var/www/html/mt-static \
    && cp -r /var/www/cgi-bin/mt/mt-static/* /var/www/html/mt-static/ \
    && chown -R www-data:www-data /var/www/html/mt-static \
    && chmod -R 755 /var/www/html/mt-static

# アップロードディレクトリの作成
RUN mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 755 /var/www/html/uploads

# MovableType設定ファイルの作成
COPY docker/movabletype/mt-config.cgi /var/www/cgi-bin/mt/mt-config.cgi
RUN chown www-data:www-data /var/www/cgi-bin/mt/mt-config.cgi \
    && chmod 644 /var/www/cgi-bin/mt/mt-config.cgi

# Apache設定
COPY docker/apache/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/apache/conf-available/movabletype.conf /etc/apache2/conf-available/movabletype.conf
RUN a2enconf movabletype

# ポート公開
EXPOSE 80 443

# 起動スクリプト
COPY docker/movabletype/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]