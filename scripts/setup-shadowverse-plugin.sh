#!/bin/bash
# ShadowverseDeckBuilder Plugin Setup Script

set -e

echo "Setting up ShadowverseDeckBuilder plugin..."

# Create sample cards
docker-compose exec mysql mysql -u mt -pmovabletype mt << 'EOF'
INSERT IGNORE INTO mt_svcard (card_id, name, name_en, cost, attack, life, type, class, rarity, set_name, description, image_url) VALUES
('SV_001', 'フェアリー', 'Fairy', 1, 1, 1, 'follower', 'elf', 'bronze', 'Basic', '基本的なエルフフォロワー', ''),
('SV_002', 'ゴブリン', 'Goblin', 1, 2, 1, 'follower', 'neutral', 'bronze', 'Basic', '基本的なニュートラルフォロワー', ''),
('SV_003', 'エンジェル', 'Angel', 2, 2, 2, 'follower', 'bishop', 'bronze', 'Basic', '基本的なビショップフォロワー', ''),
('SV_004', 'ナイト', 'Knight', 2, 2, 3, 'follower', 'royal', 'silver', 'Basic', '基本的なロイヤルフォロワー', ''),
('SV_005', 'ファイアーボール', 'Fireball', 3, 0, 0, 'spell', 'witch', 'bronze', 'Basic', '3ダメージを与える', '');
EOF

# Create sample deck
docker-compose exec mysql mysql -u mt -pmovabletype mt << 'EOF'
INSERT IGNORE INTO mt_svdeck (title, description, class, class_jp, cards_data, is_public, author_id, author_name, created_on, modified_on, share_token) VALUES
('サンプルエルフデッキ', 'エルフクラスのサンプルデッキです', 'elf', 'エルフ', '[{"card_id":"SV_001","count":3},{"card_id":"SV_002","count":3}]', 1, 1, 'admin', '20250618120000', '20250618120000', 'sample123');
EOF

echo "ShadowverseDeckBuilder plugin setup completed!"