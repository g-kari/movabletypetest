#!/bin/bash
# Apache Configuration Fix Script

set -e

echo "Fixing Apache configuration..."

docker-compose exec movabletype bash -c "
# Remove Apache default index.html that may interfere
rm -f /var/www/html/index.html

# Update .htaccess with correct CGI path
cat > /var/www/html/.htaccess << 'EOF'
# MovableType URL Routing
DirectoryIndex index.html

# Handle MovableType requests
RewriteEngine On
RewriteBase /

# Route admin requests to MovableType CMS
RewriteRule ^mt/?(.*)$ /cgi-bin/mt/mt.cgi?__mode=\$1 [QSA,L]

# Route root requests to MovableType
RewriteRule ^$ /cgi-bin/mt/mt.cgi [L]
EOF

# Ensure proper permissions
chown www-data:www-data /var/www/html/.htaccess
chmod 644 /var/www/html/.htaccess
"

echo "Apache configuration fixed!"