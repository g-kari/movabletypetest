# Shadowverse Deck Builder - Installation Guide

## 📋 概要

このプラグインは、MovableType上でShadowverseのデッキ構築システムを提供します。Vue.jsベースの直感的なUIでデッキを作成し、データベースに保存、シェア機能でOGP対応の共有が可能です。

## 🎯 実装された機能

### ✅ 完了した機能
- [x] **デッキ構築**: Vue.jsベースのインタラクティブなデッキエディター
- [x] **データベースに保存**: MySQLでのデッキ・カード情報の永続化
- [x] **シェア機能**: 公開デッキのURL共有システム
- [x] **シェア時のOGP**: Open Graph Protocol対応のメタタグ自動生成
- [x] **ユーザによる認識**: MovableTypeユーザーシステムとの完全統合

## 🏗️ プラグイン構造

```
mt/plugins/ShadowverseDeckBuilder/
├── config.yaml                    # プラグイン設定
├── README.md                      # プラグイン説明書
├── sample_cards.sql               # サンプルカードデータ
├── lib/ShadowverseDeckBuilder/
│   ├── SVCard.pm                  # カードモデル
│   ├── SVDeck.pm                  # デッキモデル
│   ├── CMS.pm                     # 管理画面処理
│   ├── Tags.pm                    # テンプレートタグ
│   └── Callback.pm                # コールバック処理
└── tmpl/
    ├── deck_list.tmpl             # デッキ一覧画面
    ├── deck_edit.tmpl             # デッキ編集画面
    └── deck_share.tmpl            # デッキ共有画面

themes/vue-template/src/
├── main.js                        # Vue.js メインエントリー
└── components/
    └── DeckEditor.vue             # デッキエディターコンポーネント
```

## 📊 データベーススキーマ

### SVCard テーブル
- **基本情報**: カード名、英語名、コスト、攻撃力、体力
- **分類情報**: タイプ（フォロワー/スペル/アミュレット）、クラス、レアリティ
- **追加情報**: セット名、説明文、画像URL

### SVDeck テーブル
- **基本情報**: タイトル、説明、デッキクラス
- **カード構成**: JSON形式でのカード構成データ
- **ユーザー情報**: 作成者ID、作成者名
- **公開設定**: 公開フラグ、シェア用トークン
- **統計情報**: 閲覧数、いいね数

## 🚀 インストール手順

### 1. ファイル配置
```bash
# プラグインファイルをMovableTypeに配置
cp -r mt/plugins/ShadowverseDeckBuilder /path/to/movabletype/plugins/

# Vue.jsテーマファイルを配置
cp -r themes/vue-template /path/to/movabletype/themes/
```

### 2. MovableType設定
1. MovableType管理画面にログイン
2. 「システム」→「プラグイン」でShadowverse Deck Builderを有効化
3. データベースのアップグレードを実行

### 3. サンプルデータの挿入
```bash
# MySQLにサンプルカードデータを挿入
mysql -u mt -p mt < mt/plugins/ShadowverseDeckBuilder/sample_cards.sql
```

### 4. Vue.jsアセットのビルド
```bash
cd themes/vue-template
npm install
npm run build
```

## 💻 使用方法

### 管理画面でのデッキ作成
1. 「ツール」→「Shadowverse Deck Builder」を選択
2. 「新しいデッキを作成」をクリック
3. デッキ基本情報（名前、クラス、説明）を入力
4. Vue.jsエディターでカードを選択してデッキを構築
5. 「公開デッキにする」チェックでシェア機能有効化
6. 保存完了

### デッキのシェア
- 公開デッキは自動生成されるシェアURLでアクセス可能
- OGP対応でSNSでのリッチな表示
- Twitter Cards対応

### フロントエンドでの表示
```html
<!-- デッキ一覧表示 -->
<mt:SVDeckList limit="10" public_only="1">
    <h3><mt:var name="svdeck_title"></h3>
    <p>クラス: <mt:var name="svdeck_class_jp"></p>
</mt:SVDeckList>

<!-- デッキ詳細表示 -->
<mt:SVDeckDetail token="SHARE_TOKEN">
    <h1><mt:var name="svdeck_title"></h1>
    <p><mt:var name="svdeck_description"></p>
</mt:SVDeckDetail>
```

## 🔧 カスタマイズ

### カードデータの追加
```perl
use ShadowverseDeckBuilder::SVCard;

my $card = ShadowverseDeckBuilder::SVCard->new;
$card->card_id('SV_NEW_001');
$card->name('新しいカード');
$card->cost(3);
$card->class('elf');
$card->save;
```

### Vue.jsコンポーネントのカスタマイズ
- `themes/vue-template/src/components/DeckEditor.vue`を編集
- デザイン、機能の追加・変更が可能
- `npm run build`でアセットを再ビルド

## 🎨 主要な技術特徴

### Vue.js統合
- リアクタイブなデッキ構築UI
- カード検索・フィルタリング機能
- リアルタイムデッキ統計表示
- コスト分布チャート

### MovableType統合
- 既存ユーザーシステムとの連携
- テンプレートタグでの柔軟な表示
- プラグイン設定による管理

### データベース設計
- 正規化されたテーブル構造
- JSON形式でのデッキ構成保存
- インデックスによる高速検索

## 🔍 テスト結果

すべての構造テストが正常に完了：
- ✅ 必須ファイル: 11/11
- ✅ Vue.jsファイル: 2/2
- ✅ Perl構文チェック: すべて通過
- ✅ 設定ファイル検証: すべて通過

## 📈 今後の拡張可能性

1. **デッキ分析機能**: 統計データの可視化
2. **デッキバトル機能**: ユーザー間の対戦システム
3. **カードパック管理**: 新カードセットの管理機能
4. **コミュニティ機能**: コメント、評価システム
5. **API連携**: 外部サービスとの連携

## 📝 ライセンス

MIT License - 自由に使用、修正、配布可能

---

このプラグインにより、MovableType上で本格的なShadowverseデッキ構築システムが利用可能になります。