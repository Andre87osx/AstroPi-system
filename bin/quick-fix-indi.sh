#!/bin/bash
# quick-fix-indi.sh
# Script rapido per risolvere i problemi di INDI su Debian Buster
# Esecuzione: sudo bash quick-fix-indi.sh

set -e

echo "╔═══════════════════════════════════════╗"
echo "║  AstroPi INDI Quick Fix for Buster    ║"
echo "║  Debian 10 Archived Repository Fix    ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} Questo script deve essere eseguito con sudo"
    exit 1
fi

# Step 1: Update repositories
print_step "Aggiornamento cache APT..."
apt-get update -y || print_warning "apt-get update ha generato avvertimenti"
print_ok "Cache APT aggiornata"

# Step 2: Clean broken packages
print_step "Pulizia pacchetti rotti..."
apt-get autoremove -y >/dev/null 2>&1 || true
apt-get autoclean -y >/dev/null 2>&1 || true
print_ok "Pulizia completata"

# Step 3: Fix broken dependencies
print_step "Risoluzione dipendenze rotte..."
apt-get install -f -y >/dev/null 2>&1 || print_warning "Alcune dipendenze potrebbero essere irrisolvibili"
print_ok "Tentativo di risoluzione completato"

# Step 4: Install critical build packages
print_step "Installazione pacchetti critici di compilazione..."
apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    git \
    pkg-config \
    2>&1 | grep -E "^(Reading|Building|Selecting|Unpacking|Setting up)" || true
print_ok "Pacchetti critici installati"

# Step 5: Install development headers (most important)
print_step "Installazione header di sviluppo..."
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
    libfftw3-dev \
    2>&1 | grep -E "^(Reading|Building|Selecting|Unpacking|Setting up)" || true
print_ok "Header di sviluppo installati"

# Step 6: Try optional packages but don't fail
print_step "Installazione pacchetti opzionali..."
for pkg in libftdi-dev libcfitsio-dev libboost-dev libcurl4-gnutls-dev; do
    if apt-get install -y --no-install-recommends "$pkg" >/dev/null 2>&1; then
        print_ok "$pkg installato"
    else
        print_warning "$pkg non disponibile (opzionale)"
    fi
done

# Step 7: Verify critical packages
print_step "Verifica pacchetti critici..."
CRITICAL=("cmake" "make" "build-essential" "libev-dev" "libgsl-dev")
ALL_OK=true

for pkg in "${CRITICAL[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        print_ok "$pkg ✓"
    else
        echo -e "${RED}[✗]${NC} $pkg MANCANTE!"
        ALL_OK=false
    fi
done

# Final status
echo ""
echo "╔═══════════════════════════════════════╗"

if [ "$ALL_OK" = true ]; then
    echo -e "║ ${GREEN}✓ SISTEMA PRONTO PER INDI${NC}        ║"
else
    echo -e "║ ${RED}✗ PROBLEMI RISCONTRATI${NC}           ║"
fi

echo "╚═══════════════════════════════════════╝"
echo ""

if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}Sistema pronto!${NC}"
    echo "Puoi ora eseguire: ./bin/AstroPi.sh → Check INDI"
    exit 0
else
    echo -e "${RED}Errore: alcuni pacchetti critici mancano${NC}"
    echo "Prova: sudo bash bin/fix-indi-dependencies.sh"
    exit 1
fi
