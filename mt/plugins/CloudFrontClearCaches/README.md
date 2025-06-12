# CloudFront Clear Caches Plugin

AWS CloudFrontのキャッシュを自動的にクリアするMovableTypeプラグインです。

## 機能

- 記事やページの公開時に自動的にCloudFrontキャッシュを無効化
- 管理画面から手動でキャッシュクリア
- 再構築時の自動キャッシュクリア
- AWS署名付きリクエストによる安全なAPI呼び出し

## インストール

1. このプラグインを `mt/plugins/CloudFrontClearCaches/` に配置
2. MovableTypeの管理画面にアクセス
3. システムメニュー > プラグイン設定 でCloudFrontClearCachesの設定を行う

## 設定項目

- **CloudFront Distribution ID**: CloudFrontディストリビューションのID
- **AWS Access Key ID**: CloudFrontにアクセスするためのAWS Access Key
- **AWS Secret Access Key**: CloudFrontにアクセスするためのAWS Secret Key
- **AWS Region**: AWSリージョン (デフォルト: us-east-1)
- **Auto Invalidate on Publish**: 自動無効化の有効/無効

## 使用方法

### 自動キャッシュクリア

プラグイン設定で「Auto Invalidate on Publish」を有効にすると、以下のタイミングで自動的にキャッシュがクリアされます：

- 記事の保存時
- ページの保存時
- サイトの再構築時

### 手動キャッシュクリア

1. 管理画面 > ツール > CloudFront Cache Clear にアクセス
2. 「キャッシュをクリア」ボタンをクリック

## 必要な権限

CloudFrontのキャッシュ無効化には、以下のIAM権限が必要です：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Resource": "arn:aws:cloudfront::*:distribution/*"
        }
    ]
}
```

## トラブルシューティング

- 設定が正しいか確認してください
- AWS認証情報が正しいか確認してください
- CloudFrontディストリビューションIDが正しいか確認してください
- MovableTypeのログでエラーメッセージを確認してください

## ライセンス

MIT License
