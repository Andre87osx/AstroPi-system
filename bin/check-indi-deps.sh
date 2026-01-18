#!/bin/bash
# check-indi-deps.sh
# Script per controllare se tutte le dipendenze per INDI sono disponibili

echo "======================================"
echo "Check INDI Dependencies"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_missing() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Critical packages
CRITICAL_PACKAGES=(
    "cmake"
    "make"
    "build-essential"
    "git"
    "pkg-config"
    "libev-dev"
    "libgsl-dev"
    "libgsl0-dev"
    "libraw-dev"
    "libusb-dev"
    "libusb-1.0-0-dev"
    "zlib1g-dev"
    "libjpeg-dev"
    "libtiff-dev"
    "libfftw3-dev"
)

# Optional packages
OPTIONAL_PACKAGES=(
    "libftdi-dev"
    "libftdi1-dev"
    "libkrb5-dev"
    "libnova-dev"
    "librtlsdr-dev"
    "libcfitsio-dev"
    "libgphoto2-dev"
    "libdc1394-22-dev"
    "libboost-dev"
    "libboost-regex-dev"
    "libcurl4-gnutls-dev"
    "libtheora-dev"
    "liblimesuite-dev"
    "libavcodec-dev"
    "libavdevice-dev"
)

echo "Checking CRITICAL packages..."
echo ""
CRITICAL_MISSING=0

for pkg in "${CRITICAL_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        print_ok "$pkg"
    else
        print_missing "$pkg"
        ((CRITICAL_MISSING++))
    fi
done

echo ""
echo "Checking OPTIONAL packages..."
echo ""
OPTIONAL_MISSING=0

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        print_ok "$pkg"
    else
        print_warning "$pkg (optional)"
        ((OPTIONAL_MISSING++))
    fi
done

echo ""
echo "======================================"
echo "SUMMARY"
echo "======================================"
echo ""

if [ $CRITICAL_MISSING -eq 0 ]; then
    print_ok "All CRITICAL packages are installed"
    if [ $OPTIONAL_MISSING -eq 0 ]; then
        print_ok "All OPTIONAL packages are installed"
        print_info "System is ready for INDI compilation!"
        exit 0
    else
        print_warning "$OPTIONAL_MISSING optional packages are missing"
        print_info "System can proceed with INDI compilation, but some features might be limited"
        exit 0
    fi
else
    print_missing "$CRITICAL_MISSING CRITICAL packages are missing"
    print_warning "System cannot compile INDI without these packages"
    print_info "Run: sudo bash fix-indi-dependencies.sh"
    exit 1
fi
