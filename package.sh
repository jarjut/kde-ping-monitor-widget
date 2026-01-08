#!/bin/bash

# Ping Monitor Widget Packaging Script

# Check if zip is available
if ! command -v zip &> /dev/null; then
    echo "✗ Error: 'zip' command not found!"
    echo ""
    echo "Please install zip first:"
    echo "  Ubuntu/Debian: sudo apt install zip"
    echo "  Fedora:        sudo dnf install zip"
    echo "  Arch:          sudo pacman -S zip"
    echo "  openSUSE:      sudo zypper install zip"
    echo ""
    exit 1
fi

WIDGET_NAME="ping-monitor"
VERSION=$(grep -oP '"Version":\s*"\K[^"]+' metadata.json)
OUTPUT_DIR="./output/"
PACKAGE_NAME="${WIDGET_NAME}-${VERSION}.plasmoid"

echo "Packaging Ping Monitor Widget v${VERSION}..."

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Clean up old packages
rm -f "${OUTPUT_DIR}"*.plasmoid

# Create the package from current directory
zip -r "${OUTPUT_DIR}${PACKAGE_NAME}" . \
    -x ".git/*" \
    -x ".gitignore" \
    -x "package.sh" \
    -x "output/*" \
    -x "*.plasmoid" \
    -x "*~" \
    -x "*.swp"

if [ $? -eq 0 ]; then
    echo "✓ Package created successfully: ${OUTPUT_DIR}${PACKAGE_NAME}"
    echo ""
    echo "To install:"
    echo "  kpackagetool6 -t Plasma/Applet -i ${OUTPUT_DIR}${PACKAGE_NAME}"
    echo ""
    echo "To upgrade:"
    echo "  kpackagetool6 -t Plasma/Applet -u ${OUTPUT_DIR}${PACKAGE_NAME}"
else
    echo "✗ Packaging failed!"
    exit 1
fi
