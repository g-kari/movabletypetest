#!/bin/bash
# Create Admin User Script

set -e

echo "Creating admin user..."

# Create admin user directly in database
docker-compose exec -T mysql mysql -u mt -pmovabletype mt << 'EOF'
-- Create admin user with known credentials
INSERT IGNORE INTO mt_author (
    author_name, 
    author_nickname, 
    author_email, 
    author_password, 
    author_is_superuser, 
    author_type, 
    author_status,
    author_created_on,
    author_modified_on
) VALUES (
    'admin', 
    'Administrator', 
    'admin@example.com', 
    '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', -- 'password' in SHA256
    1, 
    1, 
    1,
    NOW(),
    NOW()
);
EOF

echo "Admin user created with username: admin, password: password"