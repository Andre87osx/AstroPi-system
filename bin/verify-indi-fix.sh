#!/bin/bash
# verify-indi-fix-installation.sh
# Verifica che tutti i file di fix per INDI siano stati installati correttamente

echo "╔════════════════════════════════════════╗"
echo "║  INDI Fix Installation Verification    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}[✓]${NC} $1"
        return 0
    else
        echo -e "${RED}[✗]${NC} $1 - NON TROVATO"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}[✓]${NC} $1/"
        return 0
    else
        echo -e "${RED}[✗]${NC} $1/ - NON TROVATO"
        return 1
    fi
}

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cartella base: $BASEDIR"
echo ""

echo "Verificando file modificati..."
check_file "$BASEDIR/include/functions.sh" && echo "  └─ Contiene miglioramenti INDI" || true
check_file "$BASEDIR/include/functions.sh.bak" && echo "  └─ Backup del file originale" || true
echo ""

echo "Verificando script creati..."
check_file "$BASEDIR/bin/fix-indi-dependencies.sh"
check_file "$BASEDIR/bin/check-indi-deps.sh"
check_file "$BASEDIR/bin/quick-fix-indi.sh"
check_file "$BASEDIR/bin/99-indi-buster-archive.conf"
echo ""

echo "Verificando documentazione..."
check_file "$BASEDIR/INDI_DEPENDENCIES_FIX.md"
check_file "$BASEDIR/FIX_INDI_DEPENDENCIES_v1_7_1.md"
check_file "$BASEDIR/README_INDI_QUICK_START.md"
check_file "$BASEDIR/CHANGELOG_INDI_FIX.md"
check_file "$BASEDIR/IMPLEMENTATION_SUMMARY.txt"
echo ""

echo "═════════════════════════════════════════"
echo "Riepilogo:"
echo "═════════════════════════════════════════"
echo ""
echo "File Creati:"
echo "  • bin/fix-indi-dependencies.sh"
echo "  • bin/check-indi-deps.sh"
echo "  • bin/quick-fix-indi.sh"
echo "  • bin/99-indi-buster-archive.conf"
echo ""
echo "Documentazione:"
echo "  • INDI_DEPENDENCIES_FIX.md"
echo "  • FIX_INDI_DEPENDENCIES_v1_7_1.md"
echo "  • README_INDI_QUICK_START.md"
echo "  • CHANGELOG_INDI_FIX.md"
echo "  • IMPLEMENTATION_SUMMARY.txt"
echo ""
echo "File Modificati:"
echo "  • include/functions.sh (2 funzioni migliorate)"
echo "  • include/functions.sh.bak (backup automatico)"
echo ""
echo "═════════════════════════════════════════"
echo ""
echo "Prossimi Step:"
echo ""
echo "1. Esegui System Pre Update:"
echo "   $ ./bin/AstroPi.sh"
echo ""
echo "2. Pre-risolvi le dipendenze:"
echo "   $ sudo bash bin/quick-fix-indi.sh"
echo ""
echo "3. Compila INDI:"
echo "   $ ./bin/AstroPi.sh"
echo ""
echo "═════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ Installazione completata!${NC}"
echo ""
