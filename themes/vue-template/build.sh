#!/bin/bash

# Vue.js Template Build Script for MovableType

set -e

echo "🔨 Vue.js テンプレートをビルドしています..."

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Node.js dependencies のインストール
if [ ! -d "node_modules" ]; then
    echo "📦 依存関係をインストールしています..."
    npm install
fi

# Vue.js プロジェクトのビルド
echo "🏗️  Vue.js コンポーネントをビルドしています..."
npm run build

# 出力ディレクトリが存在することを確認
OUTPUT_DIR="../../mt-static/themes/vue-template"
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# ビルド結果の確認
if [ -f "$OUTPUT_DIR/assets/main.js" ] && [ -f "$OUTPUT_DIR/assets/main.css" ]; then
    echo "✅ ビルドが完了しました！"
    echo "📁 出力先: $OUTPUT_DIR"
    echo "📋 生成されたファイル:"
    ls -la "$OUTPUT_DIR/assets/"
else
    echo "❌ ビルドに失敗しました"
    exit 1
fi

echo ""
echo "🎉 Vue.js テンプレートの準備が完了しました！"
echo ""
echo "💡 次のステップ:"
echo "   1. MovableType管理画面にアクセス"
echo "   2. デザイン > テンプレート セットから 'Vue.js Template' を選択"
echo "   3. テンプレートを適用してサイトを再構築"