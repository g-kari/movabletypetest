-- MovableType データベース初期化スクリプト

-- データベースとユーザーが作成されていることを確認
USE mt;

-- 必要に応じて追加の初期化クエリをここに追加
-- 例: 文字セットの設定確認
ALTER DATABASE mt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- mtユーザーがmysql_native_passwordを使用するように設定
-- Docker環境では既にユーザーが作成されているので、認証プラグインを変更
ALTER USER 'mt'@'%' IDENTIFIED WITH mysql_native_password BY 'movabletype';
FLUSH PRIVILEGES;