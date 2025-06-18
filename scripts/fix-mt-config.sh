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

# Security settings
CookieSecret MTSecretCookieKey2024
SecretToken MTSecretToken2024

# Session management - Disable for troubleshooting
#SessionDriver DB::DBI
#SessionOptions timeout=3600

# Security headers - Disable for troubleshooting
RequiredHeaders 0
CSRFProtection 0
XMLRPCAllowedXssDomains *

# Email settings
MailTransfer sendmail
SendMailPath /usr/sbin/sendmail

# Performance settings
ProcessMemoryCommand /bin/ps -o rss=

# Debug settings
DebugMode 2

# Additional security
DisableNotificationPings 1
AllowComments 0
AllowPings 0
EOF

# Set proper permissions
chmod 644 mt-config.cgi
chown -R www-data:www-data /var/www/cgi-bin/mt
chmod 755 /var/www/cgi-bin/mt/mt.cgi
chmod 755 /var/www/cgi-bin/mt/mt-*.cgi
find /var/www/cgi-bin/mt/tools -name '*.pl' -exec chmod 755 {} \; 2>/dev/null || true
"

echo "MovableType configuration fixed!"