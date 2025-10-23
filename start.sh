#!/bin/bash

# This script downloads and runs Clash.Meta
# It is designed to be run in a fresh Kali Live environment.

# Exit immediately if any command fails
set -e

# --- START CONFIGURATION ---

# ⚠️ 1. EDIT THIS URL
#    Go to your config.yaml in GitHub, click "Raw", and copy/paste the URL here.
CONFIG_URL="https://raw.githubusercontent.com/Monster-ZeroX/Web/refs/heads/main/config.yaml"

# ⚠️ 2. (Optional) EDIT THIS URL
#    To update Clash, find the latest release URL from:
#    https://github.com/MetaCubeX/Clash.Meta/releases
#    This is for the 'clash.meta-linux-amd64' version.
CLASH_URL="https://github.com/MetaCubeX/Clash.Meta/releases/download/v1.18.1/clash.meta-linux-amd64-v1.18.1.gz"

# --- END CONFIGURATION ---


# --- Helper Functions for colored output ---
info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}
success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1"
}
error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
    exit 1
}
# --- End Helper Functions ---


# Check for curl
if ! command -v curl &> /dev/null; then
    error "curl is not installed. This script needs curl to run."
fi

# Define file and directory names
CLASH_DIR="$HOME/clash_session"
CLASH_BINARY="clash.meta"
CLASH_BINARY_GZ="${CLASH_BINARY}.gz"
CONFIG_FILE="config.yaml"

# Create a clean working directory
info "Setting up working directory at $CLASH_DIR"
mkdir -p "$CLASH_DIR"
cd "$CLASH_DIR"

# --- Download Clash Binary ---
info "Downloading Clash binary..."
curl -sL "$CLASH_URL" -o "$CLASH_BINARY_GZ"
if [ $? -ne 0 ]; then
    error "Failed to download Clash binary."
fi

# --- Download Your Config ---
info "Downloading config.yaml from your repo..."
curl -sL "$CONFIG_URL" -o "$CONFIG_FILE"
if [ $? -ne 0 ]; then
    error "Failed to download config.yaml. Please check your CONFIG_URL."
fi

# Check if config is empty (common error)
if [ ! -s "$CONFIG_FILE" ]; then
    error "config.yaml was downloaded but is empty. Check your CONFIG_URL."
fi

# --- Unpack and Prepare ---
info "Unpacking Clash..."
# -d = decompress, -f = force (overwrite if file exists)
gzip -df "$CLASH_BINARY_GZ" || error "Failed to unpack Clash."

info "Making Clash executable..."
chmod +x "$CLASH_BINARY" || error "Failed to set execute permissions."

# --- Run Clash ---
success "Setup complete! Starting Clash..."
echo "-----------------------------------------------------"
info "Clash will now take over this terminal."
info "To stop Clash, press Ctrl+C or close this window."
echo "-----------------------------------------------------"

# Run Clash in the current directory (-d .)
# It will automatically find the config.yaml in this folder.
./"$CLASH_BINARY" -d .
