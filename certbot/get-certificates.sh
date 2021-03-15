#!/usr/bin/env sh
set -e

IFS=","
for domain in $DOMAINS; do
  dst="/etc/letsencrypt/live/$domain"
  if [ -d $dst ]; then
    continue;
  fi

  echo "Get cetificate for $domain"
  certbot certonly \
    --webroot \
    --webroot-path /usr/share/certbot/webroot \
    --email anders@tight.no \
    --agree-tos \
    --no-eff-email \
    -d $domain
done
