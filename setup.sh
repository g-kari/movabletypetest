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

# Make scripts executable
chmod +x scripts/*.sh

# Run individual setup scripts
echo "Running Apache configuration fix..."
./scripts/fix-apache-config.sh

echo "Running MovableType configuration fix..."
./scripts/fix-mt-config.sh

echo "Running database initialization..."
./scripts/init-database.sh

echo "Creating admin user..."
./scripts/create-admin-user.sh

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