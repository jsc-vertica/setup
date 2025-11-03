#!/bin/bash

# chezmoi manual installation script for Ubuntu 24
# This script downloads and installs the latest version of chezmoi

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l)
            echo "arm"
            ;;
        i386|i686)
            echo "386"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Function to get the latest version from GitHub API
get_latest_version() {
    local latest_url="https://api.github.com/repos/twpayne/chezmoi/releases/latest"
    
    if command -v curl >/dev/null 2>&1; then
        curl -s "$latest_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$latest_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//'
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

# Function to download and install chezmoi
install_chezmoi() {
    local version="$1"
    local arch="$2"
    local install_dir="$3"
    
    local filename="chezmoi_${version}_linux_${arch}.tar.gz"
    local download_url="https://github.com/twpayne/chezmoi/releases/download/v${version}/${filename}"
    local temp_dir=$(mktemp -d)
    
    print_status "Downloading chezmoi v${version} for ${arch}..."
    
    # Download the archive
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "${temp_dir}/${filename}" "$download_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${temp_dir}/${filename}" "$download_url"
    fi
    
    if [ $? -ne 0 ]; then
        print_error "Failed to download chezmoi"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    print_status "Extracting chezmoi..."
    
    # Extract the archive
    tar -xzf "${temp_dir}/${filename}" -C "$temp_dir"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to extract chezmoi"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Create install directory if it doesn't exist
    mkdir -p "$install_dir"
    
    # Move the binary to the install directory
    mv "${temp_dir}/chezmoi" "$install_dir/"
    
    # Make it executable
    chmod +x "${install_dir}/chezmoi"
    
    # Clean up
    rm -rf "$temp_dir"
    
    print_success "chezmoi installed successfully to ${install_dir}/chezmoi"
}

# Function to update PATH
update_path() {
    local install_dir="$1"
    local shell_rc=""
    
    # Detect shell and set appropriate RC file
    case "$SHELL" in
        */bash)
            shell_rc="$HOME/.bashrc"
            ;;
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
        *)
            shell_rc="$HOME/.profile"
            ;;
    esac
    
    # Check if directory is already in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_status "Adding $install_dir to PATH in $shell_rc"
        
        if [ "$SHELL" = */fish ]; then
            echo "set -gx PATH $install_dir \$PATH" >> "$shell_rc"
        else
            echo "export PATH=\"$install_dir:\$PATH\"" >> "$shell_rc"
        fi
        
        print_warning "Please run 'source $shell_rc' or restart your shell to update PATH"
    else
        print_status "$install_dir is already in PATH"
    fi
}

# Main installation function
main() {
    print_status "Starting chezmoi installation..."
    
    # Check if running on Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            print_warning "This script is designed for Ubuntu, but detected: $ID"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    
    # Detect architecture
    local arch=$(detect_arch)
    print_status "Detected architecture: $arch"
    
    # Get latest version
    print_status "Fetching latest version information..."
    local version=$(get_latest_version)
    
    if [ -z "$version" ]; then
        print_error "Failed to get latest version information"
        exit 1
    fi
    
    print_status "Latest version: v$version"
    
    # Determine installation directory
    local install_dir="$HOME/.local/bin"
    
    # Allow user to specify custom installation directory
    if [ -n "$1" ]; then
        install_dir="$1"
        print_status "Using custom installation directory: $install_dir"
    else
        print_status "Installing to: $install_dir"
    fi
    
    # Check if chezmoi is already installed
    if command -v chezmoi >/dev/null 2>&1; then
        local current_version=$(chezmoi --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        print_warning "chezmoi v$current_version is already installed"
        
        if [ "$current_version" = "$version" ]; then
            print_status "Already running the latest version"
            exit 0
        fi
        
        read -p "Upgrade to v$version? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    # Install chezmoi
    install_chezmoi "$version" "$arch" "$install_dir"
    
    # Update PATH if necessary
    update_path "$install_dir"
    
    # Verify installation
    if [ -x "${install_dir}/chezmoi" ]; then
        local installed_version=$("${install_dir}/chezmoi" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        print_success "chezmoi v$installed_version installed successfully!"
        print_status "Run '${install_dir}/chezmoi --help' to get started"
        
        # If not in current PATH, suggest how to run it
        if ! command -v chezmoi >/dev/null 2>&1; then
            print_status "To use chezmoi immediately, run: ${install_dir}/chezmoi"
        fi
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [INSTALL_DIR]"
    echo ""
    echo "Install chezmoi on Ubuntu 24"
    echo ""
    echo "Arguments:"
    echo "  INSTALL_DIR    Custom installation directory (default: \$HOME/.local/bin)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install to \$HOME/.local/bin"
    echo "  $0 /usr/local/bin     # Install to /usr/local/bin (may require sudo)"
    echo ""
}

# Handle command line arguments
case "${1:-}" in
    -h|--help|help)
        show_usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
