#!/bin/sh
set -eu

mkdir -p /etc/nginx/conf.d

SUBST_VARS='${KONG_UPSTREAM} ${CERT_FILE} ${KEY_FILE} ${DEFAULT_CERT} ${TENANT1_SERVER_NAME} ${TENANT1_UPSTREAM} ${TENANT1_CERT}'
for f in /etc/nginx/templates/conf.d/*.template; do
  out="/etc/nginx/conf.d/$(basename "$f" .template)"
  envsubst "$SUBST_VARS" < "$f" > "$out"
done

nginx -t
nginx

last_state=""

while true; do
  cert_mtime="$(stat -c %Y "$CERT_FILE" 2>/dev/null || echo missing)"
  key_mtime="$(stat -c %Y "$KEY_FILE" 2>/dev/null || echo missing)"
  new_state="${cert_mtime}:${key_mtime}"

  if [ -z "$last_state" ]; then
    last_state="$new_state"
  elif [ "$new_state" != "$last_state" ]; then
    echo "Certificate change detected, validating nginx config..."
    if nginx -t; then
      echo "Reloading nginx..."
      nginx -s reload
      last_state="$new_state"
    else
      echo "nginx config test failed, keeping current config"
    fi
  fi

  sleep "$CERT_CHECK_INTERVAL"
done