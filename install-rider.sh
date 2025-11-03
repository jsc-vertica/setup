#!/bin/bash
# JetBrains Rider manual installation script for Ubuntu
# Author: ChatGPT (GPT-5)
# Usage: sudo bash install-rider.sh

set -e

# --- CONFIGURATION ---
RIDER_URL="https://download.jetbrains.com/rider/JetBrains.Rider-2025.2.3.tar.gz"
INSTALL_DIR="/opt/rider"
DESKTOP_FILE="/usr/share/applications/jetbrains-rider.desktop"

echo "🚀 Installing JetBrains Rider..."

# --- 1. Install dependencies ---
echo "📦 Installing required tools..."
sudo apt update -qq
sudo apt install -y curl tar

# --- 2. Download Rider ---
echo "⬇️ Downloading Rider from JetBrains..."
curl -L "$RIDER_URL" -o /tmp/Rider.tar.gz

# --- 3. Extract and move to /opt ---
echo "📂 Extracting package..."
tar -xzf /tmp/Rider.tar.gz -C /tmp

# Find extracted directory name (usually Rider-2025.x.x)
RIDER_DIR=$(find /tmp -maxdepth 1 -type d -iname "JetBrains Rider*" | head -n 1)

echo "📁 Moving Rider to $INSTALL_DIR ..."
sudo rm -rf "$INSTALL_DIR"
sudo mv "$RIDER_DIR" "$INSTALL_DIR"

# --- 4. Create desktop shortcut ---
echo "🖥️ Creating desktop shortcut..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Name=JetBrains Rider
Comment=Cross-platform .NET IDE
Exec=$INSTALL_DIR/bin/rider.sh
Icon=$INSTALL_DIR/bin/rider.svg
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=jetbrains-rider
EOF

# Make it discoverable
sudo chmod 644 "$DESKTOP_FILE"
sudo update-desktop-database > /dev/null 2>&1 || true

# --- 5. Add Rider to PATH ---
echo "🛠️ Adding Rider command to PATH..."
sudo ln -sf "$INSTALL_DIR/bin/rider.sh" /usr/local/bin/rider

# --- 6. Cleanup ---
rm -f /tmp/Rider.tar.gz

echo "✅ Installation complete!"
echo "👉 Launch with 'rider' or from your application menu."
