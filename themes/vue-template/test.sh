#!/bin/bash

# Vue.js Template テストスクリプト

set -e

echo "🔍 Vue.js Template のテストを開始します..."
echo ""

# テストディレクトリに移動
cd "$(dirname "$0")"

# 1. ディレクトリ構造の確認
echo "📁 ディレクトリ構造の確認:"

required_dirs=(
    "src"
    "src/components"
    "templates"
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

# 2. 必要ファイルの確認
echo "📄 必要ファイルの確認:"

required_files=(
    "package.json"
    "vite.config.js"
    "build.sh"
    "theme.yaml"
    "src/main.js"
    "src/App.vue"
    "src/components/BlogPosts.vue"
    "src/components/Navigation.vue"
    "templates/main_index.tmpl"
    "templates/entry.tmpl"
    "templates/コンテンツ.tmpl"
    "README.md"
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

# 3. package.json の内容確認
echo "📦 package.json の確認:"

if grep -q "vue" package.json; then
    echo "✅ Vue.js の依存関係が定義されています"
else
    echo "❌ Vue.js の依存関係が見つかりません"
    exit 1
fi

if grep -q "vite" package.json; then
    echo "✅ Vite の依存関係が定義されています"
else
    echo "❌ Vite の依存関係が見つかりません"
    exit 1
fi

if grep -q '"build": "vite build"' package.json; then
    echo "✅ ビルドスクリプトが定義されています"
else
    echo "❌ ビルドスクリプトが見つかりません"
    exit 1
fi

echo ""

# 4. Vite設定の確認
echo "⚙️ Vite設定の確認:"

if grep -q "@vitejs/plugin-vue" vite.config.js; then
    echo "✅ Vue.js プラグインが設定されています"
else
    echo "❌ Vue.js プラグインが設定されていません"
    exit 1
fi

if grep -q "mt-static/themes/vue-template" vite.config.js; then
    echo "✅ 出力ディレクトリが正しく設定されています"
else
    echo "❌ 出力ディレクトリの設定が見つかりません"
    exit 1
fi

echo ""

# 5. テーマ設定の確認
echo "🎨 テーマ設定の確認:"

if grep -q "id: vue-template" theme.yaml; then
    echo "✅ テーマIDが設定されています"
else
    echo "❌ テーマIDが設定されていません"
    exit 1
fi

if grep -q "name: Vue.js Template" theme.yaml; then
    echo "✅ テーマ名が設定されています"
else
    echo "❌ テーマ名が設定されていません"
    exit 1
fi

echo ""

# 6. Vueコンポーネントの構文チェック
echo "🧩 Vueコンポーネントの確認:"

vue_files=(
    "src/App.vue"
    "src/components/BlogPosts.vue"
    "src/components/Navigation.vue"
)

for vue_file in "${vue_files[@]}"; do
    if grep -q "<template>" "$vue_file" && grep -q "<script>" "$vue_file" && (grep -q "<style>" "$vue_file" || grep -q "<style scoped>" "$vue_file"); then
        echo "✅ $vue_file の構造が正しいです"
    else
        echo "⚠️  $vue_file の構造を確認してください"
    fi
done

echo ""

# 7. MovableTypeテンプレートの確認
echo "📝 MovableTypeテンプレートの確認:"

tmpl_files=(
    "templates/main_index.tmpl"
    "templates/entry.tmpl"
    "templates/コンテンツ.tmpl"
)

for tmpl_file in "${tmpl_files[@]}"; do
    if grep -q "vue-" "$tmpl_file"; then
        echo "✅ $tmpl_file にVue.js統合が含まれています"
    else
        echo "⚠️  $tmpl_file のVue.js統合を確認してください"
    fi
done

echo ""

# 8. ビルドスクリプトの実行権限確認
echo "🔧 ビルドスクリプトの確認:"

if [ -x "build.sh" ]; then
    echo "✅ build.sh に実行権限があります"
else
    echo "⚠️  build.sh に実行権限を設定しています..."
    chmod +x build.sh
    echo "✅ build.sh に実行権限を設定しました"
fi

echo ""

# 9. Node.js環境の確認
echo "🟢 Node.js環境の確認:"

if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js がインストールされています: $NODE_VERSION"
    
    # Node.js バージョンチェック (v16以上が推奨)
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | sed 's/v\([0-9]*\).*/\1/')
    if [ "$NODE_MAJOR_VERSION" -ge 16 ]; then
        echo "✅ Node.js バージョンが適切です"
    else
        echo "⚠️  Node.js v16以上を推奨します (現在: $NODE_VERSION)"
    fi
else
    echo "❌ Node.js がインストールされていません"
    echo "   Docker環境での使用時は、コンテナ内でNode.jsが利用可能になります"
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm がインストールされています: v$NPM_VERSION"
else
    echo "❌ npm がインストールされていません"
fi

echo ""

echo "🎉 Vue.js Template の基本テストが完了しました！"
echo ""
echo "💡 次のステップ:"
echo "   1. ./build.sh を実行してVue.jsコンポーネントをビルド"
echo "   2. Docker環境を起動: docker compose up -d"
echo "   3. MovableType管理画面でテーマを適用"
echo ""
echo "🔨 ビルドコマンド:"
echo "   cd themes/vue-template && ./build.sh"