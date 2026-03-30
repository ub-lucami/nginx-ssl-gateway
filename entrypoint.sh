#!/usr/bin/env bash
set -euo pipefail

# Render the default server from the template using envsubst
TEMPLATE=/etc/nginx/templates/conf.d/default.conf.template
OUTPUT=/etc/nginx/conf.d/default.conf

if [ -f "$TEMPLATE" ]; then
  echo "Rendering Nginx server config from template ..."
  envsubst '
    $DEFAULT_CERT
    $KONG_UPSTREAM
    $CORS_ALLOW_ORIGIN
    $CORS_ALLOW_METHODS
    $CORS_ALLOW_HEADERS
    $CORS_ALLOW_CREDENTIALS
    $CORS_MAX_AGE
  ' < "$TEMPLATE" > "$OUTPUT"
  echo "Rendered to $OUTPUT"
else
  echo "Template $TEMPLATE not found!" >&2
  exit 1
fi
