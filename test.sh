#!/bin/bash

# MovableType Docker環境 テストスクリプト

set -e

echo "🔍 MovableType Docker環境のテストを開始します..."
echo ""

# 1. 設定ファイルの検証
echo "📋 設定ファイルの検証:"

# Docker Composeファイルの検証
if [ -f "docker-compose.yml" ]; then
    echo "✅ docker-compose.yml が存在します"
    if docker compose config > /dev/null 2>&1; then
        echo "✅ docker-compose.yml の構文が正しいです"
    else
        echo "❌ docker-compose.yml に構文エラーがあります"
        exit 1
    fi
else
    echo "❌ docker-compose.yml が見つかりません"
    exit 1
fi

# Dockerfileの検証
if [ -f "docker/movabletype/Dockerfile" ]; then
    echo "✅ Dockerfile が存在します"
else
    echo "❌ Dockerfile が見つかりません"
    exit 1
fi

# 設定ファイルの検証
required_files=(
    "docker/movabletype/mt-config.cgi"
    "docker/movabletype/entrypoint.sh"
    "docker/apache/sites-available/000-default.conf"
    "docker/apache/conf-available/movabletype.conf"
    "docker/mysql/init/01-init.sql"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file が存在します"
    else
        echo "❌ $file が見つかりません"
        exit 1
    fi
done

echo ""

# 2. ディレクトリ構造の確認
echo "📁 ディレクトリ構造の確認:"

required_dirs=(
    "docker/movabletype"
    "docker/apache/sites-available"
    "docker/apache/conf-available"
    "docker/mysql/init"
    "mt"
    "mt-static"
    "uploads"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir ディレクトリが存在します"
    else
        echo "❌ $dir ディレクトリが見つかりません"
        exit 1
    fi
done

echo ""

# 3. スクリプトファイルの実行権限確認
echo "🔧 スクリプトファイルの権限確認:"

script_files=(
    "start.sh"
    "stop.sh"
    "docker/movabletype/entrypoint.sh"
)

for script in "${script_files[@]}"; do
    if [ -x "$script" ]; then
        echo "✅ $script は実行可能です"
    else
        echo "⚠️  $script に実行権限がありません。設定中..."
        chmod +x "$script"
        echo "✅ $script に実行権限を設定しました"
    fi
done

echo ""

# 4. 設定ファイルの内容確認
echo "📄 設定ファイルの内容確認:"

# MovableType設定ファイルの確認
if grep -q "Database mysql" docker/movabletype/mt-config.cgi; then
    echo "✅ MovableType設定: MySQL設定が正しいです"
else
    echo "❌ MovableType設定: MySQL設定が見つかりません"
    exit 1
fi

if grep -q "DBHost mysql" docker/movabletype/mt-config.cgi; then
    echo "✅ MovableType設定: データベースホスト設定が正しいです"
else
    echo "❌ MovableType設定: データベースホスト設定が見つかりません"
    exit 1
fi

if grep -q "MemcachedServers redis:6379" docker/movabletype/mt-config.cgi; then
    echo "✅ MovableType設定: Redis設定が正しいです"
else
    echo "❌ MovableType設定: Redis設定が見つかりません"
    exit 1
fi

if grep -q "MailTransfer sendmail" docker/movabletype/mt-config.cgi; then
    echo "✅ MovableType設定: Sendmail設定が正しいです"
else
    echo "❌ MovableType設定: Sendmail設定が見つかりません"
    exit 1
fi

if grep -q "SendMailPath /usr/sbin/sendmail" docker/movabletype/mt-config.cgi; then
    echo "✅ MovableType設定: Sendmailパス設定が正しいです"
else
    echo "❌ MovableType設定: Sendmailパス設定が見つかりません"
    exit 1
fi

echo ""

# 5. Docker Composeサービスの確認
echo "🐳 Docker Composeサービスの確認:"

services=$(docker compose config --services)
expected_services=("mysql" "redis" "movabletype")

for service in "${expected_services[@]}"; do
    if echo "$services" | grep -q "$service"; then
        echo "✅ $service サービスが定義されています"
    else
        echo "❌ $service サービスが定義されていません"
        exit 1
    fi
done

echo ""

# 6. ポート設定の確認
echo "🔌 ポート設定の確認:"

if docker compose config | grep -q "published: \"8080\""; then
    echo "✅ HTTP ポート (8080) が設定されています"
else
    echo "❌ HTTP ポート (8080) が設定されていません"
fi

if docker compose config | grep -q "published: \"3307\""; then
    echo "✅ MySQL ポート (3307) が設定されています"
else
    echo "❌ MySQL ポート (3307) が設定されていません"
fi

if docker compose config | grep -q "published: \"6380\""; then
    echo "✅ Redis ポート (6380) が設定されています"
else
    echo "❌ Redis ポート (6380) が設定されていません"
fi

echo ""
echo "🎉 全ての基本テストがパスしました！"
echo ""
echo "💡 次のステップ:"
echo "   1. ./start.sh でサービスを起動"
echo "   2. http://localhost:8080/cgi-bin/mt/mt.cgi にアクセス"
echo "   3. セットアップウィザードを実行"
echo ""
echo "📊 サービス起動後の確認コマンド:"
echo "   docker compose ps          # サービス状態確認"
echo "   docker compose logs        # ログ確認"
echo "   make dev-mysql             # MySQL接続テスト"
echo "   make dev-redis             # Redis接続テスト"