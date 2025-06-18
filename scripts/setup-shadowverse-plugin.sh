#!/bin/bash
# ShadowverseDeckBuilder Plugin Setup Script

set -e

echo "Setting up ShadowverseDeckBuilder plugin..."

# First, ensure the plugin tables exist by running MT upgrade
docker-compose exec -T movabletype bash -c "
cd /var/www/cgi-bin/mt
export MT_CONFIG=/var/www/cgi-bin/mt/mt-config.cgi
perl tools/upgrade --name admin 2>/dev/null || true
"

# Wait a moment for tables to be created
sleep 2

# Check if tables exist, if not create them
docker-compose exec -T mysql mysql -u mt -pmovabletype mt << 'EOF'
CREATE TABLE IF NOT EXISTS mt_svcard (
    id int NOT NULL AUTO_INCREMENT,
    card_id varchar(50) NOT NULL,
    name varchar(255) NOT NULL,
    name_en varchar(255),
    cost int NOT NULL,
    attack int,
    life int,
    type varchar(20) NOT NULL,
    class varchar(20) NOT NULL,
    rarity varchar(20) NOT NULL,
    set_name varchar(100),
    description text,
    image_url varchar(500),
    PRIMARY KEY (id),
    KEY card_id (card_id),
    KEY class (class),
    KEY cost (cost),
    KEY type (type),
    KEY rarity (rarity)
);

CREATE TABLE IF NOT EXISTS mt_svdeck (
    id int NOT NULL AUTO_INCREMENT,
    title varchar(255) NOT NULL,
    description text,
    class varchar(20) NOT NULL,
    class_jp varchar(50),
    cards_data text,
    is_public tinyint DEFAULT 0,
    author_id int,
    author_name varchar(255),
    created_on varchar(14),
    modified_on varchar(14),
    share_token varchar(50),
    PRIMARY KEY (id),
    KEY author_id (author_id),
    KEY class (class),
    KEY is_public (is_public)
);
EOF

# Create sample cards
docker-compose exec -T mysql mysql -u mt -pmovabletype mt << 'EOF'
INSERT IGNORE INTO mt_svcard (card_id, name, name_en, cost, attack, life, type, class, rarity, set_name, description, image_url) VALUES
('SV_001', 'フェアリー', 'Fairy', 1, 1, 1, 'follower', 'elf', 'bronze', 'Basic', '基本的なエルフフォロワー', ''),
('SV_002', 'ゴブリン', 'Goblin', 1, 2, 1, 'follower', 'neutral', 'bronze', 'Basic', '基本的なニュートラルフォロワー', ''),
('SV_003', 'エンジェル', 'Angel', 2, 2, 2, 'follower', 'bishop', 'bronze', 'Basic', '基本的なビショップフォロワー', ''),
('SV_004', 'ナイト', 'Knight', 2, 2, 3, 'follower', 'royal', 'silver', 'Basic', '基本的なロイヤルフォロワー', ''),
('SV_005', 'ファイアーボール', 'Fireball', 3, 0, 0, 'spell', 'witch', 'bronze', 'Basic', '3ダメージを与える', '');
EOF

# Create sample deck
docker-compose exec -T mysql mysql -u mt -pmovabletype mt << 'EOF'
INSERT IGNORE INTO mt_svdeck (title, description, class, class_jp, cards_data, is_public, author_id, author_name, created_on, modified_on, share_token) VALUES
('サンプルエルフデッキ', 'エルフクラスのサンプルデッキです', 'elf', 'エルフ', '[{"card_id":"SV_001","count":3},{"card_id":"SV_002","count":3}]', 1, 1, 'admin', '20250618120000', '20250618120000', 'sample123');
EOF

echo "ShadowverseDeckBuilder plugin setup completed!"