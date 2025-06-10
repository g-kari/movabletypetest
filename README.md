# MovableType Docker環境

このプロジェクトは、MovableTypeをDocker環境で簡単に立ち上げるためのセットアップです。

## 📋 含まれる技術スタック

- **MovableType**: 最新の開発版 (Perl基盤のCMS)
- **MySQL**: 8.0 (データベース)
- **Apache**: 2.4 (Webサーバー)
- **PHP**: 8.1 (動的パブリッシング用)
- **Redis**: 7 (キャッシュシステム)

## 🚀 クイックスタート

### 前提条件

- Docker Engine 20.10+
- Docker Compose 2.0+

### 起動方法

1. リポジトリをクローン:
```bash
git clone https://github.com/g-kari/movabletypetest.git
cd movabletypetest
```

2. Docker Composeで起動:
```bash
docker compose up -d
```

3. ブラウザでアクセス:
- MovableType管理画面: http://localhost:8080/cgi-bin/mt/mt.cgi
- サイト: http://localhost:8080/

### 初回セットアップ

1. MovableType管理画面にアクセス
2. セットアップウィザードに従って設定
3. データベース接続情報は以下の通り:
   - データベースサーバー: `mysql`
   - データベース名: `mt`
   - ユーザー名: `mt`
   - パスワード: `movabletype`

## 🔧 サービス詳細

### MovableType (Webアプリケーション)
- **ポート**: 8080, 443
- **CGIパス**: `/cgi-bin/mt/`
- **静的ファイル**: `/mt-static/`
- **アップロード**: `/uploads/`

### MySQL (データベース)
- **ポート**: 3306
- **ルートパスワード**: `movabletype`
- **データベース**: `mt`
- **ユーザー**: `mt` / `movabletype`

### Redis (キャッシュ)
- **ポート**: 6379
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

## 🆘 トラブルシューティング

### よくある問題

1. **ポート競合エラー**:
   - 他のサービスがポート8080、3306、6379を使用していないか確認

2. **権限エラー**:
   - `uploads/` ディレクトリの権限を確認

3. **データベース接続エラー**:
   - MySQLサービスが起動しているか確認
   - `docker compose logs mysql` でログを確認

### リセット方法

全データを削除して初期状態に戻す:

```bash
docker compose down -v
docker compose up -d
```

## 📜 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
MovableType自体は Six Apart社の製品であり、別途ライセンスが適用されます。

## 🤝 コントリビューション

プルリクエストや Issue の報告を歓迎します。

---

## 🔗 関連リンク

- [MovableType公式サイト](https://www.movabletype.org/)
- [MovableType開発者ドキュメント](https://www.movabletype.org/documentation/)
- [Docker公式ドキュメント](https://docs.docker.com/)