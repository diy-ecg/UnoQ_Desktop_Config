# Arduino Uno Q Configuration (Debian Trixie)

This repository contains configuration files and helper scripts for setting up an **Arduino Uno Q** running Linux (Debian Trixie):

1. **[`setup_eduroam.sh`](./setup_eduroam.sh)**: Interactive Bash script to easily configure and connect to the **eduroam** Wi-Fi network via NetworkManager (`nmcli`).
2. **[`90-monitor-rotate.conf`](./90-monitor-rotate.conf)**: X11 configuration file to rotate both the DSI display output (`DSI-1`) and the capacitive touchscreen input (`Goodix Capacitive TouchScreen`) to landscape orientation (`left`).

---

## Prerequisites

* Arduino Uno Q running Debian Linux (Trixie) with `NetworkManager` (`nmcli`) and X11 (`Xorg`)
* `sudo` privileges on the system

### Transferring Files to the Arduino Uno Q

If the Arduino Uno Q does not have an active internet connection yet, download or clone this repository to your computer and copy the files to the board via `scp` (e.g., over USB network/SSH):

```bash
scp setup_eduroam.sh 90-monitor-rotate.conf <user>@<uno-q-ip>:~/
```

*(Alternatively, if the board is already connected to the internet via LAN or USB tethering, you can clone this repository directly on the board using `git clone`.)*

---

## 1. eduroam Wi-Fi Setup (`setup_eduroam.sh`)

### Features

* **Interactive prompts:** Only asks for your university email address and password.
* **Secure password input:** Hidden password entry (`read -s`) that safely handles special characters (such as `!`, `$`, `'`, `"`).
* **Automatic domain extraction:** Derives the `anonymous-identity` (e.g., `anonymous@hs-koblenz.de`) automatically from your email address.
* **Automatic Wi-Fi interface detection:** Detects the active Wi-Fi interface via `nmcli` (falls back to `wlan0`).
* **Clean profile creation:** Automatically removes any pre-existing `eduroam` profile before creating a new one to prevent duplicates.

### Usage

#### Step 1: Make the script executable (`chmod`)

Set the executable permission bit (`+x`) so Linux allows running the script directly:

```bash
chmod +x setup_eduroam.sh
```

#### Step 2: Run the script

```bash
./setup_eduroam.sh
```

> **Note:** Alternatively, you can invoke the script directly with `bash setup_eduroam.sh` without running `chmod +x` first, though setting `chmod +x` is the recommended standard.

Follow the prompts in the terminal:
1. Enter your **email address** (e.g., `user@hs-koblenz.de`).
2. Enter your **password** (input is hidden for security).
3. If prompted, enter the Linux user's `sudo` password.

### Optional: Make Available System-Wide for All Users

To install the script permanently as a global `setup-eduroam` command for all users on the Arduino Uno Q (e.g., when preparing a lab SD card image):

```bash
sudo cp setup_eduroam.sh /usr/local/bin/setup-eduroam
sudo chmod 755 /usr/local/bin/setup-eduroam
```

Afterwards, any user can configure eduroam from anywhere by simply running:

```bash
setup-eduroam
```

---

## 2. Screen & Touchscreen Rotation (`90-monitor-rotate.conf`)

The file [`90-monitor-rotate.conf`](./90-monitor-rotate.conf) rotates the display (`DSI-1`) to the `left` and applies the matching coordinate transformation matrix (`0 -1 1 1 0 0 0 0 1`) to the `Goodix Capacitive TouchScreen` so touch inputs align accurately with the rotated screen.

### Installation

1. Ensure the target X11 configuration directory `/etc/X11/xorg.conf.d/` exists and copy the configuration file into it:

   ```bash
   sudo mkdir -p /etc/X11/xorg.conf.d/
   sudo cp 90-monitor-rotate.conf /etc/X11/xorg.conf.d/90-monitor-rotate.conf
   sudo chmod 644 /etc/X11/xorg.conf.d/90-monitor-rotate.conf
   ```

2. Restart the X server (display manager) or reboot the Arduino Uno Q for the changes to take effect:

   ```bash
   sudo reboot
   ```

---

## Troubleshooting

### Error: `$'\r': command not found` or `bad interpreter`
If `setup_eduroam.sh` was downloaded or edited on Windows, it may contain Windows line endings (`CRLF` instead of `LF`). Convert the file on the Arduino Uno Q using:

```bash
sed -i 's/\r$//' setup_eduroam.sh
```

### Verify Wi-Fi Connection Status
You can check whether the `eduroam` Wi-Fi connection is active at any time with:

```bash
nmcli device status
```
