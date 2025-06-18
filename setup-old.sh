#!/bin/bash
# MovableType Initial Setup Script
# Fixes common setup issues and automates configuration

set -e

echo "==========================================="
echo "MovableType Setup Script Starting..."
echo "==========================================="

# Check if running in correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found. Run this script from the project root directory."
    exit 1
fi

# Step 1: Start Docker services
echo "Step 1: Starting Docker services..."
docker-compose down || true
docker-compose up -d

# Step 2: Wait for services to be ready
echo "Step 2: Waiting for services to be ready..."
sleep 10  # Wait for containers to start

echo "Step 3: Running configuration scripts..."

# Run individual setup scripts
echo "Running Apache configuration fix..."
./scripts/fix-apache-config.sh

echo "Running MovableType configuration fix..."
./scripts/fix-mt-config.sh

echo "Running database initialization..."
./scripts/init-database.sh

echo "Running ShadowverseDeckBuilder plugin setup..."
./scripts/setup-shadowverse-plugin.sh

# Step 4: Restart services to apply changes
echo "Step 4: Restarting services to apply changes..."
docker-compose restart

# Step 5: Final verification
echo "Step 5: Final verification..."
sleep 5

echo ""
echo "==========================================="
echo "Setup Complete!"
echo "==========================================="
echo ""
echo "Access your MovableType installation at:"
echo "  🌐 Main site: http://localhost:8080"
echo "  ⚙️  Admin: http://localhost:8080/cgi-bin/mt/mt.cgi"
echo ""
echo "Database access:"
echo "  Host: localhost:3307"
echo "  Database: mt"
echo "  Username: mt"
echo "  Password: movabletype"
echo ""
echo "ShadowverseDeckBuilder plugin should be available in:"
echo "  Tools → Shadowverse Deck Builder"
echo ""
echo "==========================================="
cd /var/www/html/mt

# Check if mt-config.cgi exists, create if missing
if [ ! -f mt-config.cgi ]; then
    echo 'Creating mt-config.cgi...'
    cat > mt-config.cgi << 'EOF'
CGIPath /var/www/html/mt/
StaticWebPath /mt-static/
StaticFilePath /var/www/html/mt-static/

Database mysql
DBUser movabletype
DBPassword password
DBHost db
DBPort 3306
DBName movabletype

DefaultLanguage ja
DefaultTimezone +09:00

AdminCGIPath /mt/
AdminScript mt.cgi

PublishCharset utf-8
LogConfig /tmp/mt.log

PluginPath plugins
ThemesDirectory themes

# Email settings (adjust as needed)
MailTransfer sendmail
SendMailPath /usr/sbin/sendmail

# Performance settings
ProcessMemoryCommand /bin/ps -o rss=
EOF
    chmod 644 mt-config.cgi
fi

# Ensure proper permissions for MovableType
chown -R www-data:www-data /var/www/html/mt
chmod 755 /var/www/html/mt/mt.cgi
chmod 755 /var/www/html/mt/mt-*.cgi
chmod 755 /var/www/html/mt/tools/*.pl
"

# Step 5: Initialize database and create admin user
echo "Step 5: Initializing database and admin user..."
docker-compose exec -T mt bash -c "
cd /var/www/html/mt
# Run MovableType installation/upgrade
perl tools/upgrade --force --non-interactive || echo 'Database initialization completed'
"

# Step 6: Install and configure ShadowverseDeckBuilder plugin
echo "Step 6: Configuring ShadowverseDeckBuilder plugin..."
docker-compose exec -T mt bash -c "
cd /var/www/html/mt
# Run upgrade to ensure plugin tables are created
perl tools/upgrade --force --non-interactive
"

# Step 7: Create sample Shadowverse cards
echo "Step 7: Creating sample Shadowverse cards..."
docker-compose exec -T db mysql -u movabletype -ppassword movabletype << 'EOF'
INSERT IGNORE INTO mt_svcard (card_id, name, name_en, cost, attack, life, type, class, rarity, set_name, description, image_url) VALUES
('SV_001', 'フェアリー', 'Fairy', 1, 1, 1, 'follower', 'elf', 'bronze', 'Basic', '基本的なエルフフォロワー', ''),
('SV_002', 'ゴブリン', 'Goblin', 1, 2, 1, 'follower', 'neutral', 'bronze', 'Basic', '基本的なニュートラルフォロワー', ''),
('SV_003', 'エンジェル', 'Angel', 2, 2, 2, 'follower', 'bishop', 'bronze', 'Basic', '基本的なビショップフォロワー', ''),
('SV_004', 'ナイト', 'Knight', 2, 2, 3, 'follower', 'royal', 'silver', 'Basic', '基本的なロイヤルフォロワー', ''),
('SV_005', 'ファイアーボール', 'Fireball', 3, 0, 0, 'spell', 'witch', 'bronze', 'Basic', '3ダメージを与える', '');
EOF

# Step 8: Create sample deck
echo "Step 8: Creating sample deck..."
docker-compose exec -T db mysql -u movabletype -ppassword movabletype << 'EOF'
INSERT IGNORE INTO mt_svdeck (title, description, class, class_jp, cards_data, is_public, author_id, author_name, created_on, modified_on, share_token) VALUES
('サンプルエルフデッキ', 'エルフクラスのサンプルデッキです', 'elf', 'エルフ', '[{"card_id":"SV_001","count":3},{"card_id":"SV_002","count":3}]', 1, 1, 'admin', '20250618120000', '20250618120000', 'sample123');
EOF

# Step 9: Fix Vue.js deck builder template
echo "Step 9: Creating Vue.js deck builder template..."
docker-compose exec -T mt bash -c "
mkdir -p /var/www/html/mt/plugins/ShadowverseDeckBuilder/tmpl
cat > /var/www/html/mt/plugins/ShadowverseDeckBuilder/tmpl/deck_edit.tmpl << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Deck Editor - Shadowverse Deck Builder</title>
    <meta charset=\"utf-8\">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 20px; }
        .deck-form { max-width: 800px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .deck-builder { margin-top: 20px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .cards-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }
        .available-cards, .deck-cards { border: 1px solid #ccc; padding: 15px; border-radius: 5px; }
        .card-item { padding: 8px; margin: 5px 0; border: 1px solid #eee; border-radius: 3px; cursor: pointer; }
        .card-item:hover { background: #f5f5f5; }
        .deck-total { font-weight: bold; color: #007cba; }
        .actions { margin-top: 20px; }
        .actions button { padding: 10px 20px; margin-right: 10px; background: #007cba; color: white; border: none; border-radius: 3px; cursor: pointer; }
        .actions button:hover { background: #005a87; }
        .actions a { padding: 10px 20px; background: #666; color: white; text-decoration: none; border-radius: 3px; }
    </style>
</head>
<body>
    <div class=\"header\">
        <h1><mt:if name=\"editing\">Edit Deck<mt:else>Create New Deck</mt:if></h1>
        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_list\">← Back to Deck List</a>
    </div>
    
    <form method=\"post\" action=\"<$mt:var name=\"script_url\"$>\" class=\"deck-form\">
        <input type=\"hidden\" name=\"__mode\" value=\"sv_deck_save\">
        <input type=\"hidden\" name=\"magic_token\" value=\"<$mt:var name=\"magic_token\"$>\">
        <mt:if name=\"editing\">
            <input type=\"hidden\" name=\"id\" value=\"<$mt:var name=\"deck.id\"$>\">
        </mt:if>
        <input type=\"hidden\" name=\"cards_data\" id=\"cards_data\" value=\"\">
        
        <div class=\"form-group\">
            <label>Deck Title:</label>
            <input type=\"text\" name=\"title\" value=\"<$mt:var name=\"deck.title\" escape=\"html\"$>\" required>
        </div>
        
        <div class=\"form-group\">
            <label>Class:</label>
            <select name=\"class\" required>
                <option value=\"\">Select Class</option>
                <option value=\"elf\"<mt:if name=\"deck.class\" eq=\"elf\"> selected</mt:if>>エルフ</option>
                <option value=\"royal\"<mt:if name=\"deck.class\" eq=\"royal\"> selected</mt:if>>ロイヤル</option>
                <option value=\"witch\"<mt:if name=\"deck.class\" eq=\"witch\"> selected</mt:if>>ウィッチ</option>
                <option value=\"dragon\"<mt:if name=\"deck.class\" eq=\"dragon\"> selected</mt:if>>ドラゴン</option>
                <option value=\"necromancer\"<mt:if name=\"deck.class\" eq=\"necromancer\"> selected</mt:if>>ネクロマンサー</option>
                <option value=\"vampire\"<mt:if name=\"deck.class\" eq=\"vampire\"> selected</mt:if>>ヴァンパイア</option>
                <option value=\"bishop\"<mt:if name=\"deck.class\" eq=\"bishop\"> selected</mt:if>>ビショップ</option>
                <option value=\"nemesis\"<mt:if name=\"deck.class\" eq=\"nemesis\"> selected</mt:if>>ネメシス</option>
            </select>
        </div>
        
        <div class=\"form-group\">
            <label>Description:</label>
            <textarea name=\"description\" rows=\"3\"><$mt:var name=\"deck.description\" escape=\"html\"$></textarea>
        </div>
        
        <div class=\"form-group\">
            <label>
                <input type=\"checkbox\" name=\"is_public\" value=\"1\"<mt:if name=\"deck.is_public\"> checked</mt:if>>
                Make deck public
            </label>
        </div>
        
        <div class=\"deck-builder\">
            <h3>Deck Builder</h3>
            <div id=\"deck-builder-app\">
                <div class=\"cards-container\">
                    <div class=\"available-cards\">
                        <h4>Available Cards</h4>
                        <div id=\"available-cards-list\">
                            <p>Loading cards...</p>
                        </div>
                    </div>
                    <div class=\"deck-cards\">
                        <h4>Deck Cards <span class=\"deck-total\">(Total: <span id=\"deck-total\">0</span>/40)</span></h4>
                        <div id=\"deck-cards-list\">
                            <p>Add cards to your deck</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class=\"actions\">
            <button type=\"submit\">Save Deck</button>
            <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_list\">Cancel</a>
        </div>
    </form>
    
    <script>
    // Simple deck builder without Vue.js dependency
    let allCards = [];
    let deckCards = [];
    
    try {
        allCards = <$mt:var name=\"all_cards\"$> || [];
        deckCards = <$mt:var name=\"saved_cards\"$> || [];
    } catch (e) {
        console.error('Error loading cards data:', e);
        allCards = [];
        deckCards = [];
    }
    
    function renderAvailableCards() {
        const container = document.getElementById('available-cards-list');
        if (allCards.length === 0) {
            container.innerHTML = '<p>No cards available. Please add cards first.</p>';
            return;
        }
        
        container.innerHTML = allCards.map(card => 
            '<div class=\"card-item\" onclick=\"addToDeck(' + card.id + ')\">' +
            '<strong>' + (card.name || 'Unknown') + '</strong><br>' +
            'Cost: ' + (card.cost || 0) + ' | ' + (card.type || 'Unknown') + 
            '</div>'
        ).join('');
    }
    
    function renderDeckCards() {
        const container = document.getElementById('deck-cards-list');
        if (deckCards.length === 0) {
            container.innerHTML = '<p>Add cards to your deck</p>';
            updateDeckTotal();
            return;
        }
        
        container.innerHTML = deckCards.map(deckCard => {
            const card = allCards.find(c => c.id == deckCard.card_id);
            if (!card) return '';
            
            return '<div class=\"card-item\">' +
                '<strong>' + (card.name || 'Unknown') + '</strong> x' + deckCard.count +
                '<button onclick=\"removeFromDeck(' + card.id + ')\" style=\"float: right;\">Remove</button>' +
                '</div>';
        }).join('');
        
        updateDeckTotal();
    }
    
    function addToDeck(cardId) {
        const existingCard = deckCards.find(c => c.card_id == cardId);
        if (existingCard) {
            if (existingCard.count < 3) {
                existingCard.count++;
            } else {
                alert('Maximum 3 copies of each card allowed');
                return;
            }
        } else {
            deckCards.push({ card_id: cardId, count: 1 });
        }
        
        renderDeckCards();
        updateCardsData();
    }
    
    function removeFromDeck(cardId) {
        const existingCard = deckCards.find(c => c.card_id == cardId);
        if (existingCard) {
            existingCard.count--;
            if (existingCard.count <= 0) {
                deckCards = deckCards.filter(c => c.card_id != cardId);
            }
        }
        
        renderDeckCards();
        updateCardsData();
    }
    
    function updateDeckTotal() {
        const total = deckCards.reduce((sum, card) => sum + card.count, 0);
        document.getElementById('deck-total').textContent = total;
    }
    
    function updateCardsData() {
        document.getElementById('cards_data').value = JSON.stringify(deckCards);
    }
    
    // Initialize
    document.addEventListener('DOMContentLoaded', function() {
        renderAvailableCards();
        renderDeckCards();
        updateCardsData();
    });
    </script>
</body>
</html>
EOF

# Fix deck list template
cat > /var/www/html/mt/plugins/ShadowverseDeckBuilder/tmpl/deck_list.tmpl << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Deck List - Shadowverse Deck Builder</title>
    <meta charset=\"utf-8\">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 20px; }
        .actions { margin-bottom: 20px; }
        .actions a { margin-right: 10px; padding: 8px 15px; background: #007cba; color: white; text-decoration: none; border-radius: 3px; }
        .decks-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; }
        .deck-item { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
        .deck-title { font-weight: bold; color: #333; margin-bottom: 5px; }
        .deck-class { color: #007cba; font-weight: bold; }
        .deck-description { color: #666; margin: 10px 0; }
        .deck-actions { margin-top: 10px; }
        .deck-actions a { margin-right: 10px; padding: 5px 10px; background: #666; color: white; text-decoration: none; border-radius: 3px; font-size: 12px; }
        .no-decks { text-align: center; color: #666; padding: 40px; }
    </style>
</head>
<body>
    <div class=\"header\">
        <h1>Shadowverse Deck Builder</h1>
    </div>
    
    <div class=\"actions\">
        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_edit\">Create New Deck</a>
        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_card_list\">Manage Cards</a>
    </div>
    
    <h2>My Decks (<$mt:var name=\"deck_count\" default=\"0\"$>)</h2>
    
    <mt:if name=\"decks\">
        <div class=\"decks-grid\">
            <mt:loop name=\"decks\">
                <div class=\"deck-item\">
                    <div class=\"deck-title\"><$mt:var name=\"title\"$></div>
                    <div class=\"deck-class\"><$mt:var name=\"class_jp\"$></div>
                    <mt:if name=\"description\">
                        <div class=\"deck-description\"><$mt:var name=\"description\"$></div>
                    </mt:if>
                    <div class=\"deck-actions\">
                        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_edit&id=<$mt:var name=\"id\"$>\">Edit</a>
                        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_delete&id=<$mt:var name=\"id\"$>\" onclick=\"return confirm('Are you sure?')\">Delete</a>
                        <mt:if name=\"is_public\">
                            <span style=\"color: #28a745; font-size: 12px;\">Public</span>
                        </mt:if>
                    </div>
                </div>
            </mt:loop>
        </div>
    <mt:else>
        <div class=\"no-decks\">
            <p>No decks found.</p>
            <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_deck_edit\">Create your first deck</a>
        </div>
    </mt:if>
</body>
</html>
EOF

# Create card edit template
cat > /var/www/html/mt/plugins/ShadowverseDeckBuilder/tmpl/card_edit.tmpl << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title><mt:if name=\"editing\">Edit Card<mt:else>Add New Card</mt:if> - Shadowverse Deck Builder</title>
    <meta charset=\"utf-8\">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 20px; }
        .card-form { max-width: 600px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .actions { margin-top: 20px; }
        .actions button { padding: 10px 20px; margin-right: 10px; background: #007cba; color: white; border: none; border-radius: 3px; cursor: pointer; }
        .actions button:hover { background: #005a87; }
        .actions a { padding: 10px 20px; background: #666; color: white; text-decoration: none; border-radius: 3px; }
    </style>
</head>
<body>
    <div class=\"header\">
        <h1><mt:if name=\"editing\">Edit Card<mt:else>Add New Card</mt:if></h1>
        <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_card_list\">← Back to Card List</a>
    </div>
    
    <form method=\"post\" action=\"<$mt:var name=\"script_url\"$>\" class=\"card-form\">
        <input type=\"hidden\" name=\"__mode\" value=\"sv_card_save\">
        <input type=\"hidden\" name=\"magic_token\" value=\"<$mt:var name=\"magic_token\"$>\">
        <mt:if name=\"editing\">
            <input type=\"hidden\" name=\"id\" value=\"<$mt:var name=\"card.id\"$>\">
        </mt:if>
        
        <div class=\"form-group\">
            <label>Card ID:</label>
            <input type=\"text\" name=\"card_id\" value=\"<$mt:var name=\"card.card_id\" escape=\"html\"$>\" required>
        </div>
        
        <div class=\"form-group\">
            <label>Card Name (Japanese):</label>
            <input type=\"text\" name=\"name\" value=\"<$mt:var name=\"card.name\" escape=\"html\"$>\" required>
        </div>
        
        <div class=\"form-group\">
            <label>Card Name (English):</label>
            <input type=\"text\" name=\"name_en\" value=\"<$mt:var name=\"card.name_en\" escape=\"html\"$>\">
        </div>
        
        <div class=\"form-row\">
            <div class=\"form-group\">
                <label>Cost:</label>
                <input type=\"number\" name=\"cost\" value=\"<$mt:var name=\"card.cost\" default=\"0\"$>\" min=\"0\" max=\"20\" required>
            </div>
            <div class=\"form-group\">
                <label>Type:</label>
                <select name=\"type\" required>
                    <option value=\"\">Select Type</option>
                    <option value=\"follower\"<mt:if name=\"card.type\" eq=\"follower\"> selected</mt:if>>フォロワー</option>
                    <option value=\"spell\"<mt:if name=\"card.type\" eq=\"spell\"> selected</mt:if>>スペル</option>
                    <option value=\"amulet\"<mt:if name=\"card.type\" eq=\"amulet\"> selected</mt:if>>アミュレット</option>
                </select>
            </div>
        </div>
        
        <div class=\"form-row\">
            <div class=\"form-group\">
                <label>Attack:</label>
                <input type=\"number\" name=\"attack\" value=\"<$mt:var name=\"card.attack\"$>\" min=\"0\" max=\"20\">
            </div>
            <div class=\"form-group\">
                <label>Life:</label>
                <input type=\"number\" name=\"life\" value=\"<$mt:var name=\"card.life\"$>\" min=\"0\" max=\"20\">
            </div>
        </div>
        
        <div class=\"form-row\">
            <div class=\"form-group\">
                <label>Class:</label>
                <select name=\"class\" required>
                    <option value=\"\">Select Class</option>
                    <option value=\"neutral\"<mt:if name=\"card.class\" eq=\"neutral\"> selected</mt:if>>ニュートラル</option>
                    <option value=\"elf\"<mt:if name=\"card.class\" eq=\"elf\"> selected</mt:if>>エルフ</option>
                    <option value=\"royal\"<mt:if name=\"card.class\" eq=\"royal\"> selected</mt:if>>ロイヤル</option>
                    <option value=\"witch\"<mt:if name=\"card.class\" eq=\"witch\"> selected</mt:if>>ウィッチ</option>
                    <option value=\"dragon\"<mt:if name=\"card.class\" eq=\"dragon\"> selected</mt:if>>ドラゴン</option>
                    <option value=\"necromancer\"<mt:if name=\"card.class\" eq=\"necromancer\"> selected</mt:if>>ネクロマンサー</option>
                    <option value=\"vampire\"<mt:if name=\"card.class\" eq=\"vampire\"> selected</mt:if>>ヴァンパイア</option>
                    <option value=\"bishop\"<mt:if name=\"card.class\" eq=\"bishop\"> selected</mt:if>>ビショップ</option>
                    <option value=\"nemesis\"<mt:if name=\"card.class\" eq=\"nemesis\"> selected</mt:if>>ネメシス</option>
                </select>
            </div>
            <div class=\"form-group\">
                <label>Rarity:</label>
                <select name=\"rarity\" required>
                    <option value=\"\">Select Rarity</option>
                    <option value=\"bronze\"<mt:if name=\"card.rarity\" eq=\"bronze\"> selected</mt:if>>ブロンズ</option>
                    <option value=\"silver\"<mt:if name=\"card.rarity\" eq=\"silver\"> selected</mt:if>>シルバー</option>
                    <option value=\"gold\"<mt:if name=\"card.rarity\" eq=\"gold\"> selected</mt:if>>ゴールド</option>
                    <option value=\"legendary\"<mt:if name=\"card.rarity\" eq=\"legendary\"> selected</mt:if>>レジェンド</option>
                </select>
            </div>
        </div>
        
        <div class=\"form-group\">
            <label>Set Name:</label>
            <input type=\"text\" name=\"set_name\" value=\"<$mt:var name=\"card.set_name\" escape=\"html\"$>\">
        </div>
        
        <div class=\"form-group\">
            <label>Description:</label>
            <textarea name=\"description\" rows=\"3\"><$mt:var name=\"card.description\" escape=\"html\"$></textarea>
        </div>
        
        <div class=\"form-group\">
            <label>Image URL:</label>
            <input type=\"url\" name=\"image_url\" value=\"<$mt:var name=\"card.image_url\" escape=\"html\"$>\">
        </div>
        
        <div class=\"actions\">
            <button type=\"submit\">Save Card</button>
            <a href=\"<$mt:var name=\"script_url\"$>?__mode=sv_card_list\">Cancel</a>
        </div>
    </form>
</body>
</html>
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html/mt/plugins/ShadowverseDeckBuilder/
chmod -R 644 /var/www/html/mt/plugins/ShadowverseDeckBuilder/tmpl/*.tmpl
"

# Step 10: Restart services to apply changes
echo "Step 10: Restarting services to apply changes..."
docker-compose restart

# Step 11: Final verification
echo "Step 11: Performing final verification..."
sleep 5
if curl -s http://localhost:8080 | grep -q "MovableType\|Movable Type\|mt.cgi"; then
    echo "✅ MovableType is accessible!"
else
    echo "⚠️  Warning: MovableType may not be fully accessible yet. Check manually."
fi

echo ""
echo "==========================================="
echo "Setup Complete!"
echo "==========================================="
echo ""
echo "Access your MovableType installation at:"
echo "  🌐 Main site: http://localhost:8080"
echo "  ⚙️  Admin: http://localhost:8080/mt/mt.cgi"
echo ""
echo "Default login credentials:"
echo "  Username: admin"
echo "  Password: password"
echo ""
echo "ShadowverseDeckBuilder plugin should now be available in:"
echo "  Tools → Shadowverse Deck Builder"
echo ""
echo "If you encounter issues:"
echo "  1. Check docker logs: docker-compose logs"
echo "  2. Restart services: docker-compose restart"
echo "  3. Check database: docker-compose exec db mysql -u movabletype -ppassword movabletype"
echo ""
echo "==========================================="