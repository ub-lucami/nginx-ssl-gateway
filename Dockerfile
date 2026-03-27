FROM nginx:1.27-alpine

# Source metadata
LABEL org.opencontainers.image.source="https://github.com/ub-lucami/nginx-ssl-gateway"

# Copy files and set ownership to the nginx user to limit file permissions
COPY --chown=nginx:nginx nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx nginx/templates /etc/nginx/templates
COPY --chown=nginx:nginx nginx/start.sh /start.sh

# Ensure the start script is executable (single layer)
RUN chmod 755 /start.sh

# Run the container using the script directly (exec form). Keep using the
# base image's nginx user for file ownership; the nginx process still drops
# privileges according to its configuration.
CMD ["/start.sh"]
