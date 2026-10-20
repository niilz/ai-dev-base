#!/usr/bin/env bash
# ==============================================================================
# Setup Cisco Root Certificate and Node.js CA Configuration
# ==============================================================================
# This script runs during the container build process. When executed in a corporate
# environment (e.g. work machine), an optional Cisco root certificate may be passed
# in the build context. When present, this script installs it into the OS trust store
# and configures shell profiles (Fish and POSIX) so Node.js trusts it via NODE_EXTRA_CA_CERTS.
#
# In personal/private environments where no certificate is provided, this script exits
# cleanly without modifying the container's certificate configuration or environment.
# ==============================================================================

set -euo pipefail

CONTEXT_DIR="${1:-/tmp/build-context}"
CERT_NAME="cisco-root.crt"
CERT_SOURCE="${CONTEXT_DIR}/${CERT_NAME}"
SYSTEM_CERT_DIR="/usr/local/share/ca-certificates"
INSTALLED_CERT="${SYSTEM_CERT_DIR}/${CERT_NAME}"

# If no corporate certificate was provided in the build context, exit early.
if [[ ! -f "${CERT_SOURCE}" ]]; then
    echo "No corporate certificate (${CERT_NAME}) found in build context. Skipping CA setup."
    exit 0
fi

echo "Found ${CERT_NAME}. Installing corporate certificate into trust store..."

# 1. Install certificate into the Linux CA trust store
mkdir -p "${SYSTEM_CERT_DIR}"
cp "${CERT_SOURCE}" "${INSTALLED_CERT}"
update-ca-certificates

# 2. Configure Fish shell drop-in to expose NODE_EXTRA_CA_CERTS automatically
# Fish reads all files in /etc/fish/conf.d/ upon startup.
mkdir -p /etc/fish/conf.d
cat << 'EOF' > /etc/fish/conf.d/cisco_ca.fish
# Automatically configure Node.js to trust the corporate root certificate
if test -f /usr/local/share/ca-certificates/cisco-root.crt
    set -gx NODE_EXTRA_CA_CERTS /usr/local/share/ca-certificates/cisco-root.crt
end
EOF

# 3. Configure POSIX shells (bash, zsh, sh) drop-in
mkdir -p /etc/profile.d
cat << 'EOF' > /etc/profile.d/cisco_ca.sh
# Automatically configure Node.js to trust the corporate root certificate
if [ -f /usr/local/share/ca-certificates/cisco-root.crt ]; then
    export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/cisco-root.crt
fi
EOF

echo "Corporate certificate and shell CA configuration successfully installed."
