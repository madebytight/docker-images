#!/usr/bin/env sh
set -e

# Certifcate will be renewed if it expires within X days.
days=30
expiration=$((($days * 24) * 3600))

IFS=","
for domain in $DOMAINS; do
  folder=$domain
  if [[ ${folder:0:2} = "*." ]]; then
    folder=${folder:2}
  fi

  dst="/etc/letsencrypt/live/$folder"
  cert="$dst/fullchain.pem"

  echo "=== Renew certificate for $domain ==="
  echo "    \$dst: $dst"
  echo "    \$cert: $cert"
  echo ""

  if [ ! -d $dst ]; then
    echo "    \$dst does not exist"
    continue;
  elif openssl x509 -checkend $expiration -noout -in $cert > /dev/null; then
    echo "    \$expiration not passed"
    continue;
  elif [[ ${domain:0:2} = "*." ]]; then
    certbot certonly \
      --dns-dnsimple \
      --dns-dnsimple-credentials /run/secrets/DNSIMPLE_CREDENTIALS \
      --noninteractive \
      -d ${domain:2} \
      -d $domain
  else
    certbot certonly \
        --webroot \
        --webroot-path /usr/share/certbot/webroot \
        --noninteractive \
        -d $domain
  fi

  echo ""
done
