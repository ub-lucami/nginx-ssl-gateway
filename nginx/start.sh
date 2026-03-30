#!/usr/bin/env bash
set -e

echo "Rendering Nginx templates..."

for tpl in /etc/nginx/templates/conf.d/*.template; do
    out="/etc/nginx/conf.d/$(basename "$tpl" .template)"
    echo "Generating $out from $tpl"
    envsubst < "$tpl" > "$out"
done

echo "Templates rendered. Starting Nginx..."

# Try to start Nginx, but don't let the script exit immediately on failure
if nginx -t; then
    echo "Config test passed. Starting Nginx..."
    exec nginx -g "daemon off;"
else
    echo "ERROR: nginx -t failed! Check the config above."
    echo "Container will stay alive for debugging (sleeping 3600 seconds = 1 hour)"
    echo "You can now exec into the container and fix /etc/nginx/conf.d/10-main.conf"
    sleep 3600
    echo "Sleep finished. Exiting..."
    exit 1
fi
