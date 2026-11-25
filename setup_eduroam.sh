#!/usr/bin/env bash
set -euo pipefail

CON_NAME="eduroam"
SSID="eduroam"

echo "=== eduroam Wi-Fi Setup ==="

# 1. Automatically detect Wi-Fi interface (fallback: wlan0)
IFNAME=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi" {print $1; exit}')
IFNAME=${IFNAME:-wlan0}
echo "Using Wi-Fi interface: $IFNAME"

# 2. Prompt for email / user identity
read -r -p "Email address (e.g. user@hs-koblenz.de): " EMAIL
if [[ -z "$EMAIL" || "$EMAIL" != *"@"* ]]; then
    echo "Error: Please enter a valid email address containing '@'." >&2
    exit 1
fi

# Extract domain from email for anonymous-identity
DOMAIN="${EMAIL#*@}"
ANON_ID="anonymous@${DOMAIN}"

# 3. Prompt for password silently (-r disables backslash escaping, -s hides input)
read -r -s -p "Password: " PASSWORD
echo ""
if [[ -z "$PASSWORD" ]]; then
    echo "Error: Password cannot be empty." >&2
    exit 1
fi

# 4. Remove existing eduroam connection profile if present
if nmcli -t -f NAME connection show | grep -Fxq "$CON_NAME"; then
    echo "Removing existing '$CON_NAME' profile..."
    sudo nmcli connection delete "$CON_NAME" >/dev/null
fi

# 5. Create new connection profile
echo "Creating eduroam profile for $EMAIL (anonymous identity: $ANON_ID)..."
sudo nmcli connection add \
  type wifi \
  con-name "$CON_NAME" \
  ifname "$IFNAME" \
  ssid "$SSID" \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap peap \
  802-1x.phase2-auth mschapv2 \
  802-1x.identity "$EMAIL" \
  802-1x.anonymous-identity "$ANON_ID" \
  802-1x.system-ca-certs false \
  802-1x.password "$PASSWORD" >/dev/null

# 6. Activate connection
echo "Connecting to $CON_NAME..."
sudo nmcli connection up "$CON_NAME"

echo "Successfully connected to eduroam!"
