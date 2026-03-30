FROM nginx:1.25-alpine

# tini for proper signals (optional but helps with clean shutdowns)
RUN apk add --no-cache bash gettext tini

# Copy static global config and template
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /docker-entrypoint.d/20-render-template.sh

# Make sure the hook is executable
RUN chmod +x /docker-entrypoint.d/20-render-template.sh

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"
