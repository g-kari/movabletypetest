-- MovableType データベース初期化スクリプト

-- データベースとユーザーが作成されていることを確認
USE mt;

-- 必要に応じて追加の初期化クエリをここに追加
-- 例: 文字セットの設定確認
ALTER DATABASE mt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;