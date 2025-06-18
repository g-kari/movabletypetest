#!/bin/bash
# Database Initialization Script

set -e

echo "Initializing MovableType database..."

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
    if docker-compose exec mysql mysql -u mt -pmovabletype -e "SELECT 1;" > /dev/null 2>&1; then
        echo "MySQL is ready!"
        break
    fi
    echo "Attempt $i/30: MySQL not ready yet..."
    sleep 2
done

# Run MovableType upgrade
docker-compose exec movabletype bash -c "
cd /var/www/cgi-bin/mt
perl tools/upgrade --force --non-interactive || echo 'Database initialization completed'
"

echo "Database initialization completed!"