#!/bin/bash
# Script per creare un pacchetto zip di KStars AstroPi con la struttura di installazione reale
set -e

# Funzione import universale per includere librerie dalla cartella include
function import() {
    local mylib="$1"
    # Cerca nella cartella include accanto a bin
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local mylib_path="${script_dir}/../include/${mylib}.sh"
    if [ -f "${mylib_path}" ]; then
        source "${mylib_path}"
    else
        echo "Error: Cannot find library at: ${mylib_path}"
        exit 1
    fi
}

# Importa functions.sh
import functions

# Variabili principali (ora prese da functions.sh)
# majorRelease, minorRelease, AstroPi_v, KStars_v già disponibili
appDir=${HOME}/.local/share/astropi
WorkDir=${HOME}/.Projects
PACKAGE_DIR="${WorkDir}/kstars-package"

# Pulizia e preparazione
rm -rf "${PACKAGE_DIR}"
mkdir -p "${PACKAGE_DIR}/usr/bin"
mkdir -p "${PACKAGE_DIR}/usr/share/applications"
mkdir -p "${PACKAGE_DIR}/usr/share/config.kcfg"
mkdir -p "${PACKAGE_DIR}/usr/share/metainfo"
mkdir -p "${PACKAGE_DIR}/usr/share/knotifications5"

# Compila KStars AstroPi (come in chkKStars)
if [ ! -d "${WorkDir}/kstars-cmake" ]; then
    mkdir -p "${WorkDir}/kstars-cmake"
fi
cd "${WorkDir}/kstars-cmake"
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=Off "${appDir}/kstars-astropi"
make -j $(expr $(nproc) + 2)

# Copia l'eseguibile principale (kstars)
if [ -f "kstars" ]; then
    cp kstars "${PACKAGE_DIR}/usr/bin/"
else
    # Cerca l'eseguibile nella sottocartella kstars
    if [ -f "kstars/kstars" ]; then
        cp kstars/kstars "${PACKAGE_DIR}/usr/bin/"
    else
        echo "Eseguibile kstars non trovato!"
        exit 1
    fi
fi

# Copia i file desktop e config
SRC_KSTARS="${appDir}/kstars-astropi/kstars"
cp "${SRC_KSTARS}/org.kde.kstars.desktop" "${PACKAGE_DIR}/usr/share/applications/" 2>/dev/null || true
cp "${SRC_KSTARS}/kstars.kcfg" "${PACKAGE_DIR}/usr/share/config.kcfg/" 2>/dev/null || true
cp "${SRC_KSTARS}/kstars.notifyrc" "${PACKAGE_DIR}/usr/share/knotifications5/" 2>/dev/null || true
cp "${appDir}/kstars-astropi/org.kde.kstars.appdata.xml" "${PACKAGE_DIR}/usr/share/metainfo/" 2>/dev/null || true

# (Opzionale) Copia altre risorse necessarie (temi, dati, ecc.)
# Puoi aggiungere qui altre cartelle/files se richiesto

# Crea il pacchetto autoestraente
cd "${PACKAGE_DIR}"
ARCHIVE_NAME="KStars-AstroPi_${KStars_v}.tar.gz"
tar czf "$ARCHIVE_NAME" .
base64 "$ARCHIVE_NAME" > payload.b64

# Crea l'installer autoestraente
INSTALLER="${HOME}/KStars-AstroPi_${KStars_v}-installer.sh"
cat "${script_dir}/install_kstars.sh" payload.b64 > "$INSTALLER"
chmod +x "$INSTALLER"

# Pulizia
rm -f "$ARCHIVE_NAME" payload.b64

# Messaggio finale
echo "Installer autoestraente creato: $INSTALLER"
