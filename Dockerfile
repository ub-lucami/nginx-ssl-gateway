FROM nginx:1.27-alpine

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/templates /etc/nginx/templates
COPY nginx/start.sh /start.sh

RUN chmod +x /start.sh

CMD ["/bin/sh", "/start.sh"]