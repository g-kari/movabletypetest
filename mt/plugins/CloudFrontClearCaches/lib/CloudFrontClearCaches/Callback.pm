package CloudFrontClearCaches::Callback;

use strict;
use warnings;
use MT::Util qw( log_time );
use CloudFrontClearCaches::Util;

sub invalidate_on_save {
    my ( $cb, $app, $obj, $original ) = @_;
    
    return 1 unless MT->config('CloudFrontAutoInvalidate');
    
    # 自動無効化が有効な場合のみ実行
    if ( MT->config('CloudFrontAutoInvalidate') ) {
        CloudFrontClearCaches::Util::invalidate_cache();
    }
    
    return 1;
}

sub invalidate_on_rebuild {
    my ( $cb, %args ) = @_;
    
    return 1 unless MT->config('CloudFrontAutoInvalidate');
    
    # 再構築時にキャッシュを無効化
    if ( MT->config('CloudFrontAutoInvalidate') ) {
        CloudFrontClearCaches::Util::invalidate_cache();
    }
    
    return 1;
}

1;