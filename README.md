# Docker Ingress with Caddy

A dynamic reverse proxy using Caddy

## Setup

1. Create the external network:
   ```bash
   docker network create ingress
   ```

2. Add your other containers to the `ingress` network.

3. Copy `.env.example` to `.env` and update it with your own values.

4. Start the service:
   ```bash
   docker compose up -d --build --force-recreate
   ```

# Mapping Format
Format per line: `encrypted|cleartext public-hostname internal-hostname [forced-host-header]`
   - First column:
     -  **`encrypted`**: HTTPS on Caddy with a certificate from Let’s Encrypt (ACME).
     -  **`cleartext`**: HTTP only (e.g. TLS may have already been terminated before Caddy).
   - `public-hostname`: The public domain name
   - `internal-hostname`: The internal service hostname (Docker service name or external hostname)
   - `forced-host-header` (optional): If provided, this value is used as the Host header sent to the upstream. If blank or omitted, the original public hostname is used (transparent proxy mode).

## Features
- **Per-site TLS**: First column is **`encrypted`** (automatic HTTPS) or **`cleartext`** (HTTP only)
- **Dynamic Configuration**: Builds the Caddyfile from the `DOMAIN_MAPPINGS` environment variable
- **WebSocket Support**: Full WebSocket proxy support
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy
- **Gzip Compression**: Automatic compression for supported content types
- **Error Handling**: Active health checks treat 502/503/504 as unhealthy; `handle_errors` returns a JSON body when those statuses occur in Caddy’s error path (upstream passthrough responses may not use this path)