#!/bin/bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/site-config.tpl"

line=${1:-}
if [[ -z "$line" ]]; then
    echo "build-config.sh: expected one DOMAIN_MAPPINGS line as the sole argument." >&2
    exit 1
fi

TLS_FLAG_RAW=$(echo "$line" | awk '{print $1}')
PUBLIC_HOSTNAME=$(echo "$line" | awk '{print $2}')
INTERNAL_HOSTNAME=$(echo "$line" | awk '{print $3}')
HOST_HEADER=$(echo "$line" | awk '{print $4}')

lowered=$(printf '%s' "$TLS_FLAG_RAW" | tr '[:upper:]' '[:lower:]')
case "$lowered" in
    encrypted) TLS_MODE=encrypted ;;
    cleartext) TLS_MODE=cleartext ;;
    *)
        echo "Invalid first column '$TLS_FLAG_RAW' (expected encrypted or cleartext). Line: $line" >&2
        exit 1
        ;;
esac

if [[ -z "$PUBLIC_HOSTNAME" || -z "$INTERNAL_HOSTNAME" ]]; then
    echo "Missing public or internal hostname after encrypted|cleartext. Line: $line" >&2
    exit 1
fi

echo "Building config for $PUBLIC_HOSTNAME (internal: $INTERNAL_HOSTNAME, $TLS_MODE, forced host: ${HOST_HEADER:-<transparent>})" >&2

if [[ -n "$HOST_HEADER" ]]; then
    HOST_HEADER_VALUE="$HOST_HEADER"
else
    HOST_HEADER_VALUE="{host}"
fi

SCHEME="http://"
if [[ "$TLS_MODE" == "encrypted" ]]; then
	SCHEME="https://"
fi

sed -e "s/\${PUBLIC_HOSTNAME}/$PUBLIC_HOSTNAME/g" \
    -e "s/\${INTERNAL_HOSTNAME}/$INTERNAL_HOSTNAME/g" \
    -e "s/\${HOST_HEADER}/$HOST_HEADER_VALUE/g" \
    -e "s|\${SCHEME}|$SCHEME|g" \
    "$TEMPLATE_FILE"
echo ""
