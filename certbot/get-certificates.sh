#!/usr/bin/env sh
set -e

IFS=","
for domain in $DOMAINS; do
  folder=$domain
  if [[ ${folder:0:2} = "*." ]]; then
    folder=${folder:2}
  fi

  dst="/etc/letsencrypt/live/$folder"

  if [ -d $dst ]; then
    continue;
  elif [[ ${domain:0:2} = "*." ]]; then
    certbot certonly \
      --dns-dnsimple \
      --dns-dnsimple-credentials /run/secrets/DNSIMPLE_CREDENTIALS \
      --email anders@tight.no \
      --agree-tos \
      --no-eff-email \
      -d ${domain:2} \
      -d $domain
  else
    certbot certonly \
        --webroot \
        --webroot-path /usr/share/certbot/webroot \
        --email anders@tight.no \
        --agree-tos \
        --no-eff-email \
        -d $domain
  fi
done
