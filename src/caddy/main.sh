#!/bin/bash
set -e
set -o pipefail

# Checking required environment variables
if [[ -z "${CERTBOT_EMAIL:-}" ]]; then
    echo "CERTBOT_EMAIL must be set (ACME contact address)." >&2
    exit 1
fi
if [[ -z "${DOMAIN_MAPPINGS:-}" ]]; then
    echo "DOMAIN_MAPPINGS must be set (newline-separated domain mapping lines)." >&2
    exit 1
fi

# Initing Caddyfile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADDYFILE_PATH="/etc/caddy/Caddyfile"

cat > "$CADDYFILE_PATH" <<EOF
{
	email ${CERTBOT_EMAIL}
}

EOF

# Appending domain configs (looping domain mappings)
while read -r line; do
    line=${line%$'\r'}
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    "$SCRIPT_DIR/build-config.sh" "$line" >> "$CADDYFILE_PATH"
done <<< "$DOMAIN_MAPPINGS"

# Starting Caddy
caddy run --config "$CADDYFILE_PATH" --adapter caddyfile
