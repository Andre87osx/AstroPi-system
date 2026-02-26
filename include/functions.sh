# shellcheck disable=SC2034
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########
# rev 1.7 sept 2024 

# Common array anf functions

# Create version of AstroPi
majorRelease=1								# Major Release
minorRelease=7.8							# Minor Release
AstroPi_v=${majorRelease}.${minorRelease}	# Actual Stable Release
KStars_v=3.5.4_v1.7.9						# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.7								# Based on INDI 1.9.7 Core
StellarSolver_v=1.9							# From Rlancaste GitHub

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# GUI windows width and height - responsive sizes for different dialog types
# Small: confirmations, quick info (yes/no dialogs)
W_SMALL=$((SCREEN_WIDTH / 4))
H_SMALL=$((SCREEN_HEIGHT / 4))

# Medium: standard info dialogs, forms (typical messages)
W_MEDIUM=$((SCREEN_WIDTH / 3))
H_MEDIUM=$((SCREEN_HEIGHT / 2))

# Large: log viewers, detailed error messages, text-info dialogs
W_LARGE=$((SCREEN_WIDTH / 5))
H_LARGE=$((SCREEN_HEIGHT / 3))

# Legacy variables for backward compatibility (defaults to medium)
W=${W_MEDIUM}
H=${H_MEDIUM}
Wprogress=$((SCREEN_WIDTH / 2))

# Cap main window size to avoid huge dialogs on scaled displays
if [ ${W} -gt 900 ]; then W=900; fi
if [ ${H} -gt 600 ]; then H=600; fi

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# System full info, linux version and aarch
sysinfo=$(uname -sonmr)

# Disk usage
diskUsagePerc=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $5}')
diskUsageFree=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $4}')

# Helper function: Auto-detect optimal dialog size based on text length
# Usage: size=$(get_dialog_size "text content") -> returns "WIDTH HEIGHT"
function get_dialog_size()
{
	local text="$1"
	local num_lines=$(echo -e "$text" | wc -l)
	local max_chars=$(echo -e "$text" | awk '{print length}' | sort -rn | head -1)
	
	# Estimate needed width: roughly 8 pixels per character (adjustable)
	local est_width=$((max_chars * 8 + 40))
	local est_height=$((num_lines * 25 + 80))
	
	# Constrain to available presets
	local final_width=$W_MEDIUM
	local final_height=$H_MEDIUM
	
	# Use LARGE only when clearly needed; otherwise stay at MEDIUM
	if [ $num_lines -gt 8 ] || [ $max_chars -gt 140 ] || [ $est_height -gt $H_LARGE ]; then
		final_width=$W_LARGE
		final_height=$H_LARGE
	fi
	
	echo "$final_width $final_height"
}

# Smart wrapper for zenity command - automatically sizes dialogs
# This intercepts all zenity calls from sourced scripts and applies intelligent sizing
# No script modifications needed - backward compatible!
function zenity()
{
	local -a args=("$@")
	local text=""
	local width_idx=-1
	local text_idx=-1
	local dialog_type=""
	
	# Parse arguments to find --text and --width
	for i in "${!args[@]}"; do
		case "${args[$i]}" in
			--text=*)
				text="${args[$i]#--text=}"
				text_idx=$i
				;;
			--text)
				# Handle --text as separate parameter
				text="${args[$((i+1))]}"
				text_idx=$i
				;;
			--width=*)
				width_idx=$i
				;;
			--width)
				width_idx=$i
				;;
			--error)
				dialog_type="error"
				;;
			--info)
				dialog_type="info"
				;;
			--warning)
				dialog_type="warning"
				;;
			--question)
				dialog_type="question"
				;;
		esac
	done
	
	# If --text is found and --width exists, replace it with smart size
	if [ $text_idx -ge 0 ] && [ $width_idx -ge 0 ] && [ ! -z "$text" ]; then
		# Get optimal dimensions for this text
		local dimensions=($(get_dialog_size "$text"))
		local new_width=${dimensions[0]}
		
		# Replace the --width= parameter
		if [[ "${args[$width_idx]}" =~ ^--width= ]]; then
			args[$width_idx]="--width=$new_width"
		elif [[ "${args[$width_idx]}" == "--width" ]]; then
			args[$((width_idx+1))]=$new_width
		fi
	fi
	
	# Call the actual zenity with processed arguments
	/usr/bin/zenity "${args[@]}"
}


# Chk USER and create path
function chkUser()
{
	if [[ -z ${USER} ]] && [[ ${USER} != root ]]; then
		echo "Run this script as user not as root"
		echo " "
		echo "Read how to use at top of this script"
		zenity --error --text="<b>WARNING! Run this script as user not as root</b>
		\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
		exit 1
		break
	else
		appDir=${HOME}/.local/share/astropi		# Default application path
		WorkDir=${HOME}/.Projects				# Working path for cmake
  		mkdir -p ${HOME}/.local/share/astropi
    	mkdir -p ${HOME}/.Projects
		echo "Wellcome to AstroPi System"
		echo "=========================="
		echo " "
	fi
}

# Install all script in default path
function install_script()
{
	(	
		cd "${appDir}"/bin || exit 1
		if [[ -f ./AstroPi.sh ]]; then
			echo "# Install AstroPi.sh in /usr/bin/"
			echo "Install AstroPi.sh in /usr/bin/"
			sudo cp "${appDir}"/bin/AstroPi.sh /usr/bin/AstroPi.sh
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		if [[ -f ./kstars.sh ]]; then
			echo "# Install kstars.sh in /usr/bin/"
			echo "Install kstars.sh in /usr/bin/"
			sudo cp "${appDir}"/bin/kstars.sh /usr/bin/kstars.sh
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		if [[ -f ./AstroPi.desktop ]]; then
			echo "# Install AstroPi.desktop in /usr/share/applications/"
			echo "Install AstroPi.desktop in /usr/share/applications/"
			sudo cp "${appDir}"/bin/AstroPi.desktop /usr/share/applications/AstroPi.desktop
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
			
		fi
		if [[ -f ./kstars.desktop ]]; then
			echo "# Install kstars.desktop in /usr/share/applications/"
			echo "Install kstars.desktop in /usr/share/applications/"
			sudo cp "${appDir}"/bin/kstars.desktop /usr/share/applications/kstars.desktop
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
			
		fi
		if  [[ -f ./panel ]]; then
			echo "# Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
			echo "Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
			cp "${appDir}"/bin/panel "${HOME}"/.config/lxpanel/LXDE-pi/panels/panel
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		if [[ -f ./autohotspot.service ]]; then
			echo "# Install autohotspot.service in /etc/systemd/system/"
			echo "Install autohotspot.service in /etc/systemd/system/"
			sudo cp "${appDir}"/bin/autohotspot.service /etc/systemd/system/autohotspot.service
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
			
		fi
  		if [[ -f ./dnsmasq.conf ]]; then
			echo "# overwrite DNSMAQ.CONF in /etc/dnsmasq.conf"
			echo "Overwrite DNSMAQ.CONF in /etc/dnsmasq.conf"
			sudo cp "${appDir}"/bin/dnsmasq.conf /etc/dnsmasq.conf
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
			
		fi
		if [[ -f ./autohotspot ]]; then
			echo "# Install autohotspot in /usr/bin/"
			echo "Install autohotspot in /usr/bin/"
			sudo cp "${appDir}"/bin/autohotspot /usr/bin/autohotspot
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		# Install INDI Helper Scripts
		if [[ -f ./fix-indi-dependencies.sh ]]; then
			echo "# Install fix-indi-dependencies.sh in ${appDir}/bin/"
			echo "Install fix-indi-dependencies.sh in ${appDir}/bin/"
			sudo chmod +x "${appDir}"/bin/fix-indi-dependencies.sh
		else
			echo "Warning: fix-indi-dependencies.sh not found (optional)"
		fi
		if [[ -f ./check-indi-deps.sh ]]; then
			echo "# Install check-indi-deps.sh in ${appDir}/bin/"
			echo "Install check-indi-deps.sh in ${appDir}/bin/"
			sudo chmod +x "${appDir}"/bin/check-indi-deps.sh
		else
			echo "Warning: check-indi-deps.sh not found (optional)"
		fi
		if [[ -f ./quick-fix-indi.sh ]]; then
			echo "# Install quick-fix-indi.sh in ${appDir}/bin/"
			echo "Install quick-fix-indi.sh in ${appDir}/bin/"
			sudo chmod +x "${appDir}"/bin/quick-fix-indi.sh
		else
			echo "Warning: quick-fix-indi.sh not found (optional)"
		fi
		if [[ -f ./verify-indi-fix.sh ]]; then
			echo "# Install verify-indi-fix.sh in ${appDir}/bin/"
			echo "Install verify-indi-fix.sh in ${appDir}/bin/"
			sudo chmod +x "${appDir}"/bin/verify-indi-fix.sh
		else
			echo "Warning: verify-indi-fix.sh not found (optional)"
		fi
		cd "${appDir}"/include || exit 1
		if [[ -f ./solar-system-dark.svg ]]; then
			echo "# Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			sudo cp "${appDir}"/include/solar-system-dark.svg /usr/share/icons/gnome/scalable/places/solar-system-dark.svg
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		if [[ -f ./solar-system.svg ]]; then
			echo "# Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			sudo cp "${appDir}"/include/solar-system.svg /usr/share/icons/gnome/scalable/places/solar-system.svg
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi
		if [[ -f ./kstars.svg ]]; then
			echo "# Install KStars icons in /usr/share/icons/gnome/scalable/places"
			echo "Install KStars icons in /usr/share/icons/gnome/scalable/places"
			sudo cp "${appDir}"/include/kstars.svg /usr/share/icons/gnome/scalable/places/kstars.svg
		else
			echo "Error in addigng AstroPi system files"
			zenity --error --text="<b>WARNING! Error in addigng AstroPi system files</b>
			\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
			exit 1
		fi	
	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
}

# Make all script executable
function make_executable()
{
	for f in "${appDir}"/bin/*.*; do
		if sudo chmod +x "${f}"; then
			echo "Make executable ${f} script"
			else
			echo "Error in ${f} script"
		fi
	done
}

# Prepair fot update system
function system_pre_update()
{
	(
		# Rimuovi il repository astroberry se esiste
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f ${sources} ]; then
			sudo rm -f ${sources}
			if [ $? -ne 0 ]; then
				zenity --error --width=${W} --text="Errore durante la rimozione di <b>astroberry.list</b>\nContatta il supporto su <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
				exit 1
			fi
		fi

		# 1. Pulizia repository APT
		echo "==> Pulizia repository APT…"
		sudo find /etc/apt/sources.list.d/ -type f -name "*.list" -exec rm -v {} \;
		if [ $? -ne 0 ]; then
			zenity --error --width=${W} --text="Errore durante la pulizia di /etc/apt/sources.list.d/*.list" --title=${W_Title}
			exit 1
		fi
		sudo find /etc/apt/sources.list.d/ -type f \( -name "*.bak*" -o -name "*.save" -o -name "*.old" \) -exec rm -v {} \;
		sudo find /etc/apt/ -maxdepth 1 -type f \( -name "*.bak*" -o -name "*.save" -o -name "*.old" \) -exec rm -v {} \;

		# 2. Ricostruzione sources.list con repository archiviati Debian 10 Buster (2025)
		echo "==> Ricostruzione sources.list per Debian 10 Buster…"
		sudo sh -c ">/etc/apt/sources.list" # Svuota completamente il file
		sudo bash -c 'cat > /etc/apt/sources.list <<EOF
# Main repository - Debian Archived
deb [trusted=yes] http://archive.debian.org/debian/ buster main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian/ buster main contrib non-free

# Updates - Debian Archived
deb [trusted=yes] http://archive.debian.org/debian/ buster-updates main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian/ buster-updates main contrib non-free

# Security updates - Debian Archived
deb [trusted=yes] http://archive.debian.org/debian-security buster/updates main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian-security buster/updates main contrib non-free

# Backports (archived, optional)
deb [trusted=yes] http://archive.debian.org/debian/ buster-backports main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian/ buster-backports main contrib non-free

# Raspberry Pi OS (for ARM-specific packages on Buster)
# This helps find ARM-specific packages like libgphoto2 with correct dependencies
deb [trusted=yes] http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi
deb [trusted=yes] http://archive.raspberrypi.org/debian/ buster main
EOF'
		if [ $? -ne 0 ]; then
			zenity --error --width=${W} --text="Errore durante la creazione di /etc/apt/sources.list" --title=${W_Title}
			exit 1
		fi

		# 3. Disabilita check validità e consente repo archiviati non firmati
		sudo bash -c 'cat > /etc/apt/apt.conf.d/99archive-debian-buster <<EOF
Acquire::Check-Valid-Until "false";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF'

		# 3.5 Aggiungi configurazione ottimizzata per INDI su Buster archiviato
		echo "==> Aggiunta configurazione APT ottimizzata per INDI…"
		sudo bash -c 'cat > /etc/apt/apt.conf.d/99indi-buster-archive <<EOF
Acquire::Check-Valid-Until "false";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
Acquire::Retries "3";
APT::Acquire::Retries "3";
Acquire::ForceIPv4 "true";
EOF'
		if [ $? -ne 0 ]; then
			zenity --error --width=${W} --text="Errore durante la creazione di /etc/apt/apt.conf.d/99indi-buster-archive" --title=${W_Title}
			exit 1
		fi

		# 3b. Aggiungi chiavi per Raspberry Pi (opzionale, per ARM packages)
		echo "==> Aggiunta chiavi GPG per Raspberry Pi…"
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9120CD33B31B0AE418D00D6B47BB525DC65406FA >/dev/null 2>&1 || true
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8A1AF3A26997E3 >/dev/null 2>&1 || true

		# 4. Pulizia APT (l'aggiornamento viene eseguito da system_update)
		echo "==> Pulizia cache APT…"
		sudo apt clean
		if [ $? -ne 0 ]; then
			zenity --error --width=${W} --text="Errore durante la pulizia della cache di APT" --title=${W_Title}
			exit 1
		fi

		echo "==> Completato."

		# Implement USB memory dump
		echo "# Preparing update"
		sudo sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title} && exit 1

	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>System PRE Update</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
		exit 1
		break
	fi
	
	# Install VNC Server before system update
	if [[ -f "${appDir}/bin/VNC-Server-7.16.0-Linux-ARM.deb" ]]; then
		(
			echo "# Installing VNC Server..."
			echo "30"
			echo "# Attempting to install VNC Server via apt..."
			if sudo apt install -y "${appDir}/bin/VNC-Server-7.16.0-Linux-ARM.deb" 2>&1 | while read -r line; do echo "# $line"; done; then
				echo "70"
				echo "# VNC Server installed successfully"
			else
				echo "70"
				echo "# Fallback: trying dpkg + fix-deps..."
				if sudo dpkg -i "${appDir}/bin/VNC-Server-7.16.0-Linux-ARM.deb" 2>&1 | while read -r line; do echo "# $line"; done; then
					echo "85"
					echo "# Fixing dependencies..."
					sudo apt-get install -f -y 2>&1 | while read -r line; do echo "# $line"; done
					echo "100"
					echo "# VNC Server installed with dependency fix"
				else
					echo "100"
					echo "# Error: VNC Server installation failed"
				fi
			fi
			echo "100"
			echo "# VNC Server installation complete"
		) | zenity --progress --title="${W_Title}" --text="<b>Installing VNC Server...</b>" --percentage=0 --auto-close --auto-kill --width=${Wprogress}
	fi
	
	# Suggest running INDI fix script (only if not already done)
	INDI_FIX_MARKER="${appDir}/.indi-fix-completed"
	if [[ -f "${appDir}"/bin/quick-fix-indi.sh && ! -f "${INDI_FIX_MARKER}" ]]; then
		zenity --question --width=${W} --text="<b>INDI Dependencies Fix</b>\n\nIl sistema è ora configurato con i repository corretti.\n\nVuoi pre-risolvere le dipendenze di INDI?\n(Consigliato prima di compilare INDI)" --title=${W_Title} --ok-label="Si, esegui fix" --cancel-label="No, dopo"
		if [ $? -eq 0 ]; then
			# Run quick-fix-indi.sh with progress bar
			(
				echo "# Avvio pre-risoluzione dipendenze INDI..."
				echo "5"
				sudo bash "${appDir}"/bin/quick-fix-indi.sh 2>&1 | while IFS= read -r line; do
					echo "# $line"
				done
				echo "100"
				echo "# Pre-risoluzione completata!"
			) | zenity --progress --title="Pre-risoluzione Dipendenze INDI" --text="Installazione pacchetti critici..." --percentage=0 --auto-close --width=${Wprogress}
			
			if [ $? -eq 0 ]; then
				# Create marker file to indicate fix has been completed
				touch "${INDI_FIX_MARKER}"
				zenity --info --width=${W} --text="<b>Pre-risoluzione Completata</b>\n\nLe dipendenze INDI sono state pre-risolte.\n\nPuoi ora procedere con 'Check INDI' per compilare INDI." --title=${W_Title}
			fi
		fi
	fi
}

# Get full AstoPi System update
function system_update()
{
	(
 		# Ensure unbuffer is installed
		if ! command -v unbuffer &> /dev/null; then
    			sudo apt-get install -y expect
		fi
 	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}

 	# APT Default commands for up to date the system
	apt_commands=(
	'apt-get update'
 	'apt install vlc-bin'
	'apt-get upgrade'
	'apt-get full-upgrade'
	'apt autopurge'
	'apt autoremove'
	'apt autoclean'
	)
	for CMD in "${apt_commands[@]}"; do
		echo ""
		echo "Running $CMD"
		echo ""
		{
			echo "# Running Update ${CMD}"
			sudo ${CMD} -y 2>&1 | while read -r line; do
    				echo "# $line"
        		done
			sleep 1s
		} | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
		exit_stat=$?
		if [ ${exit_stat} -eq 0 ]; then
			echo "System successfully updated on $(date)" >> "${appDir}"/bin/update-log.txt
		elif [ ${exit_stat} -ne 0 ]; then
			echo "Error running $CMD on $(date), exit status code: ${exit_stat}" >> "${appDir}"/bin/update-log.txt
			zenity --error --width=${W} --text="Something went wrong in <b>System Update ${CMD}</b>
			\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
			# Don't exit immediately - continue with other commands
		fi
	done	
	
	# Install wmctrl if missing
	if ! command -v wmctrl >/dev/null 2>&1; then
		(
			echo "# Installing wmctrl..."
			echo "25"
			if sudo apt-get install -y wmctrl 2>&1 | while read -r line; do echo "# $line"; done; then
				echo "100"
				echo "# wmctrl installed successfully"
			else
				echo "100"
				echo "# Error: wmctrl installation failed"
				exit 1
			fi
		) | zenity --progress --title="${W_Title}" --text="<b>Installing wmctrl...</b>" --percentage=0 --auto-close --auto-kill --width=${Wprogress}
		if [ $? -ne 0 ]; then
			zenity --error --width=${W} --text="<b>WARNING! Error installing wmctrl</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		fi
	fi
}

# Check if GSC exist for simulator solving
function chkIndexGsc()
{
	(
		echo "# Check GSC catalog for Simulaor"
		if [ ! -d /usr/share/GSC ]; then
			mkdir -p "${HOME}"/gsc | cd "${HOME}"/gsc
			if [ ! -f "${HOME}"/gsc/bincats_GSC_1.2.tar.gz ]; then
				echo "# Download GSC catalog for Simulaor"
				wget -O bincats_GSC_1.2.tar.gz http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/tar.gz?bincats/GSC_1.2 2>&1 | \
				sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | zenity \
				--progress --title="Downloading GSC..." --pulsate --auto-close --auto-kill --width=${Wprogress}
			fi
			echo "# Install GSC catalog for Simulaor"
			tar -xvzf bincats_GSC_1.2.tar.gz
			cd "${HOME}"/gsc/src || exit 1
			make -j $(expr $(nproc) + 2)
			mv gsc.exe gsc
			echo "${ask_pass}" | sudo -S cp gsc /usr/bin/
			cp -r "${HOME}"/gsc /usr/share/
			sudo mv /usr/share/gsc /usr/share/GSC
			sudo rm -r /usr/share/GSC/bin-dos
			sudo rm -r /usr/share/GSC/src
			sudo rm /usr/share/GSC/bincats_GSC_1.2.tar.gz
			sudo rm /usr/share/GSC/bin/gsc.exe
			sudo rm /usr/share/GSC/bin/decode.exe
			sudo rm -r "${HOME}"/gsc
			if [ -z "$(grep 'export GSCDAT' /etc/profile)" ]; then
				cp /etc/profile /etc/profile.copy
				echo "export GSCDAT=/usr/share/GSC" >> /etc/profile
			fi
		else
			zenity --info --width="${W}" --text="<b>GSC (Guide Star Catalog - NASA v1.3) allredy exist.</b>
			\nFor issue contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		fi
	
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width="${W}" --text="Something went wrong in <b>Install GSC.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Check Astrometry Index for solving
function chkIndexAstro()
{
	echo "Check all Index, if missing download it..."
	zenity --info --width="${W}" --text="<b>Check if all astrometric index are present</b>
			\nThis may take a few hours, depending on how many indexes are missing
			\nFor issue contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
	if "${appDir}"/bin/astrometry.sh; then
		true
	else
		zenity --error --width="${W}" --text="Something went wrong in <b>Install Index Astrometry.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

function chkARM64()
{
	if grep -q 'arm_64bit=0' '/boot/config.txt'; then
		# Il sistema è già a 32 bit
		true
	else
		zenity --question --width="${W}" --text="Il sistema NON è a 32 bit.
		\n${sysinfo}
		\nVuoi forzare la modalità 32 bit?
		\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"

		if [ $? -eq 0 ]; then
			# L'utente ha accettato → modifica config.txt
			sudo sed -i '/^arm_64bit=/d' /boot/config.txt
			echo 'arm_64bit=0' | sudo tee -a /boot/config.txt > /dev/null

			# Chiede se riavviare
			zenity --question --width="${W}" --text="Configurazione aggiornata: il sistema sarà in modalità 32 bit al prossimo riavvio.
			\nVuoi riavviare ora?" --title="${W_Title}"

			if [ $? -eq 0 ]; then
				# Riavvio immediato
				sudo reboot
			fi
		fi
	fi
}

# Check if Hotspot service works fine
function chksysHotSpot()
{
	# After some system updates hostapd gets masked using Raspbian Buster, and above. This checks and fixes  
	# the issue and also checks dnsmasq is ok so the hotspot can be generated.
	# Check Hostapd is unmasked and disabled
	if systemctl -all list-unit-files hostapd.service | grep "hostapd.service masked" >/dev/null 2>&1 ;then
		sudo systemctl unmask hostapd.service >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files hostapd.service | grep "hostapd.service enabled" >/dev/null 2>&1 ;then
		sudo systemctl disable hostapd.service >/dev/null 2>&1
		sudo systemctl stop hostapd >/dev/null 2>&1
	fi
	# Check dnsmasq is disabled
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service masked" >/dev/null 2>&1 ;then
		sudo systemctl unmask dnsmasq >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service enabled" >/dev/null 2>&1 ;then
		sudo systemctl disable dnsmasq >/dev/null 2>&1
		sudo systemctl stop dnsmasq >/dev/null 2>&1
	fi
}

# Cleanup the system
function sysClean()
{
	(
		echo "# Remove unnecessary lib..."
		sudo apt-get clean
		echo "# Delete old AstroPi version"
		if [ -d "${GitDir}" ]; then
			sudo rm -rf "${GitDir}"
		fi
		echo "# Cleaning CMake Project..."
		if [ -d "${WorkDir}" ]; then 
			sudo rm -rf "${WorkDir}"
		fi
  		# Delete old AstroPi installations and GIT
		file_old=(
		'AstroPi'
 		'AstroPi-system'
		'AstroPi system updater'
		'Update'
 		'.Update'
		'install'
		'functions'
		'wget-log'
		)
		for f in "${HOME}"/"${file_old[@]}"*; do sudo rm -Rf "${HOME}/$f"; done	
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width="${Wprogress}"
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width="${W}" --text="Something went wrong in <b>System Cleanup</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
 	zenity --info --width="${W}" --text="Cleaning was done correctly" --title="${W_Title}"
}

function ksBackup()
{
	# Percorsi principali
	CONFIG_FILE="$HOME/.config/kstarsrc"
	DATA_DIR="$HOME/.local/share/kstars"
	INDI_DIR="$HOME/.indi"
	BACKUP_DIR="$HOME/BCK_KStars"
	RESTORE_SCRIPT="$BACKUP_DIR/ripristina_kstars.sh"

	mkdir -p "$BACKUP_DIR"

	zenity --info --title="Backup KStars" --width="${W}" \
	--text="Inizio backup dei file:\n\n• kstarsrc\n• kstarsData\n• INDIConfig\n• File .esl e .esq trovati nella home"

	# Conta file totali
	TOTAL_FILES=0
	[ -f "$CONFIG_FILE" ] && TOTAL_FILES=$((TOTAL_FILES + 1))
	[ -d "$DATA_DIR" ] && TOTAL_FILES=$((TOTAL_FILES + $(find "$DATA_DIR" -type f | wc -l)))
	[ -d "$INDI_DIR" ] && TOTAL_FILES=$((TOTAL_FILES + $(find "$INDI_DIR" -type f | wc -l)))
	ESL_FILES=($(find "$HOME" -type f -iname "*.esl"))
	ESQ_FILES=($(find "$HOME" -type f -iname "*.esq"))
	TOTAL_FILES=$((TOTAL_FILES + ${#ESL_FILES[@]} + ${#ESQ_FILES[@]}))

	# Barra Zenity
	(
	COUNT=0

	[ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$BACKUP_DIR/kstarsrc" && COUNT=$((COUNT + 1)) && echo $((COUNT * 100 / TOTAL_FILES))

	if [ -d "$DATA_DIR" ]; then
		find "$DATA_DIR" -type f | while read FILE; do
			DEST="$BACKUP_DIR/kstarsData/${FILE#$DATA_DIR/}"
			mkdir -p "$(dirname "$DEST")"
			cp "$FILE" "$DEST"
			COUNT=$((COUNT + 1))
			echo $((COUNT * 100 / TOTAL_FILES))
		done
	fi

	if [ -d "$INDI_DIR" ]; then
		find "$INDI_DIR" -type f | while read FILE; do
			DEST="$BACKUP_DIR/INDIConfig/${FILE#$INDI_DIR/}"
			mkdir -p "$(dirname "$DEST")"
			cp "$FILE" "$DEST"
			COUNT=$((COUNT + 1))
			echo $((COUNT * 100 / TOTAL_FILES))
		done
	fi

	for FILE in "${ESL_FILES[@]}"; do
		REL="${FILE#$HOME/}"
		DEST="$BACKUP_DIR/esl/$REL"
		mkdir -p "$(dirname "$DEST")"
		cp "$FILE" "$DEST"
		COUNT=$((COUNT + 1))
		echo $((COUNT * 100 / TOTAL_FILES))
	done

	for FILE in "${ESQ_FILES[@]}"; do
		REL="${FILE#$HOME/}"
		DEST="$BACKUP_DIR/esq/$REL"
		mkdir -p "$(dirname "$DEST")"
		cp "$FILE" "$DEST"
		COUNT=$((COUNT + 1))
		echo $((COUNT * 100 / TOTAL_FILES))
	done

	) | zenity --progress --title="Backup in corso..." --width="${W}" --percentage=0 --auto-close

	# Script di ripristino
	cat <<EOF > "$RESTORE_SCRIPT"
	#!/bin/bash

	W=500
	zenity --info --title="Ripristino KStars" --width="\${W}" \
	--text="Inizio ripristino dei file:\n\n• kstarsrc\n• kstarsData\n• INDIConfig\n• File .esl e .esq"

	TOTAL=\$(find "$BACKUP_DIR" -type f | wc -l)
	COUNT=0

	(
	cp -f "$BACKUP_DIR/kstarsrc" "\$HOME/.config/kstarsrc"
	COUNT=\$((COUNT + 1))
	echo \$((COUNT * 100 / TOTAL))

	find "$BACKUP_DIR/kstarsData" -type f | while read FILE; do
		DEST="\$HOME/.local/share/kstars/\${FILE#$BACKUP_DIR/kstarsData/}"
		mkdir -p "\$(dirname "\$DEST")"
		cp "\$FILE" "\$DEST"
		COUNT=\$((COUNT + 1))
		echo \$((COUNT * 100 / TOTAL))
	done

	find "$BACKUP_DIR/INDIConfig" -type f | while read FILE; do
		DEST="\$HOME/.indi/\${FILE#$BACKUP_DIR/INDIConfig/}"
		mkdir -p "\$(dirname "\$DEST")"
		cp "\$FILE" "\$DEST"
		COUNT=\$((COUNT + 1))
		echo \$((COUNT * 100 / TOTAL))
	done

	find "$BACKUP_DIR/esl" -type f -iname "*.esl" | while read FILE; do
		REL="\${FILE#$BACKUP_DIR/esl/}"
		DEST="\$HOME/\$REL"
		mkdir -p "\$(dirname "\$DEST")"
		cp "\$FILE" "\$DEST"
		COUNT=\$((COUNT + 1))
		echo \$((COUNT * 100 / TOTAL))
	done

	find "$BACKUP_DIR/esq" -type f -iname "*.esq" | while read FILE; do
		REL="\${FILE#$BACKUP_DIR/esq/}"
		DEST="\$HOME/\$REL"
		mkdir -p "\$(dirname "\$DEST")"
		cp "\$FILE" "\$DEST"
		COUNT=\$((COUNT + 1))
		echo \$((COUNT * 100 / TOTAL))
	done

	) | zenity --progress --title="Ripristino in corso..." --width="\${W}" --percentage=0 --auto-close

	zenity --info --title="Ripristino completato" --width="\${W}" \
	--text="Tutti i file sono stati ripristinati correttamente."
EOF

	chmod +x "$RESTORE_SCRIPT"

	zenity --info --title="Backup completato" --width="${W}" \
	--text="Backup completato in:\n\n$BACKUP_DIR\n\nPer ripristinare, esegui:\n\n$RESTORE_SCRIPT"
}	

# Add WiFi SSID

function setupWiFi() {
    WIFI=$(zenity --forms --width=400 --height=300 --title="Setup WiFi in wpa_supplicant" --text="Add new WiFi network" \
        --add-entry="Enter the SSID of the wifi network to be added." \
        --add-password="Enter the password of selected wifi network")

    SSID=$(echo "$WIFI" | cut -d'|' -f1)
    PSK=$(echo "$WIFI" | cut -d'|' -f2)

    case "$?" in
    0)
        if grep -q 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev' '/etc/wpa_supplicant/wpa_supplicant.conf'; then
            sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

            # Aggiunge la rete senza cancellare le altre
            sudo bash -c "cat >> /etc/wpa_supplicant/wpa_supplicant.conf <<EOF

network={
    ssid=\"$SSID\"
    psk=\"$PSK\"
    key_mgmt=WPA-PSK
    scan_ssid=1
}
EOF"

            if [ $? -eq 0 ]; then
                zenity --info --width=300 --text "Nuova rete WiFi aggiunta. Riavvia il Raspberry Pi." --title="Setup WiFi"
            else
                zenity --error --width=300 --text="Errore nella scrittura del file wpa_supplicant." --title="Setup WiFi"
            fi

            sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
        fi
    ;;
    1)
        zenity --info --width=300 --text "Nessuna modifica effettuata." --title="Setup WiFi"
    ;;
    -1)
        zenity --error --width=300 --text="Errore imprevisto." --title="Setup WiFi"
    ;;
    esac
}


# Enable / Disable HotSpot services
function chkHotspot()
{
	# Disable AstroPi auto hotspot
	# =========================================================================
	if [ "$StatHotSpot" == Enable ]; then
		sudo systemctl disable autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't disable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		sudo sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		zenity --info --width=${W} --text "The auto hotspot service is now <b>disable</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi" --title="${W_Title}"
	else
	# Enable AstroPi auto hotspot
	# =========================================================================
		sudo echo "nohook wpa_supplicant" >>/etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		sudo systemctl enable autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		zenity --info --width=${W} --text "The auto hotspot service is now <b>active</b>. Network Manager create a hotspot if no wifi found" --title="${W_Title}"
	fi
}

# Install / Update INDI 
function chkINDI()
{
    # Fail on pipeline errors and catch unexpected errors to show zenity message
    set -o pipefail
    trap 'err_exit "An error occurred while installing/updating INDI (line ${LINENO})."' ERR

    err_exit() {
        # Cleanup workspace on any error so build artifacts are removed
        echo "# Cleaning CMake Project..."
        if [ -d "${WorkDir}" ]; then
            sudo rm -rf "${WorkDir}"
        fi
        # Show error message and exit
        zenity --error --width="${W}" --text="$1\n\nContact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
        trap - ERR
        exit 1
    }

    # Clean previous build artifacts if they exist
    echo "# Cleaning previous INDI build artifacts..."
    if [ -d "${WorkDir}" ]; then
        sudo rm -rf "${WorkDir}" || err_exit "Failed to remove old WorkDir: ${WorkDir}"
    fi

    # Ensure unbuffer is installed
    if ! command -v unbuffer &> /dev/null; then
        sudo apt-get update -y >/dev/null 2>&1 || err_exit "Failed to update apt before installing 'expect'"
        sudo apt-get install -y expect >/dev/null 2>&1 || err_exit "Failed to install 'expect' (required for unbuffer)"
    fi

    # Prepare work dir
    if [ ! -d "${WorkDir}" ]; then
        mkdir -p "${WorkDir}" || err_exit "Cannot create WorkDir: ${WorkDir}"
    fi
    cd "${WorkDir}" || err_exit "Cannot change directory to ${WorkDir}"

    # Helper: run a list of commands, stream output to zenity and move progress during output
    run_steps() {
        local title="$1"; shift
        local -n cmds=$1; shift
        local -n ends=$1; shift

        (
            local current=5
            echo "${current}"
            echo "# ${title} - starting..."

            for i in "${!cmds[@]}"; do
                local cmd="${cmds[$i]}"
                local target=${ends[$i]}
                [ -z "${target}" ] && target=$(( current + 30 ))
                if [ "${target}" -gt 100 ]; then target=100; fi

                echo "# Running: ${cmd}"
                # Ensure line-buffered output, then read each line and nudge progress forward.
                # We use stdbuf -oL -eL to reduce buffering; unbuffer could be used if available.
                stdbuf -oL -eL bash -c "${cmd} 2>&1" | while IFS= read -r line; do
                    # compute a small step towards target, never overshoot
                    step=$(( (target - current) / 8 ))
                    if [ "${step}" -le 0 ]; then step=1; fi
                    current=$(( current + step ))
                    if [ "${current}" -ge "${target}" ]; then current=$(( target - 1 )); fi
                    echo "${current}"
                    echo "# ${line}"
                done
                # capture exit status of the command (first element of PIPESTATUS)
                status=${PIPESTATUS[0]}

                # If the command produced no output (while loop not executed), advance progress artificially
                if [ "${status}" -eq 0 ]; then
                    # finish the segment to the exact target
                    while [ "${current}" -lt "${target}" ]; do
                        current=$(( current + 2 ))
                        [ "${current}" -gt "${target}" ] && current="${target}"
                        echo "${current}"
                        echo "# running..."
                        sleep 0.25
                    done
                    # ensure the target value is shown as completed for this step
                    echo "${target}"
                    echo "# Step complete"
                else
                    echo "# Command failed (exit ${status})"
                    exit ${status}
					echo "# Cleaning CMake Project..."
					if [ -d "${WorkDir}" ]; then 
						sudo rm -rf "${WorkDir}"
					fi	
                fi
            done

            echo "100"
            echo "# ${title} complete"
        ) | zenity --progress --title="${title}" --text="Starting ${title}..." --percentage=0 --auto-close --width="${Wprogress}"
        if [ $? -ne 0 ]; then err_exit "Error during: ${title}"; fi
    }

    # =================================================================
    # Download packages from git - fail fast and report on error
    (
        echo "# Downloading INDI ${Indi_v}..."
        wget -c "https://github.com/indilib/indi/archive/refs/tags/v${Indi_v}.tar.gz" -O - | tar -xz -C "${WorkDir}" 2>&1 | while IFS= read -r line; do echo "# $line"; done
        if [ ${PIPESTATUS[0]:-1} -ne 0 ]; then exit 2; fi

        echo "33"
        echo "# Downloading INDI 3rd-party ${Indi_v}..."
        wget -c "https://github.com/indilib/indi-3rdparty/archive/refs/tags/v${Indi_v}.tar.gz" -O - | tar -xz -C "${WorkDir}" 2>&1 | while IFS= read -r line; do echo "# $line"; done
        if [ ${PIPESTATUS[0]:-1} -ne 0 ]; then exit 3; fi

        echo "66"
        echo "# Downloading StellarSolver ${StellarSolver_v}..."
        git clone -b "${StellarSolver_v}" https://github.com/rlancaste/stellarsolver.git "${WorkDir}/stellarsolver" 2>&1 | while IFS= read -r line; do echo "# $line"; done
        if [ ${PIPESTATUS[0]:-1} -ne 0 ]; then exit 4; fi

        echo "100"
        echo "# Downloads complete"
    ) | zenity --progress --title="Downloading INDI ${Indi_v}, 3rd-party and StellarSolver" --text="Starting..." --percentage=0 --auto-close --width="${Wprogress}"
    if [ $? -ne 0 ]; then err_exit "Error downloading required sources for INDI/stellarsolver"; fi

    # =================================================================
	# Update dependencies and libraries for INDI, with improved error reporting
	(
		steps=("Updating package list" "Installing packages")
		percentages=(5 90)
		commands=( "sudo apt-get update -y" "sudo apt-get -y install git cdbs dkms cmake fxload libev-dev libgps-dev libgsl-dev libgsl0-dev libraw-dev libusb-dev libusb-1.0-0-dev zlib1g-dev libftdi-dev libftdi1-dev libjpeg-dev libkrb5-dev libnova-dev libtiff-dev libfftw3-dev librtlsdr-dev libcfitsio-dev libgphoto2-dev build-essential libdc1394-22-dev libboost-dev libboost-regex-dev libcurl4-gnutls-dev libtheora-dev liblimesuite-dev libavcodec-dev libavdevice-dev" )

		# Run and capture output for debugging
		LOGFILE="${HOME}/indi-deps-install.log"
		{
			echo "# apt-get update output:"
			sudo apt-get update -y 2>&1
			
			# Try to install all packages
			echo "# apt-get install output:"
			if ! sudo apt-get -y install git cdbs dkms cmake fxload libev-dev libgps-dev libgsl-dev libgsl0-dev libraw-dev libusb-dev libusb-1.0-0-dev zlib1g-dev libftdi-dev libftdi1-dev libjpeg-dev libkrb5-dev libnova-dev libtiff-dev libfftw3-dev librtlsdr-dev libcfitsio-dev libgphoto2-dev build-essential libdc1394-22-dev libboost-dev libboost-regex-dev libcurl4-gnutls-dev libtheora-dev liblimesuite-dev libavcodec-dev libavdevice-dev 2>&1; then
				echo ""
				echo "# Tentativo di risoluzione delle dipendenze rotte..."
				sudo apt-get install -f -y 2>&1
				echo ""
				echo "# Tentativo di autoremozione di pacchetti problematici..."
				sudo apt-get autoremove -y 2>&1
				echo ""
				echo "# Secondo tentativo di installazione delle dipendenze..."
				sudo apt-get -y install git cdbs dkms cmake fxload libev-dev libgps-dev libgsl-dev libgsl0-dev libraw-dev libusb-dev libusb-1.0-0-dev zlib1g-dev libftdi-dev libftdi1-dev libjpeg-dev libkrb5-dev libnova-dev libtiff-dev libfftw3-dev librtlsdr-dev libcfitsio-dev libgphoto2-dev build-essential libdc1394-22-dev libboost-dev libboost-regex-dev libcurl4-gnutls-dev libtheora-dev liblimesuite-dev libavcodec-dev libavdevice-dev 2>&1 || true
			fi
			
			# Installa in modo più permissivo i pacchetti che potrebbero mancare in Buster
			echo ""
			echo "# Installazione permissiva di pacchetti opzionali..."
			for pkg in liblimesuite-dev libavcodec-dev libavdevice-dev libtheora-dev; do
				echo "# Tentativo di installare: $pkg"
				sudo apt-get install -y "$pkg" 2>&1 || echo "# Pacchetto $pkg non disponibile, continuo..."
			done 2>&1
			
		} | tee "$LOGFILE" | zenity --progress --title="Installing dependencies for INDI" --text="Installing dependencies..." --percentage=0 --auto-close --width="${Wprogress}"
		status=${PIPESTATUS[0]}
		if [ $status -ne 0 ]; then
			# Check if critical packages are installed
			critical_pkgs=("cmake" "make" "build-essential" "git" "libev-dev" "libgsl-dev")
			missing=()
			for pkg in "${critical_pkgs[@]}"; do
				if ! dpkg -l | grep -q "^ii.*$pkg"; then
					missing+=("$pkg")
				fi
			done
			
			if [ ${#missing[@]} -gt 0 ]; then
				zenity --error --width="${W}" --title="${W_Title}" --text="<b>Errore durante l'installazione delle dipendenze per INDI</b>\n\nPacchetti critici mancanti: ${missing[*]}\n\nVedi dettagli nel log:\n$LOGFILE"
				zenity --text-info --width=900 --height=600 --title="Dettagli installazione dipendenze INDI" --filename="$LOGFILE"
				err_exit "Error installing dependencies required for INDI build (see log above)"
			else
				# Se i pacchetti critici sono ok, continuiamo anche se alcuni pacchetti opzionali mancano
				echo "# I pacchetti critici sono stati installati. Alcuni pacchetti opzionali potrebbero mancare." | tee -a "$LOGFILE"
				zenity --warning --width="${W}" --title="${W_Title}" --text="<b>Installazione parziale delle dipendenze INDI</b>\n\nI pacchetti critici sono stati installati, ma alcuni pacchetti opzionali potrebbero mancare.\n\nVedi dettagli nel log:\n$LOGFILE\n\nContinuo con la compilazione..."
			fi
		fi
	)

    # =================================================================
    # Build INDI Core
    if [ ! -d "${WorkDir}/indi-cmake" ]; then mkdir -p "${WorkDir}/indi-cmake"; fi
    cd "${WorkDir}/indi-cmake" || err_exit "Cannot cd to indi-cmake dir"
    
    # Ensure critical packages are present before building
    echo "# Checking critical packages for INDI build..."
    sudo apt-get install -y --no-install-recommends cmake make build-essential >/dev/null 2>&1 || err_exit "Failed to ensure critical build packages"
    
    commands_core=(
        "cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug ${WorkDir}/indi-${Indi_v}"
        "make -j $(expr $(nproc) + 2)"
        "sudo make install"
    )
    ends_core=(30 80 95)
    run_steps "Building and Installing INDI Core" commands_core ends_core

    # =================================================================
    # Build INDI 3rd party LIB
    if [ ! -d "${WorkDir}/indi3rd_lib-cmake" ]; then mkdir -p "${WorkDir}/indi3rd_lib-cmake"; fi
    cd "${WorkDir}/indi3rd_lib-cmake" || err_exit "Cannot cd to indi3rd_lib-cmake dir"
    commands_lib=(
        "cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_LIBS=1 ${WorkDir}/indi-3rdparty-${Indi_v}"
        "make -j $(expr $(nproc) + 2)"
        "sudo make install"
    )
    ends_lib=(30 80 95)
    run_steps "Building and Installing INDI 3rd party LIB" commands_lib ends_lib

    # =================================================================
    # Build INDI 3rd party DRIVER
    if [ ! -d "${WorkDir}/indi3rd_driver-cmake" ]; then mkdir -p "${WorkDir}/indi3rd_driver-cmake"; fi
    cd "${WorkDir}/indi3rd_driver-cmake" || err_exit "Cannot cd to indi3rd_driver-cmake dir"
    commands_drv=(
        "cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_FXLOAD=1 ${WorkDir}/indi-3rdparty-${Indi_v}"
        "make -j $(expr $(nproc) + 2)"
        "sudo make install"
    )
    ends_drv=(30 80 95)
    run_steps "Building and Installing INDI 3rd party DRIVER" commands_drv ends_drv

    # =================================================================
    # Build StellarSolver
    if [ ! -d "${WorkDir}/solver-cmake" ]; then mkdir -p "${WorkDir}/solver-cmake"; fi
    cd "${WorkDir}/solver-cmake" || err_exit "Cannot cd to solver-cmake dir"
    commands_solver=(
        "cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTING=Off ${WorkDir}/stellarsolver"
        "make -j $(expr $(nproc) + 2)"
        "sudo make install"
    )
    ends_solver=(30 80 95)
    run_steps "Building and Installing StellarSolver" commands_solver ends_solver

    # Cleanup workspace
    echo "# Cleaning CMake Project..."
    if [ -d "${WorkDir}" ]; then
        sudo rm -rf "${WorkDir}" || err_exit "Failed to remove WorkDir during cleanup"
    fi

    # Success message
    zenity --info --text="INDI and Driver have been updated to version ${Indi_v}" --width="${W}" --title="${W_Title}"

    # restore trap
    trap - ERR
}

# Install / Update KStars AstroPi 
function chkKStars()
{
	# Fail on pipeline errors and catch unexpected errors to show zenity message
	set -o pipefail
	trap 'err_exit_kstars "An error occurred while building KStars AstroPi (line ${LINENO})."' ERR

	err_exit_kstars() {
		# Cleanup workspace on any error so build artifacts are removed
		echo "# Cleaning CMake Project..."
		if [ -d "${WorkDir}" ]; then
			sudo rm -rf "${WorkDir}"
		fi
		# Show error message and exit
		zenity --error --width="${W}" --text="$1\n\nContact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		trap - ERR
		exit 1
	}

	# Clean previous build artifacts if they exist
	echo "# Cleaning previous KStars build artifacts..."
	if [ -d "${WorkDir}" ]; then
		sudo rm -rf "${WorkDir}" || err_exit_kstars "Failed to remove old WorkDir: ${WorkDir}"
	fi

	echo "# Check KStars AstroPi"
	if [ ! -d "${WorkDir}"/kstars-cmake ]; then mkdir -p "${WorkDir}"/kstars-cmake; fi
	if [ ! -d "${HOME}"/.indi/logs ]; then mkdir -p "${HOME}"/.indi/logs; fi
	if [ ! -d "${HOME}"/.local/share/kstars/logs ]; then mkdir -p "${HOME}"/.local/share/kstars/logs; fi
	cd "${WorkDir}"/kstars-cmake || err_exit_kstars "Cannot change directory to ${WorkDir}/kstars-cmake"
	
	# =================================================================
	# Build KStar AstroPi
	commands=(
    		"cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=Off ${appDir}/kstars-astropi"
    		"make -j $(expr $(nproc) + 2)"
    		"sudo make install"
		)

	steps=("Running cmake" "Running make" "Running make install")
	percentages=(30 60 90)

	(
    		echo "10"
    		echo "# Preparing to run cmake..."

			for i in "${!commands[@]}"; do
				echo "${percentages[$i]}"
				echo "# ${steps[$i]}..."
				
				# Execute command with output streaming, capture exit status
				stdbuf -oL -eL bash -c "${commands[$i]} 2>&1" | while IFS= read -r line; do
            		echo "# $line"
        		done
				
				# Capture exit status from the command (first element of PIPESTATUS)
				status=${PIPESTATUS[0]}
				
				if [ ${status} -ne 0 ]; then
					echo "# ERROR: ${steps[$i]} failed with exit code ${status}"
					exit ${status}
				fi
			done
    		echo "100"
    		echo "# Installation complete!"
	) | zenity --progress --title="Building and Installing KStars AstroPi" --text="Starting build and installation..." --percentage=0 --auto-close --width="${Wprogress}"

	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then 
		err_exit_kstars "Error during KStars AstroPi build and installation"
	fi
  	
   	echo "# Cleaning CMake Project..."
	if [ -d "${WorkDir}" ]; then 
		sudo rm -rf "${WorkDir}" || err_exit_kstars "Failed to remove WorkDir during cleanup"
	fi

	zenity --info --width=${W} --text="KStars AstroPi $KStars_v successfully installed" --title="${W_Title}"
	
	# restore trap
	trap - ERR
}
