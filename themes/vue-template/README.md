# Vue.js Template for MovableType

このディレクトリには、MovableTypeで使用できるVue.js対応のモダンなテンプレートシステムが含まれています。

## 🎯 概要

MovableType + Vue.js テンプレートは、従来のCMSの機能性と現代的なフロントエンド開発の利便性を組み合わせた革新的なソリューションです。

### 主な特徴

- ✨ **Vue.js 3** - 最新のコンポーネントベースアーキテクチャ
- 🎨 **レスポンシブデザイン** - モバイルファーストのアプローチ
- ⚡ **高速ビルド** - Viteを使用した高速開発環境
- 🔧 **カスタマイズ可能** - 簡単にテーマを調整可能
- 🚀 **SEO最適化** - MovableTypeのSEO機能をフル活用

## 📁 ディレクトリ構造

```
themes/vue-template/
├── package.json          # Node.js依存関係管理
├── vite.config.js         # Viteビルド設定
├── build.sh              # ビルドスクリプト
├── theme.yaml            # MovableTypeテーマ設定
│
├── src/                  # Vue.jsソースファイル
│   ├── main.js           # メインエントリーポイント
│   ├── App.vue           # メインアプリコンポーネント
│   └── components/       # Vueコンポーネント
│       ├── BlogPosts.vue # ブログ記事一覧コンポーネント
│       └── Navigation.vue # ナビゲーションコンポーネント
│
└── templates/            # MovableTypeテンプレート
    ├── main_index.tmpl   # メインページテンプレート
    ├── entry.tmpl        # 記事ページテンプレート
    └── コンテンツ.tmpl    # コンテンツモジュール
```

## 🚀 セットアップ手順

### 1. 依存関係のインストールとビルド

```bash
# Vue.jsテンプレートディレクトリに移動
cd themes/vue-template

# ビルドスクリプトを実行（依存関係のインストールとビルドを自動実行）
./build.sh
```

### 2. MovableTypeでのテーマ適用

1. MovableType管理画面にアクセス
2. 「デザイン」> 「テンプレート」に移動
3. 「テンプレートセット」から「Vue.js Template」を選択
4. テンプレートを適用
5. サイトを再構築

## 🎨 カスタマイズ

### コンポーネントの編集

Vue.jsコンポーネントは `src/components/` ディレクトリにあります：

- **Navigation.vue** - サイトナビゲーション
- **BlogPosts.vue** - ブログ記事一覧表示

### スタイルの変更

各コンポーネント内の `<style>` セクションでCSSを編集できます。

### 新しいコンポーネントの追加

1. `src/components/` に新しい `.vue` ファイルを作成
2. `src/main.js` でコンポーネントをインポート
3. MovableTypeテンプレートで対応するHTML要素を追加

## 🔧 開発ワークフロー

### 開発モードでの実行

```bash
cd themes/vue-template
npm run dev
```

開発サーバーが `http://localhost:3000` で起動します。

### プロダクションビルド

```bash
cd themes/vue-template
npm run build
```

ビルドされたファイルは `../../mt-static/themes/vue-template/` に出力されます。

## 💡 使用方法

### MovableTypeテンプレートでのVueコンポーネント使用

#### 1. ブログ記事一覧の表示

```html
<div id="vue-blog-posts" 
     data-posts='[
        <$mt:Entries>
        {
            "id": "<$mt:EntryID$>",
            "title": "<$mt:EntryTitle encode_json="1"$>",
            "permalink": "<$mt:EntryPermalink$>",
            "created_on": "<$mt:EntryDate format_name="iso8601"$>",
            "author": "<$mt:EntryAuthorDisplayName encode_json="1"$>",
            "excerpt": "<$mt:EntryExcerpt encode_json="1"$>"
        }<$mt:EntriesFooter>,</$mt:EntriesFooter>
        </$mt:Entries>
     ]'>
</div>
```

#### 2. ナビゲーションの表示

```html
<div id="vue-navigation" 
     data-menu='[
        {"id": 1, "label": "ホーム", "url": "<$mt:BlogURL$>", "current": true},
        {"id": 2, "label": "ブログ", "url": "<$mt:BlogURL$>", "current": false}
     ]'>
</div>
```

#### 3. カスタムコンポーネントのマウント

```javascript
// JavaScript APIを使用してコンポーネントを動的にマウント
window.MTVueTemplate.mountBlogPosts('#blog-container', postsData);
window.MTVueTemplate.mountNavigation('#nav-container', menuData);
```

## 🎯 技術仕様

### 使用技術

- **Vue.js 3.3.4** - プログレッシブフレームワーク
- **Vite 4.4.9** - 高速ビルドツール
- **MovableType** - CMSバックエンド

### ブラウザ対応

- Chrome (最新版)
- Firefox (最新版)
- Safari (最新版)
- Edge (最新版)

### JavaScript非対応環境

JavaScript が無効な環境でも、MovableTypeの標準的なHTMLが表示されるフォールバック機能を提供しています。

## 🔧 トラブルシューティング

### よくある問題

#### 1. ビルドエラーが発生する

```bash
# Node.jsのバージョンを確認
node --version  # v18以上が必要

# 依存関係を再インストール
rm -rf node_modules package-lock.json
npm install
```

#### 2. Vueコンポーネントが表示されない

- ブラウザの開発者ツールでJavaScriptエラーを確認
- `mt-static/themes/vue-template/assets/main.js` が正しく読み込まれているか確認
- MovableTypeテンプレートの JSON データが正しい形式か確認

#### 3. スタイルが適用されない

- `mt-static/themes/vue-template/assets/main.css` が存在するか確認
- ブラウザキャッシュをクリア
- 再ビルドを実行: `./build.sh`

## 📚 リソース

### 関連ドキュメント

- [Vue.js 公式ドキュメント](https://vuejs.org/guide/)
- [Vite 公式ドキュメント](https://vitejs.dev/guide/)
- [MovableType デベロッパードキュメント](https://www.movabletype.org/documentation/)

### サンプルコード

このテンプレートには以下のサンプルが含まれています：

- レスポンシブナビゲーション
- ブログ記事一覧表示
- 記事詳細ページ
- タグ表示
- ページネーション

## 🤝 コントリビューション

改善提案やバグ報告は Issue または Pull Request でお願いします。

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。