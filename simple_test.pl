#!/usr/bin/env perl

use strict;
use warnings;

# プラグイン構造の基本テスト（外部モジュール不要版）
my $plugin_dir = './mt/plugins/ShadowverseDeckBuilder';

print "=== Shadowverse Deck Builder Plugin Structure Test ===\n\n";

# 基本ディレクトリ構造のテスト
print "Testing directory structure...\n";
my @required_dirs = (
    $plugin_dir,
    "$plugin_dir/lib",
    "$plugin_dir/lib/ShadowverseDeckBuilder",
    "$plugin_dir/tmpl",
);

for my $dir (@required_dirs) {
    if (-d $dir) {
        print "✓ Directory exists: $dir\n";
    } else {
        print "✗ Directory missing: $dir\n";
    }
}

# 必要なファイルのテスト
print "\nTesting required files...\n";
my @required_files = (
    "$plugin_dir/config.yaml",
    "$plugin_dir/README.md",
    "$plugin_dir/sample_cards.sql",
    "$plugin_dir/lib/ShadowverseDeckBuilder/SVCard.pm",
    "$plugin_dir/lib/ShadowverseDeckBuilder/SVDeck.pm",
    "$plugin_dir/lib/ShadowverseDeckBuilder/CMS.pm",
    "$plugin_dir/lib/ShadowverseDeckBuilder/Tags.pm",
    "$plugin_dir/lib/ShadowverseDeckBuilder/Callback.pm",
    "$plugin_dir/tmpl/deck_list.tmpl",
    "$plugin_dir/tmpl/deck_edit.tmpl",
    "$plugin_dir/tmpl/deck_share.tmpl",
);

my $files_ok = 0;
my $total_files = scalar @required_files;

for my $file (@required_files) {
    if (-f $file) {
        print "✓ File exists: $file\n";
        $files_ok++;
    } else {
        print "✗ File missing: $file\n";
    }
}

# Vue.jsコンポーネントのテスト
print "\nTesting Vue.js components...\n";
my @vue_files = (
    './themes/vue-template/src/components/DeckEditor.vue',
    './themes/vue-template/src/main.js',
);

my $vue_ok = 0;
my $total_vue = scalar @vue_files;

for my $file (@vue_files) {
    if (-f $file) {
        print "✓ Vue file exists: $file\n";
        $vue_ok++;
        
        # DeckEditor.vueの基本構造チェック
        if ($file =~ /DeckEditor\.vue$/) {
            open my $fh, '<', $file or die "Cannot open $file: $!";
            my $content = do { local $/; <$fh> };
            close $fh;
            
            if ($content =~ /<template>/ && $content =~ /<script>/ && $content =~ /<style/) {
                print "  ✓ DeckEditor.vue has proper Vue component structure\n";
            } else {
                print "  ✗ DeckEditor.vue missing Vue component sections\n";
            }
        }
        
        # main.jsのDeckEditor importチェック
        if ($file =~ /main\.js$/) {
            open my $fh, '<', $file or die "Cannot open $file: $!";
            my $content = do { local $/; <$fh> };
            close $fh;
            
            if ($content =~ /import.*DeckEditor.*from/) {
                print "  ✓ DeckEditor is imported in main.js\n";
            } else {
                print "  ✗ DeckEditor not imported in main.js\n";
            }
            
            if ($content =~ /mountDeckEditor/) {
                print "  ✓ mountDeckEditor method exists\n";
            } else {
                print "  ✗ mountDeckEditor method missing\n";
            }
        }
    } else {
        print "✗ Vue file missing: $file\n";
    }
}

# config.yamlの基本チェック
print "\nTesting config.yaml structure...\n";
if (-f "$plugin_dir/config.yaml") {
    open my $fh, '<', "$plugin_dir/config.yaml" or die "Cannot open config.yaml: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    my @config_checks = (
        ['id: ShadowverseDeckBuilder', 'Plugin ID'],
        ['name: Shadowverse Deck Builder', 'Plugin name'],
        ['object_drivers:', 'Object drivers section'],
        ['svdeck:', 'SVDeck object driver'],
        ['svcard:', 'SVCard object driver'],
        ['applications:', 'Applications section'],
        ['cms:', 'CMS application'],
        ['methods:', 'CMS methods'],
        ['tags:', 'Tags section']
    );
    
    for my $check (@config_checks) {
        my ($pattern, $description) = ($check->[0], $check->[1]);
        if ($content =~ /\Q$pattern\E/) {
            print "  ✓ $description found\n";
        } else {
            print "  ✗ $description missing\n";
        }
    }
}

# Perlファイルの基本構文チェック
print "\nTesting Perl file syntax...\n";
opendir my $dh, "$plugin_dir/lib/ShadowverseDeckBuilder" or die "Cannot open lib directory: $!";
my @pm_files = grep { /\.pm$/ } readdir $dh;
closedir $dh;

for my $file (@pm_files) {
    my $full_path = "$plugin_dir/lib/ShadowverseDeckBuilder/$file";
    open my $fh, '<', $full_path or die "Cannot open $full_path: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    print "  Testing $file:\n";
    
    if ($content =~ /^package\s+\w+/m) {
        print "    ✓ Package declaration found\n";
    } else {
        print "    ✗ Package declaration missing\n";
    }
    
    if ($content =~ /use strict/) {
        print "    ✓ 'use strict' found\n";
    } else {
        print "    ✗ 'use strict' missing\n";
    }
    
    if ($content =~ /use warnings/) {
        print "    ✓ 'use warnings' found\n";
    } else {
        print "    ✗ 'use warnings' missing\n";
    }
    
    if ($content =~ /^1;?\s*$/m) {
        print "    ✓ Ends with true value\n";
    } else {
        print "    ✗ Does not end with true value\n";
    }
}

# 結果サマリー
print "\n=== Test Summary ===\n";
print "Required files: $files_ok/$total_files\n";
print "Vue.js files: $vue_ok/$total_vue\n";

if ($files_ok == $total_files && $vue_ok == $total_vue) {
    print "✓ All tests passed! Plugin structure is complete.\n";
    print "\nNext steps:\n";
    print "1. Install the plugin in MovableType\n";
    print "2. Run database upgrades to create tables\n";
    print "3. Import sample card data\n";
    print "4. Test deck building functionality\n";
} else {
    print "✗ Some tests failed. Please check the missing files.\n";
}

print "\n=== Plugin Features ===\n";
print "- Deck building interface with Vue.js\n";
print "- Database storage for decks and cards\n";
print "- Share functionality with OGP support\n";
print "- User recognition via MovableType\n";
print "- Template tags for frontend integration\n";
print "- Admin interface for deck management\n";