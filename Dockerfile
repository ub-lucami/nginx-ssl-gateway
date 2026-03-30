FROM nginx:1.25-alpine

RUN apk add --no-cache bash

# Your nginx.conf will be mounted over this
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Your templates will be mounted over this
COPY nginx/templates /etc/nginx/templates

# Your startup script will be mounted over this
COPY nginx/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
