#!/bin/bash
# fix-indi-dependencies.sh
# Script per risolvere i problemi di dipendenze mancanti per INDI su Debian Buster archiviato
# Questo script deve essere eseguito prima di chkINDI() per risolvere i problemi di repository

set -e  # Exit on error

echo "======================================"
echo "Fix INDI Dependencies for Debian Buster"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "Questo script deve essere eseguito con sudo"
   exit 1
fi

# Step 1: Update APT cache
echo ""
echo "Step 1: Aggiornamento della cache APT..."
apt-get update -y || print_warning "apt-get update ha generato avvertimenti, continuo..."
print_status "Cache APT aggiornata"

# Step 2: Install critical build tools with --no-install-recommends
echo ""
echo "Step 2: Installazione dei pacchetti critici di compilazione..."
apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    git \
    pkg-config || print_warning "Alcuni pacchetti critici potrebbero mancare"
print_status "Pacchetti critici installati"

# Step 3: Install development headers
echo ""
echo "Step 3: Installazione degli header di sviluppo..."
apt-get install -y --no-install-recommends \
    libev-dev \
    libgsl-dev \
    libgsl0-dev \
    libraw-dev \
    libusb-dev \
    libusb-1.0-0-dev \
    zlib1g-dev \
    libjpeg-dev \
    libtiff-dev \
    libfftw3-dev || print_warning "Alcuni pacchetti potrebbero mancare"
print_status "Header di sviluppo installati"

# Step 4: Try to install optional packages, but don't fail
echo ""
echo "Step 4: Installazione di pacchetti opzionali..."
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

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if apt-get install -y --no-install-recommends "$pkg" >/dev/null 2>&1; then
        print_status "$pkg installato"
    else
        print_warning "$pkg non disponibile nei repository, continuo..."
    fi
done

# Step 5: Fix any broken dependencies
echo ""
echo "Step 5: Risoluzione delle dipendenze rotte..."
if ! apt-get install -f -y >/dev/null 2>&1; then
    print_warning "Attenzione: potrebbero esserci dipendenze non soddisfatte"
else
    print_status "Dipendenze risolte"
fi

# Step 6: Auto-remove and auto-clean
echo ""
echo "Step 6: Pulizia dei pacchetti non necessari..."
apt-get autoremove -y >/dev/null 2>&1 || true
apt-get autoclean -y >/dev/null 2>&1 || true
print_status "Pulizia completata"

# Step 7: Check critical packages
echo ""
echo "Step 7: Verifica dei pacchetti critici..."
CRITICAL_PACKAGES=("cmake" "make" "build-essential" "git" "libev-dev" "libgsl-dev")
MISSING=()

for pkg in "${CRITICAL_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii.*$pkg"; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    print_status "Tutti i pacchetti critici sono installati"
else
    print_error "Pacchetti critici mancanti: ${MISSING[*]}"
    exit 1
fi

echo ""
echo "======================================"
echo "Fix completato con successo!"
echo "======================================"
echo ""
echo "Puoi ora eseguire chkINDI() per compilare INDI"
echo ""
