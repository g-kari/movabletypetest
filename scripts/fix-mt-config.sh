#!/bin/bash
# MovableType Configuration Fix Script

set -e

echo "Fixing MovableType configuration..."

docker-compose exec movabletype bash -c "
cd /var/www/cgi-bin/mt

# Create mt-config.cgi with correct paths
cat > mt-config.cgi << 'EOF'
CGIPath /cgi-bin/mt/
StaticWebPath /mt-static/
StaticFilePath /var/www/html/mt-static/

# Database configuration
ObjectDriver DBI::mysql
Database mt
DBUser mt
DBPassword movabletype
DBHost mysql
DBPort 3306

DefaultLanguage ja
DefaultTimezone +09:00

AdminCGIPath /cgi-bin/mt/
AdminScript mt.cgi

PublishCharset utf-8
LogConfig /tmp/mt.log

PluginPath plugins
ThemesDirectory themes

# Email settings
MailTransfer sendmail
SendMailPath /usr/sbin/sendmail

# Performance settings
ProcessMemoryCommand /bin/ps -o rss=

# Debug settings
DebugMode 2
EOF

# Set proper permissions
chmod 644 mt-config.cgi
chown -R www-data:www-data /var/www/cgi-bin/mt
chmod 755 /var/www/cgi-bin/mt/mt.cgi
chmod 755 /var/www/cgi-bin/mt/mt-*.cgi
find /var/www/cgi-bin/mt/tools -name '*.pl' -exec chmod 755 {} \; 2>/dev/null || true
"

echo "MovableType configuration fixed!"