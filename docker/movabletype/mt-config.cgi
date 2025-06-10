# MovableType Configuration File

# データベース設定
Database mysql
DBHost mysql
DBName mt
DBUser mt
DBPassword movabletype

# 基本設定
CGIPath /cgi-bin/mt/
StaticWebPath /mt-static/
StaticFilePath /var/www/html/mt-static/

# アップロード設定
AssetBaseURL /uploads/
AssetBasePath /var/www/html/uploads/

# キャッシュ設定
MemcachedNamespace mt
MemcachedServers redis:6379

# セキュリティ設定
CookieSecret <%= ENV['MT_COOKIE_SECRET'] %>
DBUmask 0022

# 言語設定
DefaultLanguage ja

# メール設定
MailTransfer sendmail
SendMailPath /usr/sbin/sendmail

# デバッグ設定（本番環境では無効にしてください）
DebugMode 1

# その他の設定
PublishCharset utf-8
ImageDriver ImageMagick