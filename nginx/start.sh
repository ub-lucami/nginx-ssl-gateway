#!/usr/bin/env bash
set -e

echo "Rendering templates..."
for tpl in /etc/nginx/templates/conf.d/*.template; do
    out="/etc/nginx/conf.d/$(basename "$tpl" .template)"
    envsubst < "$tpl" > "$out"
    echo "Generated $out"
done

echo "Starting nginx..."
nginx -g "daemon off;"
