FROM 'alpine:3.13.1'

RUN set -eux; \
    apk add --no-cache \
      certbot \
      openssl \
    ;

COPY get-certificates.sh renew-certificates.sh /app/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["crond", "-f"]
