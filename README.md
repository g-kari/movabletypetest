# MovableType Docker環境

このプロジェクトは、MovableTypeをDocker環境で簡単に立ち上げるためのセットアップです。

## 📋 含まれる技術スタック

- **MovableType**: 最新の開発版 (Perl基盤のCMS)
- **MySQL**: 8.0 (データベース)
- **Apache**: 2.4 (Webサーバー)
- **PHP**: 8.1 (動的パブリッシング用)
- **Redis**: 7 (キャッシュシステム)
- **Node.js**: 18 (Vue.js開発環境)
- **Vue.js**: 3.3 (モダンフロントエンドフレームワーク)

## 🚀 クイックスタート

### 前提条件

- Docker Engine 20.10+
- Docker Compose 2.0+

### 🎯 **推奨**: 自動セットアップスクリプトを使用

最も簡単で確実な方法は、提供されている自動セットアップスクリプトを使用することです：

1. リポジトリをクローン:
```bash
git clone https://github.com/g-kari/movabletypetest.git
cd movabletypetest
```

2. **自動セットアップスクリプトを実行**:
```bash
./setup.sh
```

このスクリプトは以下を自動で行います：
- Docker サービスの起動
- Apache設定の修正（デフォルトページ問題の解決）
- MovableType設定の初期化
- データベースの初期化
- ShadowverseDeckBuilderプラグインの設定
- サンプルデータの挿入
- Vue.jsコンポーネントの修正

### 手動セットアップ（上級者向け）

自動セットアップを使わない場合：

1. Docker Composeで起動:
```bash
docker compose up -d
```

2. ブラウザでアクセス:
- MovableType管理画面: http://localhost:8080/mt/mt.cgi
- サイト: http://localhost:8080/

### 初回セットアップ

自動セットアップスクリプトを使用した場合：
- **管理画面**: http://localhost:8080/mt/mt.cgi
- **ユーザー名**: admin
- **パスワード**: password

手動セットアップの場合：
1. MovableType管理画面にアクセス
2. セットアップウィザードに従って設定
3. データベース接続情報:
   - データベースサーバー: `db`
   - データベース名: `movabletype`
   - ユーザー名: `movabletype`
   - パスワード: `password`

📋 **詳細なブラウザセットアップ手順**: `SETUP_GUIDE.md`の[ブラウザセットアップガイド](SETUP_GUIDE.md#🌐-ブラウザセットアップガイド)を参照してください。

## 🔧 サービス詳細

### MovableType (Webアプリケーション)
- **ポート**: 8080, 443
- **CGIパス**: `/cgi-bin/mt/`
- **静的ファイル**: `/mt-static/`
- **アップロード**: `/uploads/`

### MySQL (データベース)
- **ポート**: 3307
- **ルートパスワード**: `movabletype`
- **データベース**: `mt`
- **ユーザー**: `mt` / `movabletype`

### Redis (キャッシュ)
- **ポート**: 6380
- **永続化**: 有効

## 📁 ディレクトリ構造

```
movabletypetest/
├── docker compose.yml          # Docker Compose設定
├── docker/                     # Docker設定ファイル
│   ├── movabletype/
│   │   ├── Dockerfile          # MovableType用Dockerfile
│   │   ├── entrypoint.sh       # 起動スクリプト
│   │   └── mt-config.cgi       # MovableType設定
│   ├── apache/                 # Apache設定
│   │   ├── sites-available/
│   │   └── conf-available/
│   └── mysql/                  # MySQL初期化スクリプト
│       └── init/
├── mt/                         # MovableTypeファイル (自動配置)
├── mt-static/                  # 静的ファイル (自動配置)
├── themes/                     # Vue.jsテンプレート
│   └── vue-template/          # Vue.js対応テーマ
└── uploads/                    # アップロードファイル
```

## 🛠️ 開発・メンテナンス

### ログの確認

```bash
# 全サービスのログ
docker compose logs

# 特定のサービスのログ
docker compose logs movabletype
docker compose logs mysql
docker compose logs redis
```

### サービスの再起動

```bash
# 全サービス再起動
docker compose restart

# 特定のサービス再起動
docker compose restart movabletype
```

### データベースへの接続

```bash
# MySQLクライアントで接続
docker compose exec mysql mysql -u mt -p mt
```

### Redisの確認

```bash
# Redis CLIで接続
docker compose exec redis redis-cli
```

## 🔒 セキュリティ設定

本番環境で使用する場合は、以下の設定を変更してください:

1. **パスワードの変更**:
   - MySQL rootパスワード
   - MySQL mtユーザーパスワード
   - MovableType設定のCookieSecret

2. **デバッグモードの無効化**:
   - `docker/movabletype/mt-config.cgi` の `DebugMode 0` に変更

3. **HTTPS設定**:
   - SSL証明書の配置
   - Apache SSL設定の有効化

## 📝 カスタマイズ

### Vue.jsテンプレートの使用

Vue.js対応のモダンなテンプレートが利用可能です：

```bash
# Vue.jsテンプレートのビルド
cd themes/vue-template
./build.sh

# MovableType管理画面でテーマを適用
# デザイン > テンプレート > "Vue.js Template" を選択
```

詳細は [themes/vue-template/README.md](themes/vue-template/README.md) を参照してください。

### MovableType設定の変更

`docker/movabletype/mt-config.cgi` を編集後、コンテナを再起動してください:

```bash
docker compose restart movabletype
```

### Apache設定の変更

`docker/apache/` 以下の設定ファイルを編集後、コンテナを再起動してください:

```bash
docker compose restart movabletype
```

### プラグイン開発

MovableTypeプラグインの開発方法については、包括的な日本語ガイドを用意しています：

- **[MovableType プラグイン開発ガイド](MOVABLETYPE_PLUGIN_DEVELOPMENT_GUIDE.md)** - プラグイン開発の基礎から実践まで
- プラグインファイルは `mt/plugins/` ディレクトリに配置
- 実例として `ShadowverseDeckBuilder` と `CloudFrontClearCaches` プラグインを参照可能

## 🆘 トラブルシューティング

### 🔧 自動修復

問題が発生した場合は、まず自動セットアップスクリプトを再実行してください：

```bash
./setup.sh
```

### よくある問題と解決方法

1. **Apacheデフォルトページが表示される**:
   - 📋 **解決法**: 自動セットアップスクリプトを実行
   - 手動修復: `docker-compose exec mt rm -f /var/www/html/index.html && docker-compose restart`

2. **"svdeckをロードできません" エラー**:
   - 📋 **解決法**: 自動セットアップスクリプトを実行
   - 原因: プラグイン設定の問題またはデータベーステーブル未作成

3. **Vue.js deck builder component failed to load**:
   - 📋 **解決法**: 自動セットアップスクリプトを実行（Vue.js依存を解決した軽量版に置き換え）
   - 代替方法: 手動でのカード入力機能を使用

4. **ポート競合エラー**:
   - 他のサービスがポート8080、3307、6380を使用していないか確認
   - `docker ps` で使用中のポートを確認

5. **権限エラー**:
   - `uploads/` ディレクトリの権限を確認
   - `docker-compose exec mt chown -R www-data:www-data /var/www/html`

6. **データベース接続エラー**:
   - MySQLサービスが起動しているか確認: `docker-compose logs db`
   - サービス再起動: `docker-compose restart db`

### 🚨 完全リセット方法

全データを削除して初期状態に戻す:

```bash
docker-compose down -v
docker system prune -f
./setup.sh
```

### 🔍 詳細ログの確認

```bash
# 全サービスのログ
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f mt
docker-compose logs -f db

# MovableTypeエラーログ
docker-compose exec mt tail -f /tmp/mt.log
```

### 💡 追加のヘルプ

問題が解決しない場合：
1. `docker-compose ps` でサービス状態を確認
2. `docker-compose exec mt ls -la /var/www/html` でファイル権限を確認
3. `docker-compose exec db mysql -u movabletype -ppassword movabletype -e "SHOW TABLES;"` でデータベーステーブルを確認

## 📜 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
MovableType自体は Six Apart社の製品であり、別途ライセンスが適用されます。

## 🤝 コントリビューション

プルリクエストや Issue の報告を歓迎します。

---

## 🔗 関連リンク

### プロジェクト関連ドキュメント
- [MovableType プラグイン開発ガイド](MOVABLETYPE_PLUGIN_DEVELOPMENT_GUIDE.md) - 包括的なプラグイン開発日本語ドキュメント
- [セットアップガイド](SETUP_GUIDE.md) - 詳細なセットアップ手順
- [Shadowverse プラグインガイド](SHADOWVERSE_PLUGIN_GUIDE.md) - 実践的なプラグイン開発例

### 公式ドキュメント
- [MovableType公式サイト](https://www.movabletype.org/)
- [MovableType開発者ドキュメント](https://www.movabletype.org/documentation/)
- [Docker公式ドキュメント](https://docs.docker.com/)