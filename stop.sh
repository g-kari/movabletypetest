#!/bin/bash

# MovableType Docker環境 停止スクリプト

echo "🛑 MovableType Docker環境を停止しています..."

# サービス停止
docker compose down

echo "✅ すべてのサービスが停止されました。"
echo ""
echo "💡 ヒント:"
echo "   完全にリセットする場合: docker compose down -v"
echo "   再起動する場合: ./start.sh"