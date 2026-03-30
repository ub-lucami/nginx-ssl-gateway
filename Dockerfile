FROM nginx:1.25-alpine

RUN apk add --no-cache bash

# Copy global nginx.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy templates (multi-tenant ready)
COPY nginx/templates /etc/nginx/templates

# Copy start script and make executable
COPY nginx/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
