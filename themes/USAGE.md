# Vue.js Template for MovableType - Quick Start Guide

## 🚀 クイックスタート

### 1. Vue.jsテンプレートのビルド

```bash
# 方法1: Makeを使用（推奨）
make vue-build

# 方法2: 直接ビルド
cd themes/vue-template
./build.sh
```

### 2. Docker環境の起動

```bash
# 環境起動
make start
# または
docker compose up -d
```

### 3. MovableTypeでテーマを適用

1. ブラウザで http://localhost:8080/cgi-bin/mt/mt.cgi にアクセス
2. MovableTypeのセットアップを完了
3. 管理画面で以下の手順を実行：
   - 「デザイン」> 「テンプレート」をクリック
   - 「テンプレートセット」から「Vue.js Template」を選択
   - 「適用」をクリック
   - サイトを再構築

## 💡 使用例

### ブログ記事一覧の表示

MovableTypeテンプレート内で以下のようにVueコンポーネントを使用できます：

```html
<!-- Vue.js コンポーネントをマウントする要素 -->
<div id="vue-blog-posts" 
     data-posts='[
        <$mt:Entries>
        {
            "id": "<$mt:EntryID$>",
            "title": "<$mt:EntryTitle encode_json="1"$>",
            "permalink": "<$mt:EntryPermalink$>",
            "created_on": "<$mt:EntryDate format_name="iso8601"$>",
            "author": "<$mt:EntryAuthorDisplayName encode_json="1"$>",
            "category": "<$mt:EntryCategory encode_json="1"$>",
            "excerpt": "<$mt:EntryExcerpt encode_json="1"$>",
            "tags": [<$mt:EntryTags glue='","'>"<$mt:TagName encode_json="1"$>"</$mt:EntryTags>]
        }<$mt:EntriesFooter>,</$mt:EntriesFooter>
        </$mt:Entries>
     ]'>
    <!-- JavaScript無効時のフォールバック -->
    <div class="fallback-content">
        <$mt:Entries>
        <article>
            <h3><a href="<$mt:EntryPermalink$>"><$mt:EntryTitle$></a></h3>
            <p><$mt:EntryExcerpt$></p>
        </article>
        </$mt:Entries>
    </div>
</div>
```

### ナビゲーションの表示

```html
<div id="vue-navigation" 
     data-menu='[
        {"id": 1, "label": "ホーム", "url": "<$mt:BlogURL$>", "current": true},
        {"id": 2, "label": "ブログ", "url": "<$mt:BlogURL$>", "current": false},
        {"id": 3, "label": "アーカイブ", "url": "<$mt:BlogURL$>archives.html", "current": false}
     ]'>
    <!-- フォールバック -->
    <nav>
        <a href="<$mt:BlogURL$>">ホーム</a> |
        <a href="<$mt:BlogURL$>archives.html">アーカイブ</a>
    </nav>
</div>
```

## 🔧 カスタマイズ

### 新しいコンポーネントの追加

1. `themes/vue-template/src/components/` に新しい `.vue` ファイルを作成
2. `themes/vue-template/src/main.js` でコンポーネントをインポート
3. `make vue-build` でビルド

### スタイルの変更

各コンポーネントの `<style>` セクションを編集してカスタマイズ可能です。

## 📊 確認コマンド

```bash
# Vue.jsテンプレートのテスト
make vue-test

# Vue.jsテンプレートのビルド
make vue-build

# Vue.js開発サーバー起動（開発時）
make vue-dev
```