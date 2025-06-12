package CloudFrontClearCaches::CMS;

use strict;
use warnings;
use MT::Util qw( encode_html );
use CloudFrontClearCaches::Util;

sub clear_caches_mode {
    my $app = shift;
    
    # 権限チェック
    return $app->permission_denied()
        unless $app->user->is_superuser();
    
    my $param = {};
    
    # プラグイン設定の読み込み
    $param->{distribution_id} = MT->config("CloudFrontDistributionID") || "";
    $param->{access_key_id} = MT->config("CloudFrontAccessKeyID") || "";
    $param->{secret_access_key} = MT->config("CloudFrontSecretAccessKey") || "";
    $param->{region} = MT->config("CloudFrontRegion") || "us-east-1";
    
    # 設定が不完全な場合の警告
    if ( !$param->{distribution_id} || !$param->{access_key_id} || !$param->{secret_access_key} ) {
        $param->{config_incomplete} = 1;
    }
    
    # テンプレートを返す
    return $app->load_tmpl( "cloudfront_clear_caches.tmpl", $param );
}

sub do_clear_caches {
    my $app = shift;
    
    # 権限チェック
    return $app->permission_denied()
        unless $app->user->is_superuser();
    
    my $result = CloudFrontClearCaches::Util::invalidate_cache();
    
    if ( $result->{success} ) {
        return $app->call_return(
            message => "CloudFrontキャッシュの無効化リクエストを送信しました。",
            args => { __mode => "cloudfront_clear_caches" }
        );
    } else {
        return $app->error( $result->{error} );
    }
}

1;
