# MovableType Docker環境 セットアップガイド

## 🎯 概要

このプロジェクトは、MovableTypeを最新のDocker環境で簡単にセットアップできるように設計されています。

### 🏗️ アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MovableType   │    │     MySQL       │    │     Redis       │
│  (Apache+Perl)  │◄──►│   Database      │    │     Cache       │
│     :8080       │    │     :3307       │    │     :6380       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/g-kari/movabletypetest.git
cd movabletypetest
```

### 2. 環境の起動
```bash
# 方法 1: 便利スクリプトを使用
./start.sh

# 方法 2: Docker Composeを直接使用
docker compose up -d

# 方法 3: Makeを使用
make start
```

### 3. MovableTypeのセットアップ
1. ブラウザで http://localhost:8080/cgi-bin/mt/mt.cgi にアクセス
2. セットアップウィザードを開始
3. データベース設定を入力:
   - データベースサーバー: `mysql`
   - データベース名: `mt`
   - ユーザー名: `mt`
   - パスワード: `movabletype`

## 📊 サービス詳細

### MovableType Web サーバー
- **ポート**: 8080 (HTTP), 443 (HTTPS対応)
- **管理画面**: http://localhost:8080/cgi-bin/mt/mt.cgi
- **サイト**: http://localhost:8080/
- **技術**: Apache 2.4 + Perl + PHP 8.1

### MySQL データベース
- **ポート**: 3307
- **データベース**: mt
- **ユーザー**: mt / movabletype
- **管理者**: root / movabletype

### Redis キャッシュ
- **ポート**: 6380
- **用途**: MovableTypeのキャッシング
- **永続化**: 有効

## 🛠️ 開発・運用コマンド

### 基本操作
```bash
# 起動
make start              # または ./start.sh

# 停止
make stop               # または ./stop.sh

# 再起動
make restart

# ログ確認
make logs

# ステータス確認
docker compose ps
```

### デバッグ・メンテナンス
```bash
# MySQLに接続
make dev-mysql

# Redisに接続
make dev-redis

# MovableTypeコンテナに入る
make dev-shell

# 完全リセット（データも削除）
make reset
```

### イメージ管理
```bash
# イメージ再ビルド
make build

# 環境削除（イメージも削除）
make clean
```

## 📁 ディレクトリ構造

```
movabletypetest/
├── docker-compose.yml          # Docker Compose設定
├── Makefile                    # 開発用コマンド
├── start.sh / stop.sh          # 便利スクリプト
├── test.sh                     # 環境テストスクリプト
├── README.md                   # メインドキュメント
├── SETUP_GUIDE.md             # このファイル
│
├── docker/                     # Docker設定
│   ├── movabletype/
│   │   ├── Dockerfile          # MovableType環境
│   │   ├── entrypoint.sh       # 起動スクリプト
│   │   └── mt-config.cgi       # MovableType設定
│   ├── apache/                 # Apache設定
│   │   ├── sites-available/
│   │   └── conf-available/
│   └── mysql/                  # MySQL設定
│       └── init/
│
├── mt/                         # MovableTypeファイル（自動生成）
├── mt-static/                  # 静的ファイル（自動生成）
└── uploads/                    # アップロードファイル
```

## ⚙️ カスタマイズ

### MovableType設定の変更

`docker/movabletype/mt-config.cgi` を編集:

```perl
# 例: デバッグモードを無効化（本番環境推奨）
DebugMode 0

# 例: 言語設定変更
DefaultLanguage en
```

設定変更後は再起動:
```bash
docker compose restart movabletype
```

### Apache設定の変更

- バーチャルホスト: `docker/apache/sites-available/000-default.conf`
- MovableType設定: `docker/apache/conf-available/movabletype.conf`

### MySQL設定の変更

- 初期化スクリプト: `docker/mysql/init/01-init.sql`
- 環境変数: `docker-compose.yml` の mysql サービス

## 🔒 セキュリティ

### 本番環境での推奨設定

1. **パスワード変更**
   ```yaml
   # docker-compose.yml
   environment:
     MYSQL_ROOT_PASSWORD: your_secure_password
     MYSQL_PASSWORD: your_secure_password
   ```

2. **デバッグモード無効化**
   ```perl
   # docker/movabletype/mt-config.cgi
   DebugMode 0
   ```

3. **HTTPS設定**
   - SSL証明書の配置
   - Apache SSL設定の有効化

4. **ポート制限**
   ```yaml
   # docker-compose.yml - 外部アクセス制限例
   ports:
     - "127.0.0.1:3307:3306"  # ローカルホストのみ
   ```

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. ポート競合エラー
```bash
# エラー: port is already allocated
# 解決: 使用中のサービスを確認
sudo netstat -tulpn | grep :8080
sudo netstat -tulpn | grep :3307
sudo netstat -tulpn | grep :6380
```

#### 2. 権限エラー
```bash
# MovableTypeファイルの権限を修正
sudo chown -R $(whoami):$(whoami) mt/ mt-static/ uploads/
chmod -R 755 mt/ mt-static/ uploads/
```

#### 3. データベース接続エラー
```bash
# MySQLサービスの状態確認
docker compose logs mysql

# MySQL接続テスト
docker compose exec mysql mysql -u mt -p mt
```

#### 4. MovableTypeが表示されない
```bash
# Apacheの状態確認
docker compose logs movabletype

# CGIファイルの権限確認
docker compose exec movabletype ls -la /var/www/cgi-bin/mt/
```

### ログの確認方法

```bash
# 全サービスのログ
docker compose logs

# 特定のサービスのログ
docker compose logs movabletype
docker compose logs mysql
docker compose logs redis

# リアルタイムログ
docker compose logs -f
```

### 完全リセット手順

```bash
# 1. 全サービス停止
docker compose down

# 2. 全ボリューム削除（データも削除される）
docker compose down -v

# 3. イメージも削除
docker compose down -v --rmi all

# 4. 再起動
./start.sh
```

## 🔧 開発者向け情報

### カスタムプラグインの追加

1. プラグインファイルを `mt/plugins/` に配置
2. 権限を設定: `chmod -R 755 mt/plugins/`
3. MovableTypeを再起動: `docker compose restart movabletype`

### テーマの追加

1. テーマファイルを `mt/themes/` に配置
2. 静的ファイルを `mt-static/themes/` に配置
3. MovableTypeを再起動

### バックアップの作成

```bash
# データベースバックアップ
docker compose exec mysql mysqldump -u mt -p mt > backup_$(date +%Y%m%d).sql

# ファイルバックアップ
tar -czf backup_files_$(date +%Y%m%d).tar.gz mt/ mt-static/ uploads/
```

### データの復元

```bash
# データベース復元
docker compose exec mysql mysql -u mt -p mt < backup_20240610.sql

# ファイル復元
tar -xzf backup_files_20240610.tar.gz
```

## 📞 サポート

問題が発生した場合:

1. このガイドのトラブルシューティングセクションを確認
2. `./test.sh` を実行して環境をテスト
3. GitHub Issues で問題を報告
4. [MovableType公式ドキュメント](https://www.movabletype.org/documentation/) を参照

---

## 🔗 関連リンク

- [MovableType公式サイト](https://www.movabletype.org/)
- [Docker公式ドキュメント](https://docs.docker.com/)
- [MySQL 8.0 ドキュメント](https://dev.mysql.com/doc/refman/8.0/en/)
- [Redis ドキュメント](https://redis.io/documentation)