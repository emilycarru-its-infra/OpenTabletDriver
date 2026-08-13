#!/bin/bash

# ECUAD OpenTabletDriver Build Script
# Single-command build: Compile from source + package with munkipkg
#
# Usage: ./build.sh <version> [runtime]
# Example: ./build.sh 0.6.7 osx-arm64

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# ECUAD Configuration
CUSTOM_BUNDLE_ID="ca.ecuad.macadmin.OpenTabletDriver"
SIGNING_IDENTITY_APP="Developer ID Application: Example Organisation (TEAMID0000)"
SIGNING_KEYCHAIN="${HOME}/Library/Keychains/signing.keychain"
ENTITLEMENTS_FILE="${SCRIPT_DIR}/OpenTabletDriver.entitlements"
TEAM_ID="TEAMID0000"

VERSION="${1:-}"
if [[ -z "${VERSION}" ]]; then
    echo -e "${RED}Error: No version specified${NC}"
    echo "Usage: $0 <version> [runtime]"
    echo "Example: $0 0.6.7 osx-arm64"
    exit 1
fi

if [[ -n "${2:-}" ]]; then
    RUNTIME="${2}"
elif [[ "$(uname -m)" == "arm64" ]]; then
    RUNTIME="osx-arm64"
else
    RUNTIME="osx-x64"
fi

echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ECUAD OpenTabletDriver Build v${VERSION}          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo -e "${GREEN}Runtime:${NC} ${RUNTIME}"
echo ""

# Step 1: Update submodule
echo -e "${BLUE}[1/6]${NC} ${YELLOW}Updating submodule...${NC}"
git submodule update --init --recursive
echo "  ✓ Submodule updated"

# Step 2: Clean
echo ""
echo -e "${BLUE}[2/6]${NC} ${YELLOW}Cleaning previous builds...${NC}"
rm -rf payload/Applications/OpenTabletDriver.app
rm -rf bin
echo "  ✓ Clean"

# Step 3: Build with dotnet
echo ""
echo -e "${BLUE}[3/6]${NC} ${YELLOW}Building OpenTabletDriver from source...${NC}"

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}Error: .NET SDK not found${NC}"
    echo "Please install .NET 8 SDK from https://dotnet.microsoft.com/download/dotnet/8.0"
    exit 1
fi

# Build using the upstream package script for macOS
PATH="$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin:$PATH" \
    bash ./eng/bash/package.sh --runtime "${RUNTIME}" --output bin --configuration Release

if [[ ! -d "bin/OpenTabletDriver.app" ]]; then
    echo -e "${RED}Error: Built app not found${NC}"
    exit 1
fi

echo "  ✓ Built"

# Step 4: Update Info.plist with custom bundle ID
echo ""
echo -e "${BLUE}[4/6]${NC} ${YELLOW}Updating bundle identifier...${NC}"

INFO_PLIST="bin/OpenTabletDriver.app/Contents/Info.plist"
if [[ -f "${INFO_PLIST}" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${CUSTOM_BUNDLE_ID}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string ${CUSTOM_BUNDLE_ID}" "${INFO_PLIST}"
    
    # Set version
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${VERSION}" "${INFO_PLIST}"
    
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${VERSION}" "${INFO_PLIST}"
    
    echo "  ✓ Updated bundle ID: ${CUSTOM_BUNDLE_ID}"
else
    echo -e "${RED}Error: Info.plist not found${NC}"
    exit 1
fi

# Step 5: Re-sign all binaries with proper options for notarization
echo ""
echo -e "${BLUE}[5/6]${NC} ${YELLOW}Code signing for notarization...${NC}"

# Find and sign all executable files and dylibs
find "bin/OpenTabletDriver.app/Contents/MacOS" -type f \( -perm +111 -o -name "*.dylib" \) -print0 | while IFS= read -r -d '' file; do
    if file "${file}" | grep -q "Mach-O"; then
        if [[ -x "${file}" && "${file}" != *.dylib ]]; then
            codesign --force --sign "${SIGNING_IDENTITY_APP}" \
                --timestamp \
                --options runtime \
                --entitlements "${ENTITLEMENTS_FILE}" \
                --keychain "${SIGNING_KEYCHAIN}" \
                "${file}" 2>/dev/null || true
        else
            codesign --force --sign "${SIGNING_IDENTITY_APP}" \
                --timestamp \
                --options runtime \
                --keychain "${SIGNING_KEYCHAIN}" \
                "${file}" 2>/dev/null || true
        fi
    fi
done

# Sign the main app bundle
codesign --force --sign "${SIGNING_IDENTITY_APP}" \
    --timestamp \
    --options runtime \
    --entitlements "${ENTITLEMENTS_FILE}" \
    --keychain "${SIGNING_KEYCHAIN}" \
    --deep \
    "bin/OpenTabletDriver.app"

# Verify signature
codesign --verify --verbose "bin/OpenTabletDriver.app"
echo "  ✓ Signed with hardened runtime and timestamp"

# Step 6: Copy to payload
echo ""
echo -e "${BLUE}[6/6]${NC} ${YELLOW}Copying to munkipkg payload...${NC}"
mkdir -p "payload/Applications"
ditto "bin/OpenTabletDriver.app" "payload/Applications/OpenTabletDriver.app"

# Remove any .gitkeep files from payload
find payload -name ".gitkeep" -type f -delete

# Verify bundle ID
ACTUAL_ID=$(defaults read "${SCRIPT_DIR}/payload/Applications/OpenTabletDriver.app/Contents/Info.plist" CFBundleIdentifier)
if [[ "${ACTUAL_ID}" != "${CUSTOM_BUNDLE_ID}" ]]; then
    echo -e "${RED}Error: Bundle ID mismatch${NC}"
    echo "Expected: ${CUSTOM_BUNDLE_ID}"
    echo "Got: ${ACTUAL_ID}"
    exit 1
fi
echo "  ✓ Verified: ${ACTUAL_ID}"

# Update version in build-info.yaml
sed -i '' "s/^version: .*/version: ${VERSION}/" build-info.yaml

# Step 7: Build package
echo ""
echo -e "${BLUE}[7/7]${NC} ${YELLOW}Building package with munkipkg...${NC}"
munkipkg "${SCRIPT_DIR}"

# Rename package to include version
mv "build/OpenTabletDriver.pkg" "build/OpenTabletDriver-${VERSION}.pkg"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              BUILD SUCCESSFUL ✓                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Package:${NC} build/OpenTabletDriver-${VERSION}.pkg"
echo -e "${GREEN}Bundle ID:${NC} ${CUSTOM_BUNDLE_ID}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Test installation:"
echo "     sudo installer -pkg build/OpenTabletDriver-${VERSION}.pkg -target /"
echo ""
echo "  2. Deploy privacy profile:"
echo "     profiles install -path=OpenTabletDriver.mobileconfig"
echo ""
echo "  3. Import to Munki:"
echo "     munkiimport build/OpenTabletDriver-${VERSION}.pkg"
echo ""
