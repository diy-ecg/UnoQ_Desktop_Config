# eduroam Setup für Arduino Uno Q (Debian Trixie)

Dieses Repository enthält ein Bash-Skript ([`setup_eduroam.sh`](./setup_eduroam.sh)), mit dem die **eduroam**-WLAN-Verbindung auf dem **Arduino Uno Q** unter Linux (Debian Trixie mit NetworkManager / `nmcli`) schnell und interaktiv eingerichtet werden kann.

## Funktionen

* **Interaktive Abfrage:** Fragt nur nach der Hochschul-E-Mail-Adresse und dem Passwort.
* **Sichere Passworteingabe:** Das Passwort wird verdeckt eingegeben und unterstützt problemlos Sonderzeichen (wie `!`, `$`, `'`, `"`).
* **Automatische Domain-Erkennung:** Erzeugt die `anonymous-identity` (z. B. `anonymous@hs-koblenz.de`) automatisch aus der eingegebenen E-Mail-Adresse.
* **Automatische WLAN-Interface-Erkennung:** Ermittelt das WLAN-Interface automatisch über `nmcli` (Fallback auf `wlan0`).
* **Saubere Neueinrichtung:** Entfernt ein eventuell bereits vorhandenes `eduroam`-Profil vor dem Anlegen, um Duplikate zu vermeiden.

---

## Voraussetzungen

* Arduino Uno Q mit Debian Linux (oder ein anderes Linux-System mit aktivem `NetworkManager` / `nmcli`)
* `sudo`-Rechte auf dem System

---

## Installation & Ausführung

### 1. Skript auf den Arduino Uno Q übertragen

Falls auf dem Arduino Uno Q noch keine Internetverbindung besteht, lade [`setup_eduroam.sh`](./setup_eduroam.sh) auf deinen PC herunter und kopiere es z. B. per `scp` (über USB-Netzwerk/SSH) auf das Board:

```bash
scp setup_eduroam.sh <benutzer>@<ip-des-uno-q>:~/
```

*(Alternativ, falls das Board bereits über LAN oder USB-Tethering mit dem Internet verbunden ist, kann das Repository direkt mit `git clone` geladen werden.)*

### 2. Ausführungsrechte setzen (`chmod`)

Damit Linux die Datei als Programm ausführen darf, muss das Ausführbarkeits-Bit (`+x`) gesetzt werden:

```bash
chmod +x setup_eduroam.sh
```

### 3. Skript starten

```bash
./setup_eduroam.sh
```

> **Alternative ohne `chmod`:** Du kannst das Skript auch direkt an `bash` übergeben (`bash setup_eduroam.sh`), dann ist `chmod +x` technisch nicht zwingend nötig – das Setzen von `chmod +x` ist aber der empfohlene Standard.

Folge anschließend den Anweisungen im Terminal:
1. **E-Mail-Adresse** eingeben (z. B. `muster@hs-koblenz.de`)
2. **Passwort** eingeben (die Eingabe wird aus Sicherheitsgründen **nicht** angezeigt)
3. Falls gefragt, das `sudo`-Passwort des Linux-Benutzers eingeben.

---

## Optional: Systemweit für alle Benutzer verfügbar machen

Wenn das Skript dauerhaft als Befehl `setup-eduroam` für alle Benutzer auf dem Arduino Uno Q (z. B. für ein vorkonfiguriertes Labor-Image) hinterlegt werden soll:

```bash
sudo cp setup_eduroam.sh /usr/local/bin/setup-eduroam
sudo chmod 755 /usr/local/bin/setup-eduroam
```

Danach kann die Einrichtung jederzeit und aus jedem Verzeichnis heraus einfach mit folgendem Befehl gestartet werden:

```bash
setup-eduroam
```

---

## Fehlerbehebung

### Fehler: `$'\r': command not found` oder `bad interpreter`
Falls das Skript unter Windows heruntergeladen oder bearbeitet wurde, enthält es möglicherweise Windows-Zeilenumbrüche (`CRLF` statt `LF`). Bereinige die Datei auf dem Arduino Uno Q mit:

```bash
sed -i 's/\r$//' setup_eduroam.sh
```

### Verbindung prüfen
Mit folgendem Befehl kannst du jederzeit prüfen, ob die WLAN-Verbindung aktiv ist:

```bash
nmcli device status
```
