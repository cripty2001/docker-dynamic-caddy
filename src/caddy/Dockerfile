FROM caddy:2-alpine

# Install bash for scripts
RUN apk add --no-cache bash

# Create Caddyfile directory
RUN mkdir -p /etc/caddy

RUN mkdir -p /app
COPY site-config.tpl build-config.sh main.sh /app/

RUN chmod +x /app/build-config.sh /app/main.sh

# Exposing ports
EXPOSE 80 443

# Starting container (since domains are passed as env variables, 2 stage build is not an option...)
CMD ["bash", "/app/main.sh"]
