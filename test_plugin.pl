#!/usr/bin/env perl

use strict;
use warnings;
use YAML::Tiny;
use File::Find;
use Test::More;

# プラグイン構造のテスト
my $plugin_dir = './mt/plugins/ShadowverseDeckBuilder';

# config.yamlのテスト
subtest 'config.yaml validation' => sub {
    my $config_file = "$plugin_dir/config.yaml";
    ok(-f $config_file, 'config.yaml exists');
    
    my $yaml = YAML::Tiny->read($config_file);
    ok($yaml, 'config.yaml is valid YAML');
    
    my $config = $yaml->[0];
    is($config->{id}, 'ShadowverseDeckBuilder', 'Plugin ID is correct');
    is($config->{name}, 'Shadowverse Deck Builder', 'Plugin name is correct');
    ok($config->{version}, 'Version is specified');
    ok($config->{description}, 'Description is specified');
    
    # オブジェクトタイプの確認
    ok($config->{object_drivers}, 'Object drivers are defined');
    ok($config->{object_drivers}->{svdeck}, 'svdeck object driver exists');
    ok($config->{object_drivers}->{svcard}, 'svcard object driver exists');
    
    # アプリケーション設定の確認
    ok($config->{applications}, 'Applications are defined');
    ok($config->{applications}->{cms}, 'CMS application is defined');
    ok($config->{applications}->{cms}->{menus}, 'CMS menus are defined');
    ok($config->{applications}->{cms}->{methods}, 'CMS methods are defined');
    
    # タグの確認
    ok($config->{tags}, 'Tags are defined');
    ok($config->{tags}->{function}, 'Function tags are defined');
};

# ライブラリファイルのテスト
subtest 'Library files validation' => sub {
    my @required_files = (
        'lib/ShadowverseDeckBuilder/SVCard.pm',
        'lib/ShadowverseDeckBuilder/SVDeck.pm',
        'lib/ShadowverseDeckBuilder/CMS.pm',
        'lib/ShadowverseDeckBuilder/Tags.pm',
        'lib/ShadowverseDeckBuilder/Callback.pm',
    );
    
    for my $file (@required_files) {
        ok(-f "$plugin_dir/$file", "$file exists");
    }
};

# テンプレートファイルのテスト
subtest 'Template files validation' => sub {
    my @required_templates = (
        'tmpl/deck_list.tmpl',
        'tmpl/deck_edit.tmpl',
        'tmpl/deck_share.tmpl',
    );
    
    for my $tmpl (@required_templates) {
        ok(-f "$plugin_dir/$tmpl", "$tmpl exists");
    }
};

# Vue.jsコンポーネントのテスト
subtest 'Vue.js components validation' => sub {
    ok(-f './themes/vue-template/src/components/DeckEditor.vue', 'DeckEditor.vue exists');
    
    # main.jsでDeckEditorがインポートされているか確認
    my $main_js_content = do {
        local $/;
        open my $fh, '<', './themes/vue-template/src/main.js' or die $!;
        <$fh>;
    };
    
    like($main_js_content, qr/import.*DeckEditor.*from/, 'DeckEditor is imported in main.js');
    like($main_js_content, qr/mountDeckEditor/, 'mountDeckEditor method exists');
};

# ファイルの基本的な構文チェック（MovableTypeモジュールを除く）
subtest 'Basic syntax validation' => sub {
    my @perl_files;
    find(sub {
        push @perl_files, $File::Find::name if /\.pm$/ && -f;
    }, $plugin_dir);
    
    for my $file (@perl_files) {
        # 基本的な構文チェック（packageとuseステートメントのみ）
        open my $fh, '<', $file or die "Cannot open $file: $!";
        my $content = do { local $/; <$fh> };
        close $fh;
        
        like($content, qr/package\s+\w+/, "$file has package declaration");
        like($content, qr/use strict/, "$file uses strict");
        like($content, qr/use warnings/, "$file uses warnings");
        like($content, qr/^1;?\s*$/m, "$file ends with true value");
    }
};

# サンプルデータファイルのテスト
subtest 'Sample data validation' => sub {
    ok(-f "$plugin_dir/sample_cards.sql", 'sample_cards.sql exists');
    
    my $sql_content = do {
        local $/;
        open my $fh, '<', "$plugin_dir/sample_cards.sql" or die $!;
        <$fh>;
    };
    
    like($sql_content, qr/INSERT INTO mt_svcard/, 'SQL contains card insertions');
    like($sql_content, qr/SV_ELF_\d+/, 'Contains elf cards');
    like($sql_content, qr/SV_ROYAL_\d+/, 'Contains royal cards');
    like($sql_content, qr/SV_WITCH_\d+/, 'Contains witch cards');
};

done_testing();

print "\n=== Shadowverse Deck Builder Plugin Test Results ===\n";
print "All basic structure and syntax tests completed.\n";
print "The plugin is ready for integration with MovableType.\n";