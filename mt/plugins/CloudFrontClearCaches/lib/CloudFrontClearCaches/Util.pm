package CloudFrontClearCaches::Util;

use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use POSIX qw(strftime);
use Digest::SHA qw(hmac_sha256 sha256_hex);
use MIME::Base64;
use MT::Util qw( log_time );

sub invalidate_cache {
    my %args = @_;
    
    # 設定の読み込み
    my $distribution_id = MT->config("CloudFrontDistributionID");
    my $access_key = MT->config("CloudFrontAccessKeyID");
    my $secret_key = MT->config("CloudFrontSecretAccessKey");
    my $region = MT->config("CloudFrontRegion") || "us-east-1";
    
    # 設定チェック
    unless ( $distribution_id && $access_key && $secret_key ) {
        return {
            success => 0,
            error => "CloudFront設定が不完全です。プラグイン設定を確認してください。"
        };
    }
    
    # 無効化パスの設定
    my $paths = $args{paths} || ["/*"];
    
    # 無効化リクエストのペイロード作成
    my $invalidation_batch = {
        Paths => {
            Quantity => scalar(@$paths),
            Items => $paths
        },
        CallerReference => "mt-plugin-" . time()
    };
    
    my $json = JSON->new->utf8;
    my $body = $json->encode({ InvalidationBatch => $invalidation_batch });
    
    # AWS API リクエスト
    my $result = _make_cloudfront_request(
        method => "POST",
        path => "/2020-05-31/distribution/$distribution_id/invalidation",
        body => $body,
        access_key => $access_key,
        secret_key => $secret_key,
        region => $region
    );
    
    if ( $result->{success} ) {
        MT->log({
            message => "CloudFront invalidation request sent successfully",
            level => MT::Log::INFO(),
            class => "system"
        });
        
        return {
            success => 1,
            response => $result->{response}
        };
    } else {
        MT->log({
            message => "CloudFront invalidation failed: " . $result->{error},
            level => MT::Log::ERROR(),
            class => "system"
        });
        
        return {
            success => 0,
            error => $result->{error}
        };
    }
}

sub _make_cloudfront_request {
    my %args = @_;
    
    my $method = $args{method} || "GET";
    my $path = $args{path};
    my $body = $args{body} || "";
    my $access_key = $args{access_key};
    my $secret_key = $args{secret_key};
    my $region = $args{region} || "us-east-1";
    
    my $host = "cloudfront.amazonaws.com";
    my $service = "cloudfront";
    
    # タイムスタンプ
    my $now = time();
    my $datestamp = strftime("%Y%m%d", gmtime($now));
    my $timestamp = strftime("%Y%m%dT%H%M%SZ", gmtime($now));
    
    # ヘッダー
    my %headers = (
        "Host" => $host,
        "Content-Type" => "application/json",
        "X-Amz-Date" => $timestamp,
    );
    
    if ( $body ) {
        $headers{"Content-Length"} = length($body);
    }
    
    # Canonical request
    my $canonical_headers = "";
    my $signed_headers = "";
    for my $key ( sort keys %headers ) {
        my $lc_key = lc($key);
        $canonical_headers .= "$lc_key:" . $headers{$key} . "\n";
        $signed_headers .= $lc_key . ";";
    }
    $signed_headers =~ s/;$//;
    
    my $payload_hash = sha256_hex($body);
    my $canonical_request = join("\n",
        $method,
        $path,
        "",  # query string
        $canonical_headers,
        $signed_headers,
        $payload_hash
    );
    
    # String to sign
    my $algorithm = "AWS4-HMAC-SHA256";
    my $credential_scope = "$datestamp/$region/$service/aws4_request";
    my $string_to_sign = join("\n",
        $algorithm,
        $timestamp,
        $credential_scope,
        sha256_hex($canonical_request)
    );
    
    # Signing key
    my $k_date = hmac_sha256($datestamp, "AWS4" . $secret_key);
    my $k_region = hmac_sha256($region, $k_date);
    my $k_service = hmac_sha256($service, $k_region);
    my $k_signing = hmac_sha256("aws4_request", $k_service);
    
    # Signature
    my $signature = unpack("H*", hmac_sha256($string_to_sign, $k_signing));
    
    # Authorization header
    my $authorization = "$algorithm Credential=$access_key/$credential_scope, SignedHeaders=$signed_headers, Signature=$signature";
    $headers{"Authorization"} = $authorization;
    
    # HTTP リクエスト実行
    my $ua = LWP::UserAgent->new(timeout => 30);
    my $url = "https://$host$path";
    
    my $request;
    if ( $method eq "POST" ) {
        $request = HTTP::Request->new(POST => $url);
        $request->content($body) if $body;
    } else {
        $request = HTTP::Request->new(GET => $url);
    }
    
    for my $key ( keys %headers ) {
        $request->header($key => $headers{$key});
    }
    
    my $response = $ua->request($request);
    
    if ( $response->is_success ) {
        return {
            success => 1,
            response => $response->content
        };
    } else {
        return {
            success => 0,
            error => "HTTP " . $response->code . ": " . $response->message
        };
    }
}

1;
