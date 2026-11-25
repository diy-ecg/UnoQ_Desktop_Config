#!/usr/bin/env bash
set -euo pipefail

CON_NAME="eduroam"
SSID="eduroam"

echo "=== eduroam Einrichtung ==="

# 1. WLAN-Interface automatisch ermitteln (Fallback: wlan0)
IFNAME=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi" {print $1; exit}')
IFNAME=${IFNAME:-wlan0}
echo "Verwende WLAN-Interface: $IFNAME"

# 2. E-Mail / Benutzerkennung abfragen
read -r -p "E-Mail-Adresse (z.B. name@hs-koblenz.de): " EMAIL
if [[ -z "$EMAIL" || "$EMAIL" != *"@"* ]]; then
    echo "Fehler: Bitte eine gültige E-Mail-Adresse mit '@' eingeben." >&2
    exit 1
fi

# Domain für anonymous-identity automatisch aus der E-Mail extrahieren
DOMAIN="${EMAIL#*@}"
ANON_ID="anonymous@${DOMAIN}"

# 3. Passwort verdeckt abfragen (-r verhindert Backslash-Interpretation, -s blendet Eingabe aus)
read -r -s -p "Passwort: " PASSWORD
echo ""
if [[ -z "$PASSWORD" ]]; then
    echo "Fehler: Das Passwort darf nicht leer sein." >&2
    exit 1
fi

# 4. Falls bereits eine eduroam-Verbindung existiert, vorher entfernen
if nmcli -t -f NAME connection show | grep -Fxq "$CON_NAME"; then
    echo "Altes Profil '$CON_NAME' wird entfernt..."
    sudo nmcli connection delete "$CON_NAME" >/dev/null
fi

# 5. Neue Verbindung anlegen
echo "Erstelle eduroam-Profil für $EMAIL (Anonym: $ANON_ID)..."
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

# 6. Verbindung aktivieren
echo "Verbinde mit $CON_NAME..."
sudo nmcli connection up "$CON_NAME"

echo "Erfolgreich mit eduroam verbunden!"
