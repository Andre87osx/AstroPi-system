#!/bin/bash
# Self-extracting installer for KStars AstroPi
# Estrae e installa i file nelle directory corrette

set -e

# Funzione per estrarre i dati dopo il marker __ARCHIVE_BELOW__
extract_archive() {
    TMPDIR=$(mktemp -d)
    echo "Estrazione dei file temporanei in $TMPDIR..."
    ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")
    tail -n +$ARCHIVE_LINE "$0" | base64 -d | tar xz -C "$TMPDIR"
    echo "Installazione dei file..."
    sudo cp -r $TMPDIR/usr/* /usr/
    echo "Pulizia..."
    rm -rf "$TMPDIR"
    echo "Installazione completata."
}

# Conferma
read -p "Installare KStars AstroPi nelle directory di sistema? [Invio per continuare, Ctrl+C per annullare] "

extract_archive
exit 0

__ARCHIVE_BELOW__
# Qui sotto va incollato l'archivio tar.gz base64-encoded generato dallo script di build
# Esempio di generazione: tar czf - usr | base64 > payload.b64
# Poi cat install_kstars.sh payload.b64 > KStars-AstroPi-Installer.sh
