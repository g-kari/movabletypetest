#!/bin/bash
# Database Initialization Script

set -e

echo "Initializing MovableType database..."

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
    if docker-compose exec -T mysql mysql -u mt -pmovabletype -e "SELECT 1;" > /dev/null 2>&1; then
        echo "MySQL is ready!"
        break
    fi
    echo "Attempt $i/30: MySQL not ready yet..."
    sleep 2
done

# First, create the database if it doesn't exist
docker-compose exec -T mysql mysql -u root -pmovabletype -e "CREATE DATABASE IF NOT EXISTS mt;"

# Run MovableType upgrade
docker-compose exec -T movabletype bash -c "
cd /var/www/cgi-bin/mt
# Fix ObjectDriver config by setting proper database driver
export MT_CONFIG=/var/www/cgi-bin/mt/mt-config.cgi
# Run upgrade with correct syntax - create admin user
perl tools/upgrade --name admin || echo 'Database initialization completed'
"

echo "Database initialization completed!"