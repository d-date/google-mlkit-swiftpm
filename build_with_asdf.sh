#!/bin/bash
set -euo pipefail

# Set UTF-8 encoding for CocoaPods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set up asdf environment
export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
export PATH="/opt/homebrew/bin:$PATH"
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Add asdf shims to PATH
export PATH="$HOME/.asdf/shims:$PATH"

# Verify Ruby and Bundle are available
echo "Ruby version:"
ruby --version
echo "Bundle version:"
bundle --version

# Run make
make run
