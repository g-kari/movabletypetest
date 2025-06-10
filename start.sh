#!/bin/bash

# MovableType Docker環境 起動スクリプト

echo "🚀 MovableType Docker環境を起動しています..."

# Docker Composeファイルの存在確認
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml が見つかりません。"
    echo "   プロジェクトのルートディレクトリから実行してください。"
    exit 1
fi

# Dockerの動作確認
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Dockerが見つかりません。Dockerをインストールしてください。"
    exit 1
fi

if ! docker compose --version > /dev/null 2>&1; then
    echo "❌ Docker Composeが見つかりません。Docker Composeをインストールしてください。"
    exit 1
fi

# 既存のコンテナを停止
echo "🛑 既存のコンテナを停止しています..."
docker compose down

# イメージをビルド
echo "🔨 Docker イメージをビルドしています..."
docker compose build

# サービスを起動
echo "📦 サービスを起動しています..."
docker compose up -d

# 起動確認
echo "⏳ サービスの起動を待機しています..."
sleep 10

# サービスの状態確認
echo "📊 サービス状態確認:"
docker compose ps

echo ""
echo "✅ MovableType環境の起動が完了しました！"
echo ""
echo "🌐 アクセス情報:"
echo "   MovableType管理画面: http://localhost:8080/cgi-bin/mt/mt.cgi"
echo "   サイト: http://localhost:8080/"
echo ""
echo "📋 初回セットアップ情報:"
echo "   データベースサーバー: mysql"
echo "   データベース名: mt"
echo "   ユーザー名: mt"
echo "   パスワード: movabletype"
echo ""
echo "🔍 ログ確認: docker compose logs"
echo "🛑 停止: docker compose down"