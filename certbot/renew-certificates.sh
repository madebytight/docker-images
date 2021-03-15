#!/usr/bin/env sh
set -e

# Certifcate will be renewed if it expires within X days.
days=7
expiration=$((($days * 24) * 3600))

IFS=","
for domain in $DOMAINS; do
  cert="/etc/letsencrypt/live/$domain/fullchain.pem"
  if [ ! -d $dst ]; then
    continue;
  fi

  if openssl x509 -checkend $expiration -noout -in $cert > /dev/null; then
    continue;
  fi;

  echo "Renew cetificate for $domain"
  certbot certonly \
    --webroot \
    --webroot-path /usr/share/certbot/webroot \
    --noninteractive \
    -d $domain
done
