# MovableType プラグイン開発ガイド

MovableTypeのプラグイン開発に関する包括的な日本語ドキュメントです。初心者から上級者まで、プラグイン開発のすべての側面をカバーします。

## 📋 目次

1. [プラグイン開発の基礎](#-プラグイン開発の基礎)
2. [プラグイン構造](#-プラグイン構造)
3. [設定ファイル (config.yaml)](#-設定ファイル-configyaml)
4. [Perlモジュール開発](#-perlモジュール開発)
5. [テンプレートシステム](#-テンプレートシステム)
6. [コールバックとフック](#-コールバックとフック)
7. [データベース統合](#-データベース統合)
8. [実践例: 既存プラグインの解説](#-実践例-既存プラグインの解説)
9. [ベストプラクティス](#-ベストプラクティス)
10. [参考リンク](#-参考リンク)

---

## 🚀 プラグイン開発の基礎

### プラグインとは

MovableTypeのプラグインは、CMSの機能を拡張するためのモジュールです。以下のような機能を追加できます：

- **新しいテンプレートタグ**: ブログやウェブサイトで使用可能なカスタムタグ
- **管理画面の機能拡張**: 新しい管理画面や設定項目の追加
- **データベーススキーマの拡張**: 新しいテーブルやフィールドの追加
- **外部サービス連携**: API連携やウェブサービスとの統合
- **コンテンツ処理**: 記事やページの自動処理・変換

*参考: [MovableType プラグイン開発リファレンス](https://manual.movabletype.jp/developer/plugins/)*

### プラグイン開発の前提知識

#### 必要なスキル
- **Perl**: MovableTypeの主要言語（[Perl.org](https://www.perl.org/) でPerl学習リソースを確認）
- **HTML/CSS/JavaScript**: フロントエンド開発
- **SQL**: データベース操作
- **YAML**: 設定ファイル記述

#### 開発環境
- MovableType開発環境（本プロジェクトのDocker環境を推奨）
- テキストエディタまたはIDE
- バージョン管理システム（Git）

---

## 🏗️ プラグイン構造

### 基本的なディレクトリ構造

```
mt/plugins/YourPluginName/
├── config.yaml              # プラグイン設定ファイル（必須）
├── README.md                # プラグイン説明書
├── lib/                     # Perlモジュール
│   └── YourPluginName/
│       ├── Plugin.pm        # メインプラグインクラス
│       ├── Tags.pm          # テンプレートタグ
│       ├── Callback.pm      # コールバック処理
│       └── Model/           # データモデル
│           ├── Object1.pm
│           └── Object2.pm
├── tmpl/                    # 管理画面テンプレート
│   ├── list.tmpl
│   ├── edit.tmpl
│   └── config.tmpl
├── static/                  # 静的ファイル（CSS, JS, 画像）
│   ├── css/
│   ├── js/
│   └── images/
└── extlib/                  # 外部ライブラリ
    └── Some/
        └── Module.pm
```

### ファイルの役割

#### config.yaml（必須）
プラグインのメタデータ、設定、オブジェクト定義を記述する中核ファイル。

#### lib/ディレクトリ
Perlモジュールを配置。プラグインのビジネスロジックを実装。

#### tmpl/ディレクトリ
管理画面用のテンプレートファイルを配置。

#### static/ディレクトリ
CSS、JavaScript、画像などの静的ファイルを配置。

---

## 📝 設定ファイル (config.yaml)

`config.yaml`はプラグインの中核となる設定ファイルです。プラグインのメタデータ、設定項目、データベーススキーマ、コールバックなどすべての定義を記述します。

*参考: [MovableType プラグイン設定ファイル仕様](https://manual.movabletype.jp/developer/plugins/config.html)*

### 基本構造

```yaml
# プラグイン基本情報
id: YourPluginName
name: Your Plugin Display Name
version: 1.0.0
description: プラグインの説明
author_name: 作成者名
author_link: https://example.com
plugin_link: https://github.com/user/plugin
doc_link: https://github.com/user/plugin/wiki

# スキーマバージョン
schema_version: 1.0
```

### 設定項目の定義

```yaml
config_settings:
  PluginSetting:
    type: TEXTINPUT
    label: '設定項目のラベル'
    hint: '設定の説明文'
    default: 'デフォルト値'
    required: 1
    
  SelectSetting:
    type: SELECT
    label: '選択項目'
    values: 'option1,option2,option3'
    default: 'option1'
```

#### 設定項目のタイプ
- `TEXTINPUT`: テキスト入力
- `TEXTAREA`: テキストエリア
- `SELECT`: セレクトボックス
- `CHECKBOX`: チェックボックス
- `RADIO`: ラジオボタン

### データベースオブジェクトの定義

```yaml
object_types:
  your_object:
    column_name: string(255) not null
    description: text
    created_on: datetime not null
    modified_on: timestamp not null
    status: integer default 1
```

#### データ型
- `string(length)`: 文字列
- `text`: 長いテキスト
- `integer`: 整数
- `float`: 浮動小数点数
- `datetime`: 日時
- `timestamp`: タイムスタンプ

### テンプレートタグの定義

```yaml
tags:
  function:
    YourFunctionTag: '$YourPluginName::YourPluginName::Tags::your_function_tag'
  block:
    YourBlockTag: '$YourPluginName::YourPluginName::Tags::your_block_tag'
```

### コールバックの定義

```yaml
callbacks:
  cms_init_request: '$YourPluginName::YourPluginName::Callback::cms_init_request'
  MT::App::CMS::template_source.list_entry: '$YourPluginName::YourPluginName::Callback::template_source'
```

---

## 🔧 Perlモジュール開発

### メインプラグインクラス

```perl
package YourPluginName::Plugin;

use strict;
use warnings;
use base 'MT::Plugin';

# プラグインの初期化
sub init_registry {
    my $plugin = shift;
    
    $plugin->registry({
        # 追加の設定
    });
}

1;
```

### テンプレートタグの実装

```perl
package YourPluginName::Tags;

use strict;
use warnings;

# ファンクションタグ
sub your_function_tag {
    my ($ctx, $args, $cond) = @_;
    
    # タグの処理ロジック
    return "出力結果";
}

# ブロックタグ
sub your_block_tag {
    my ($ctx, $args, $cond) = @_;
    
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    
    # ブロック内容の処理
    my $content = $builder->build($ctx, $tokens, $cond);
    
    return "加工されたコンテンツ: $content";
}

1;
```

### データモデルクラス

```perl
package YourPluginName::YourObject;

use strict;
use warnings;
use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'name' => 'string(255) not null',
        'description' => 'text',
        'created_on' => 'datetime not null',
        'modified_on' => 'timestamp not null',
    },
    indexes => {
        'name' => 1,
        'created_on' => 1,
    },
    primary_key => 'id',
    datasource => 'your_object',
});

# カスタムメソッド
sub custom_method {
    my $self = shift;
    # カスタム処理
    return $self->name . " - カスタム処理結果";
}

1;
```

---

## 🎨 テンプレートシステム

### 管理画面テンプレート

MovableTypeの管理画面テンプレートは独自の形式を使用します。テンプレートタグやディレクティブを活用して動的なコンテンツを生成できます。

*参考: [MovableType テンプレートタグリファレンス](https://manual.movabletype.jp/appendices/tags/)*

#### リスト画面テンプレート例

```html
<mt:setvarblock name="page_title">オブジェクト一覧</mt:setvarblock>

<mt:setvarblock name="content_header">
    <div class="content-header">
        <h1><mt:var name="page_title"></h1>
    </div>
</mt:setvarblock>

<mt:setvarblock name="content_nav">
    <ul class="nav nav-tabs">
        <li class="active"><a href="#">一覧</a></li>
        <li><a href="<mt:var name="script_url">?__mode=your_edit">新規作成</a></li>
    </ul>
</mt:setvarblock>

<mt:setvarblock name="html_body">
    <div class="container">
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>名前</th>
                    <th>説明</th>
                    <th>作成日</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <mt:loop name="object_loop">
                    <tr>
                        <td><mt:var name="name" escape="html"></td>
                        <td><mt:var name="description" escape="html"></td>
                        <td><mt:var name="created_on"></td>
                        <td>
                            <a href="<mt:var name="script_url">?__mode=your_edit&id=<mt:var name="id">">編集</a>
                            <a href="<mt:var name="script_url">?__mode=your_delete&id=<mt:var name="id">">削除</a>
                        </td>
                    </tr>
                </mt:loop>
            </tbody>
        </table>
    </div>
</mt:setvarblock>

<mt:include name="layout/default.tmpl">
```

#### 編集画面テンプレート例

```html
<mt:setvarblock name="page_title">
    <mt:if name="id">
        オブジェクト編集
    <mt:else>
        オブジェクト新規作成
    </mt:if>
</mt:setvarblock>

<mt:setvarblock name="html_body">
    <form method="post" action="<mt:var name="script_url">">
        <input type="hidden" name="__mode" value="your_save" />
        <input type="hidden" name="magic_token" value="<mt:var name="magic_token">" />
        <mt:if name="id">
            <input type="hidden" name="id" value="<mt:var name="id">" />
        </mt:if>
        
        <div class="form-group">
            <label for="name">名前</label>
            <input type="text" id="name" name="name" value="<mt:var name="name" escape="html">" class="form-control" required />
        </div>
        
        <div class="form-group">
            <label for="description">説明</label>
            <textarea id="description" name="description" class="form-control"><mt:var name="description" escape="html"></textarea>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">保存</button>
            <a href="<mt:var name="script_url">?__mode=your_list" class="btn btn-secondary">キャンセル</a>
        </div>
    </form>
</mt:setvarblock>

<mt:include name="layout/default.tmpl">
```

---

## 🔄 コールバックとフック

### コールバックシステム

MovableTypeはコールバックシステムを通じて、様々なタイミングでカスタム処理を実行できます。これにより、CMSの動作に独自の処理を組み込むことが可能です。

*参考: [MovableType コールバック・フックシステム](https://manual.movabletype.jp/developer/plugins/callbacks.html)*

#### 主要なコールバック

```perl
package YourPluginName::Callback;

use strict;
use warnings;

# CMS初期化時
sub cms_init_request {
    my ($cb, $app) = @_;
    
    # カスタムモードの追加
    $app->add_methods(
        your_list => \&your_list,
        your_edit => \&your_edit,
        your_save => \&your_save,
        your_delete => \&your_delete,
    );
}

# テンプレート出力前
sub template_source {
    my ($cb, $app, $tmpl_ref) = @_;
    
    # テンプレートの動的変更
    $$tmpl_ref =~ s/<!-- カスタム挿入ポイント -->/カスタムコンテンツ/g;
}

# エントリー保存前
sub pre_save_entry {
    my ($cb, $obj, $original) = @_;
    
    # エントリーの内容を自動変換
    my $text = $obj->text;
    $text =~ s/特定パターン/置換文字列/g;
    $obj->text($text);
}

# エントリー保存後
sub post_save_entry {
    my ($cb, $obj, $original) = @_;
    
    # 外部サービスへの通知など
    notify_external_service($obj);
}

1;
```

#### よく使用されるコールバック

| コールバック名 | 実行タイミング | 用途 |
|---------------|---------------|------|
| `cms_init_request` | CMS初期化時 | カスタムモードの追加 |
| `pre_save_*` | オブジェクト保存前 | データの前処理 |
| `post_save_*` | オブジェクト保存後 | 外部通知、連携処理 |
| `template_source.*` | テンプレート表示前 | テンプレートの動的変更 |
| `build_page` | ページ生成時 | 静的ファイル生成処理 |

---

## 🗄️ データベース統合

MovableTypeは独自のORM（Object-Relational Mapping）システムである`MT::Object`を提供しています。これにより、データベース操作を直感的に記述できます。

*参考: [MovableType データベースオブジェクトシステム](https://manual.movabletype.jp/developer/plugins/object.html)*

### オブジェクトの基本操作

```perl
# オブジェクトの作成
my $obj = YourPluginName::YourObject->new;
$obj->name('サンプルオブジェクト');
$obj->description('説明文');
$obj->save or die $obj->errstr;

# オブジェクトの読み込み
my $obj = YourPluginName::YourObject->load($id);

# 条件指定での読み込み
my $obj = YourPluginName::YourObject->load({ name => 'サンプル' });

# 複数オブジェクトの読み込み
my @objects = YourPluginName::YourObject->load({ status => 1 });

# オブジェクトの更新
$obj->description('更新された説明');
$obj->save or die $obj->errstr;

# オブジェクトの削除
$obj->remove or die $obj->errstr;
```

### 高度なクエリ

```perl
# 条件指定とソート
my @objects = YourPluginName::YourObject->load(
    { status => 1 },
    {
        sort => 'created_on',
        direction => 'descend',
        limit => 10,
        offset => 0,
    }
);

# カウント
my $count = YourPluginName::YourObject->count({ status => 1 });

# JOIN操作
my @objects = YourPluginName::YourObject->load(
    { 'author.status' => 1 },
    {
        join => MT::Author->join_on('id', { id => \'= your_object_author_id' }),
    }
);
```

### データベーススキーマのアップグレード

```perl
# lib/YourPluginName/Upgrade.pm
package YourPluginName::Upgrade;

use strict;
use warnings;

# バージョン1.1への移行
sub upgrade_to_1_1 {
    my $plugin = shift;
    
    # 新しいカラムの追加
    my $driver = MT::Object->driver;
    my $ddl = $driver->dbd->ddl_class;
    
    $ddl->add_column('your_object', 'new_column', 'string(100)');
    
    # 既存データの更新
    my @objects = YourPluginName::YourObject->load;
    for my $obj (@objects) {
        $obj->new_column('デフォルト値');
        $obj->save;
    }
}

1;
```

---

## 📚 実践例: 既存プラグインの解説

このプロジェクトには2つの実践的なプラグインが含まれています。これらの実例は本リポジトリ内の実際のコードに基づいています。

*注: 以下の解説は本プロジェクト（[g-kari/movabletypetest](https://github.com/g-kari/movabletypetest)）内の実際のプラグインソースコードを参考にしています。*

### 1. ShadowverseDeckBuilder プラグイン

#### 概要
Shadowverseカードゲームのデッキ構築システムを提供するプラグイン。Vue.jsを活用したモダンなフロントエンドを特徴とします。

#### 主要機能
- **カード管理**: Shadowverseカードのデータベース管理
- **デッキ構築**: インタラクティブなデッキエディター
- **公開デッキ**: デッキの共有とOGP対応
- **Vue.js統合**: モダンなユーザーインターフェース

#### 技術的特徴

**config.yaml の活用**
```yaml
object_types:
  svcard:
    card_id: string(50) not null
    name: string(255) not null
    cost: integer not null
    attack: integer
    life: integer
    type: string(20) not null
    class: string(20) not null
    
  svdeck:
    title: string(255) not null
    description: text
    class: string(20) not null
    cards_data: text
    is_public: boolean default 0
    share_token: string(32)
```

**コールバック活用例**
```perl
# lib/ShadowverseDeckBuilder/Callback.pm より抜粋
sub cms_init_request {
    my ($cb, $app) = @_;
    
    # 公開デッキ表示用のルート追加
    $app->add_methods(
        'public_deck_view' => \&public_deck_view,
        'public_deck_create' => \&public_deck_create,
        'api_cards' => \&api_cards,
    );
}
```

#### 学べるポイント
1. **複雑なデータモデル**: カードとデッキの関係性の実装
2. **JSON API**: フロントエンド連携のためのAPI提供
3. **OGP対応**: ソーシャルメディア対応の実装
4. **Vue.js統合**: モダンフロントエンドとの連携方法

### 2. CloudFrontClearCaches プラグイン

#### 概要
AWS CloudFrontのキャッシュクリア機能を提供するシンプルなプラグイン。外部サービス連携の良い例です。

#### 技術的特徴

**設定項目の定義**
```yaml
config_settings:
  CloudFrontDistributionID:
    type: TEXTINPUT
    label: 'CloudFront Distribution ID'
    required: 1
  CloudFrontAccessKeyID:
    type: TEXTINPUT
    label: 'AWS Access Key ID'
    required: 1
```

#### 学べるポイント
1. **外部API連携**: AWS サービスとの統合方法
2. **設定管理**: 管理画面での設定項目の実装
3. **エラーハンドリング**: 外部サービス連携時のエラー処理

---

## ✅ ベストプラクティス

### 1. セキュリティ

セキュリティはWebアプリケーション開発において最重要事項です。MovableTypeプラグイン開発でも適切なセキュリティ対策を実装する必要があります。

*参考: [MovableType セキュリティベストプラクティス](https://manual.movabletype.jp/developer/security/)*
*参考: [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Webアプリケーションセキュリティの国際標準*

#### 入力値の検証
```perl
sub validate_input {
    my ($input) = @_;
    
    # HTMLエスケープ
    $input = MT::Util::encode_html($input);
    
    # SQLインジェクション対策（MT::Objectを使用する限り自動で対策済み）
    # XSS対策
    $input =~ s/<script[^>]*>.*?<\/script>//gsi;
    
    return $input;
}
```

#### 権限チェック
```perl
sub check_permission {
    my ($app) = @_;
    
    my $user = $app->user;
    return $app->error("認証が必要です") unless $user;
    
    my $perms = $user->permissions;
    return $app->error("権限がありません") unless $perms->can_do('your_permission');
    
    return 1;
}
```

### 2. パフォーマンス

データベースクエリの最適化とキャッシュの活用は、プラグインのパフォーマンスに大きく影響します。

*参考: [データベースパフォーマンス最適化](https://manual.movabletype.jp/developer/performance/) - MovableType公式ガイド*

#### データベースクエリの最適化
```perl
# Bad: N+1クエリ問題
my @entries = MT::Entry->load;
for my $entry (@entries) {
    my $author = MT::Author->load($entry->author_id);  # 毎回DB検索
}

# Good: JOINを使用
my @entries = MT::Entry->load(
    undef,
    {
        join => MT::Author->join_on('id', { id => \'= entry_author_id' }),
    }
);
```

#### キャッシュの活用
```perl
# キャッシュキーの生成
my $cache_key = 'plugin_data_' . $blog_id . '_' . $user_id;

# キャッシュから取得
my $data = MT->request->{$cache_key};
unless ($data) {
    # 重い処理
    $data = expensive_calculation();
    MT->request->{$cache_key} = $data;
}
```

### 3. 国際化対応

#### 言語ファイルの作成
```yaml
# phrases.yaml
phrases:
  'Your Plugin Name': 'あなたのプラグイン名'
  'Save': '保存'
  'Cancel': 'キャンセル'
  'Delete': '削除'
```

#### テンプレートでの使用
```html
<button type="submit"><__trans phrase="Save"></button>
<a href="#"><__trans phrase="Cancel"></a>
```

### 4. テスト

プラグインの品質を確保するため、適切なテストの実装は不可欠です。

*参考: [Test::More](https://metacpan.org/pod/Test::More) - Perl標準テストフレームワーク*
*参考: [MovableType テスト手法](https://manual.movabletype.jp/developer/testing/) - 公式テストガイド*

#### 単体テストの例
```perl
# t/your_plugin.t
use strict;
use warnings;
use Test::More;

use MT::Test qw( :app :db );
use YourPluginName::YourObject;

# テストデータの作成
my $obj = YourPluginName::YourObject->new;
$obj->name('テストオブジェクト');
$obj->save;

# テスト実行
ok($obj->id, 'オブジェクトが保存された');
is($obj->name, 'テストオブジェクト', '名前が正しく設定された');

done_testing;
```

### 5. エラーハンドリング

```perl
sub safe_operation {
    my ($self) = @_;
    
    eval {
        # 危険な処理
        dangerous_operation();
    };
    
    if ($@) {
        MT->log({
            message => "エラーが発生しました: $@",
            level => MT->model('log')->ERROR(),
            class => 'plugin',
        });
        return 0;
    }
    
    return 1;
}
```

---

## 🔗 参考リンク

### 公式ドキュメント
- [MovableType 公式サイト](https://www.movabletype.jp/) - シックス・アパート公式MovableTypeサイト
- [MovableType 7 開発者ガイド](https://manual.movabletype.jp/developer/) - 公式開発者向けマニュアル
- [MovableType プラグイン開発リファレンス](https://manual.movabletype.jp/developer/plugins/) - プラグイン開発公式ガイド
- [MovableType テンプレートタグリファレンス](https://manual.movabletype.jp/appendices/tags/) - テンプレートタグ完全リファレンス
- [MovableType データベーススキーマ](https://manual.movabletype.jp/appendices/database-schema.html) - データベース構造詳細

### プラグイン配布・情報サイト
- [GitHub - MovableType関連](https://github.com/topics/movabletype) - GitHubのMovableTypeプロジェクト
- [MovableType.jp - プラグイン](https://www.movabletype.jp/plugins/) - 公式プラグイン情報
- [PowerCMS](https://www.powercms.jp/) - MovableTypeベースのCMSとプラグイン情報

### 技術情報・チュートリアル
- [アルファサード技術ブログ](https://www.alfasado.net/blog/) - MovableType開発会社による技術情報
- [シックス・アパート技術ブログ](https://tech.sixapart.jp/) - MovableType開発元の技術情報
- [MovableType 開発Tips集](https://wiki.movabletype.org/MovableType_Developer_Tips) - コミュニティWiki
- [CPAN MT::* モジュール](https://metacpan.org/search?q=MT%3A%3A) - MovableType関連PerlモジュールCPANリスト

### コミュニティ・サポート
- [MovableType Community](https://community.movabletype.org/) - 公式コミュニティフォーラム
- [Stack Overflow - MovableType](https://stackoverflow.com/questions/tagged/movabletype) - 技術的質問・回答
- [MovableType Users Group Japan](https://www.facebook.com/groups/MTUserJapan/) - 日本のユーザーグループ
- [Qiita - MovableType](https://qiita.com/tags/movabletype) - 日本語技術記事プラットフォーム

### Perl関連リソース
- [Perl.org](https://www.perl.org/) - Perl公式サイト
- [CPAN](https://metacpan.org/) - Perlモジュールライブラリ
- [Perl Documentation](https://perldoc.perl.org/) - Perl公式ドキュメント
- [Modern Perl](http://modernperlbooks.com/) - モダンPerl開発手法

### 開発ツール・リソース
- [MovableType Docker環境](https://github.com/movabletype/docker-mt) - 公式Docker環境
- [MT-DevTools](https://github.com/movabletype/mt-devtools) - 開発支援ツール
- [Melody Project](https://github.com/openmelody/melody) - MovableType派生オープンソースプロジェクト

---

## 📝 まとめ

MovableTypeのプラグイン開発は、Perlの知識とMovableTypeのアーキテクチャの理解があれば、非常に強力で柔軟な拡張機能を作成できます。

### 開発のステップ
1. **要件定義**: 何を実現したいかを明確化
2. **設計**: データモデルとユーザーインターフェースの設計
3. **実装**: config.yaml、Perlモジュール、テンプレートの作成
4. **テスト**: 機能テストとセキュリティテストの実施
5. **デプロイ**: 本番環境への適用

### 成功のポイント
- **小さく始める**: 最初はシンプルな機能から開始
- **公式ドキュメントを活用**: 最新の情報を常に参照
- **既存プラグインを参考**: 本プロジェクトの実例や他のプラグインを研究
- **コミュニティを活用**: 困った時はフォーラムやコミュニティで質問

このガイドが、MovableTypeプラグイン開発の第一歩として役立つことを願っています。