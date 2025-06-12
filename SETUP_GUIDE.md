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

詳細なブラウザセットアップ手順については、[ブラウザセットアップガイド](#🌐-ブラウザセットアップガイド)を参照してください。

## 🌐 ブラウザセットアップガイド

Docker環境を起動した後、ブラウザからMovableTypeの初期設定を行います。このセクションでは、設定画面で指定すべき具体的なディレクトリパスと設定値を詳しく説明します。

### 📝 事前準備

1. Docker環境が正常に起動していることを確認:
   ```bash
   docker compose ps
   ```
   
2. 全サービスが`Up`状態であることを確認:
   - `movabletype`: MovableType Webサーバー
   - `mysql`: データベースサーバー  
   - `redis`: キャッシュサーバー

### 🔗 セットアップウィザードへのアクセス

1. ブラウザで以下のURLにアクセス:
   ```
   http://localhost:8080/cgi-bin/mt/mt.cgi
   ```

2. MovableTypeのセットアップウィザードが表示されます

### 🛠️ ステップ1: 言語とタイムゾーンの設定

- **言語**: `日本語` を選択
- **タイムゾーン**: `Asia/Tokyo` を選択

### 🗄️ ステップ2: データベース設定

以下の設定値を**正確に**入力してください:

| 項目 | 設定値 | 説明 |
|------|--------|------|
| データベースタイプ | `MySQL` | 使用するデータベース |
| データベースサーバー | `mysql` | Docker内のサービス名 |
| データベース名 | `mt` | 事前作成されたDB名 |
| ユーザー名 | `mt` | データベースユーザー |
| パスワード | `movabletype` | データベースパスワード |
| データベースポート | `3306` | MySQL標準ポート（コンテナ内） |

### 📁 ステップ3: ディレクトリとパス設定

**重要**: 以下のディレクトリパスを正確に入力してください。Docker環境では、これらのパスが事前に設定されています。

#### 📂 静的ファイル設定

| 項目 | 設定値 | 説明 |
|------|--------|------|
| **静的ファイルURL** | `/mt-static/` | ブラウザからアクセスするURL |
| **静的ファイルパス** | `/var/www/html/mt-static/` | サーバー内の物理パス |

#### 📤 アップロード設定

| 項目 | 設定値 | 説明 |
|------|--------|------|
| **アップロードURL** | `/uploads/` | アップロードファイルのURL |
| **アップロードパス** | `/var/www/html/uploads/` | アップロードファイルの保存先 |

#### 🔧 CGI設定

| 項目 | 設定値 | 説明 |
|------|--------|------|
| **CGI URL** | `/cgi-bin/mt/` | MovableType CGIのURL |
| **CGI パス** | `/var/www/cgi-bin/mt/` | CGIファイルの物理パス |

### 👤 ステップ4: 管理者アカウント設定

初期管理者アカウントを作成します:

- **ユーザー名**: 任意（例：`admin`）
- **表示名**: 任意（例：`管理者`）
- **メールアドレス**: 任意（例：`admin@example.com`）
- **パスワード**: 強力なパスワードを設定
- **パスワード確認**: 上記と同じパスワード

### 🌍 ステップ5: サイト設定

初期サイトの設定を行います:

- **サイト名**: 任意（例：`マイサイト`）
- **サイトURL**: `http://localhost:8080/`
- **サイトパス**: `/var/www/html/`
- **タイムゾーン**: `Asia/Tokyo`

### ✅ 設定確認チェックリスト

セットアップ完了前に以下を確認してください:

- [ ] データベース接続テストが成功
- [ ] 静的ファイルパスが正しく設定されている: `/var/www/html/mt-static/`
- [ ] アップロードパスが正しく設定されている: `/var/www/html/uploads/`
- [ ] CGIパスが正しく設定されている: `/var/www/cgi-bin/mt/`
- [ ] 管理者アカウント情報を記録している

### 🚨 よくある設定エラーと対処法

#### エラー1: データベース接続エラー
```
Database connection failed
```
**対処法**: 
- MySQL サービスが起動しているか確認: `docker compose ps mysql`
- データベース設定値を再確認（特にホスト名が`mysql`になっているか）

#### エラー2: 静的ファイルが読み込めない
```
CSS/JSファイルが表示されない
```
**対処法**:
- 静的ファイルパスが`/var/www/html/mt-static/`になっているか確認
- 静的ファイルURLが`/mt-static/`になっているか確認

#### エラー3: アップロードディレクトリエラー
```
Upload directory is not writable
```
**対処法**:
- アップロードパスが`/var/www/html/uploads/`になっているか確認
- コンテナを再起動: `docker compose restart movabletype`

#### エラー4: CGIエラー
```
Internal Server Error
```
**対処法**:
- CGIパスが`/var/www/cgi-bin/mt/`になっているか確認
- Apacheエラーログをチェック: `docker compose logs movabletype`

### 🔧 セットアップ後の確認事項

1. **管理画面アクセス確認**:
   ```
   http://localhost:8080/cgi-bin/mt/mt.cgi
   ```

2. **サイト表示確認**:
   ```
   http://localhost:8080/
   ```

3. **静的ファイル確認**:
   ```
   http://localhost:8080/mt-static/css/screen.css
   ```

### 📋 設定値一覧表（コピー用）

セットアップ時に素早く設定できるよう、主要な設定値をまとめました:

```
【データベース設定】
データベースサーバー: mysql
データベース名: mt
ユーザー名: mt
パスワード: movabletype

【ディレクトリ設定】
静的ファイルURL: /mt-static/
静的ファイルパス: /var/www/html/mt-static/
アップロードURL: /uploads/
アップロードパス: /var/www/html/uploads/
CGI URL: /cgi-bin/mt/
CGI パス: /var/www/cgi-bin/mt/

【サイト設定】
サイトURL: http://localhost:8080/
サイトパス: /var/www/html/
```

### 💡 セットアップ後の推奨作業

1. **バックアップの設定**: [バックアップの作成](#バックアップの作成)を参照
2. **セキュリティ設定**: [セキュリティ](#🔒-セキュリティ)セクションを参照
3. **プラグインインストール**: [推奨プラグイン](#推奨プラグイン)と[カスタムプラグインの追加](#カスタムプラグインの追加)を参照

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

### 推奨プラグイン

MovableTypeの機能を拡張するための推奨プラグインをご紹介します。これらのプラグインは一般的によく使用され、ブログやウェブサイトの運営に役立ちます。

#### 🔍 SEO・アクセス解析系

**PowerCMS Professional**
- **概要**: SEO最適化、高度な記事管理機能を提供
- **用途**: 企業サイト、本格的なCMS運用
- **インストール**: [公式サイト](https://www.powercms.org/)からダウンロード

**Google Analytics Plugin**
- **概要**: Google Analyticsの簡単な設定と統計表示
- **用途**: アクセス解析、トラッキングコード管理
- **インストール**: 
  ```bash
  # プラグインをダウンロード後
  cp -r GoogleAnalytics/ mt/plugins/
  chmod -R 755 mt/plugins/GoogleAnalytics/
  docker compose restart movabletype
  ```

#### 🛡️ セキュリティ・スパム対策

**TypePad AntiSpam**
- **概要**: スパムコメント・トラックバックの自動検出・ブロック
- **用途**: コメントスパム対策
- **特徴**: Six Apart社公式のスパム対策プラグイン
- **インストール**: MovableTypeに標準で含まれている場合があります

**reCAPTCHA Plugin**
- **概要**: Google reCAPTCHAを使用したボット対策
- **用途**: コメントフォーム、お問い合わせフォームの保護
- **インストール**:
  ```bash
  # プラグインをダウンロード後
  cp -r reCAPTCHA/ mt/plugins/
  chmod -R 755 mt/plugins/reCAPTCHA/
  docker compose restart movabletype
  ```

#### 📝 コンテンツ管理・編集

**TinyMCE Plugin**
- **概要**: リッチテキストエディタの高機能化
- **用途**: 記事編集の利便性向上
- **特徴**: WYSIWYG編集、画像挿入、表作成など

**CustomFields**
- **概要**: カスタムフィールドの追加・管理
- **用途**: 記事に独自の項目を追加
- **インストール**:
  ```bash
  cp -r CustomFields/ mt/plugins/
  chmod -R 755 mt/plugins/CustomFields/
  docker compose restart movabletype
  ```

#### 🖼️ メディア・画像管理

**ImageCropper**
- **概要**: 画像のトリミング・リサイズ機能
- **用途**: アップロード画像の最適化
- **特徴**: 自動リサイズ、複数サイズ生成

**AssetGallery**
- **概要**: 画像ギャラリー機能の追加
- **用途**: 画像一覧表示、スライドショー

#### 📱 ソーシャル・共有

**SocialBookmarks**
- **概要**: ソーシャルメディア共有ボタンの追加
- **用途**: Twitter、Facebook等での記事共有促進
- **インストール**:
  ```bash
  cp -r SocialBookmarks/ mt/plugins/
  chmod -R 755 mt/plugins/SocialBookmarks/
  docker compose restart movabletype
  ```

#### 🔧 システム・運用支援

**ConfigAssistant**
- **概要**: テーマ設定の簡単化
- **用途**: 色やレイアウトの変更を管理画面から実行

**Backup/Restore Plugin**
- **概要**: 管理画面からのバックアップ・復元
- **用途**: 定期バックアップ、サイト移転

#### 📋 インストール時の注意事項

1. **互換性確認**: MovableTypeのバージョンとプラグインの対応を確認
2. **テスト環境**: 本番環境にインストールする前にテスト環境で動作確認
3. **バックアップ**: プラグインインストール前は必ずバックアップを取得
4. **権限設定**: プラグインディレクトリの権限設定を忘れずに実行
5. **再起動**: プラグインインストール後はMovableTypeの再起動を実行

#### 🔗 プラグイン配布サイト

- [MovableType.org Plugins](https://plugins.movabletype.org/)
- [Six Apart Plugin Directory](https://plugins.sixapart.com/)
- [GitHub - MovableType関連](https://github.com/topics/movabletype)

### テーマの追加

#### 標準的なテーマ

1. テーマファイルを `mt/themes/` に配置
2. 静的ファイルを `mt-static/themes/` に配置
3. MovableTypeを再起動

#### Vue.jsテンプレート

Vue.js対応のモダンなテンプレートシステムを利用できます：

1. Vue.jsテンプレートをビルド：
```bash
cd themes/vue-template
./build.sh
```

2. MovableType管理画面でテーマを適用：
   - デザイン > テンプレート セット
   - "Vue.js Template" を選択
   - テンプレートを適用してサイトを再構築

詳細は [themes/vue-template/README.md](../themes/vue-template/README.md) を参照してください。

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