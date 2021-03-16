#!/usr/bin/env sh
set -e

mkdir -p /usr/share/certbot/webroot

# Get certificates
/app/get-certificates.sh

# Renew certificates
/app/renew-certificates.sh

# Schedule renew
cat << SCHEDULED > /etc/periodic/daily/renew-certificates
#!/usr/bin/env sh

DOMAINS="$DOMAINS" \
  /app/renew-certificates.sh

SCHEDULED
chmod +x /etc/periodic/daily/renew-certificates

exec "$@"
