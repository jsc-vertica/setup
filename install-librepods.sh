#!/bin/bash

# LibrePods Installation Script for Ubuntu 24.04
# Based on: https://github.com/kavishdevar/librepods/blob/main/linux/README.md

set -e  # Exit on error

echo "========================================="
echo "LibrePods Installation Script"
echo "For Ubuntu 24.04"
echo "========================================="
echo ""

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "Warning: This script is designed for Ubuntu. Your system may not be supported."
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Qt6 packages
echo ""
echo "Installing Qt6 packages..."
sudo apt-get install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-connectivity-dev \
    qt6-multimedia-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qml6-module-qtquick-controls \
    qml6-module-qtqml-workerscript \
    qml6-module-qtquick-templates \
    qml6-module-qtquick-window \
    qml6-module-qtquick-layouts

# Install OpenSSL development headers
echo ""
echo "Installing OpenSSL development headers..."
sudo apt-get install -y libssl-dev

# Install libpulse development headers
echo ""
echo "Installing libpulse development headers..."
sudo apt-get install -y libpulse-dev

# Install CMake
echo ""
echo "Installing CMake..."
sudo apt-get install -y cmake

# Install build essentials
echo ""
echo "Installing build essentials..."
sudo apt-get install -y build-essential

# Clone the repository
echo ""
echo "Cloning LibrePods repository..."
INSTALL_DIR="$HOME/build-from-source/librepods"
if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists."
    read -p "Do you want to remove it and clone fresh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
        git clone https://github.com/kavishdevar/librepods.git "$INSTALL_DIR"
    else
        echo "Using existing directory..."
    fi
else
    git clone https://github.com/kavishdevar/librepods.git "$INSTALL_DIR"
fi

# Build the application
echo ""
echo "Building LibrePods..."
cd "$INSTALL_DIR/linux"
mkdir -p build
cd build
cmake ..
make -j $(nproc)

echo ""
echo "========================================="
echo "Installation completed successfully!"
echo "========================================="
echo ""
echo "To run LibrePods:"
echo "  cd $INSTALL_DIR/linux/build"
echo "  ./librepods"
echo ""
echo "Optional: Configure AVRCP for media controls (PipeWire/WirePlumber)"
echo "If tap gestures aren't working for media control, create:"
echo "  ~/.config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf"
echo ""
echo "With this content:"
echo "  monitor.bluez.properties = {"
echo "    bluez5.dummy-avrcp-player = true"
echo "  }"
echo ""
echo "Then restart WirePlumber:"
echo "  systemctl --user restart wireplumber"
echo ""
echo "For Hearing Aid features, see:"
echo "  $INSTALL_DIR/linux/README.md"
echo ""

