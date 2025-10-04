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
minorRelease=7								# Minor Release
AstroPi_v=${majorRelease}.${minorRelease}	# Actual Stable Release
KStars_v=3.5.4_v1.7							# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.7								# Based on INDI 1.9.7 Core
StellarSolver_v=1.9							# From Rlancaste GitHub

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# GUI windows width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 4 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# System full info, linux version and aarch
sysinfo=$(uname -sonmr)

# Disk usage
diskUsagePerc=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $5}')
diskUsageFree=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $4}')

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
		if [[ -f ./VNC-Server-7.15.0-Linux-ARM.deb ]]; then
            echo "# Update VNC Server"
            echo "Update VNC Server"
            # Try to install the local .deb with apt (handles dependencies). Fallback to dpkg + apt -f.
            if sudo apt-get update -y >/dev/null 2>&1 && sudo apt install -y ./VNC-Server-7.15.0-Linux-ARM.deb >/dev/null 2>&1; then
                echo "VNC Server installed/updated successfully"
            else
                echo "Primary install failed, trying dpkg + fix-deps..."
                if sudo dpkg -i ./VNC-Server-7.15.0-Linux-ARM.deb >/dev/null 2>&1; then
                    sudo apt-get install -f -y >/dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        zenity --error --text="<b>WARNING! Error installing VNC Server (fixing dependencies failed)</b>
                        \n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
                        exit 1
                    else
                        echo "VNC Server installed with dependency fix"
                    fi
                else
                    zenity --error --text="<b>WARNING! Error installing VNC Server</b>
                    \n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
                    exit 1
                fi
            fi
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
		# Check APT Source and stops unwanted updates
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f ${sources} ]; then
			echo -e "# Stop unwonted update # deb https://www.astroberry.io/repo/ buster main" | sudo tee ${sources}
			(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>sources.list.d</b>
			\n.Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title} && exit 1
		fi
		
		# Implement USB memory dump
		echo "# Preparing update"
		sudo sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title} && exit 1
		
		# Hold some update
		echo "# Hold some update"
		sudo apt-mark hold kstars-bleeding kstars-bleeding-data indi-full libindi-dev libindi1 indi-bin
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>hold some application</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	
	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>System PRE Update</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
		exit 1
		break
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
			exit 1
			break
		fi
	done	
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

# Check if system work on 64bit kernel
function chkARM64()
{
	if [ -n "$(grep 'arm_64bit=1' '/boot/config.txt')" ]; then
		# Do not force automatic switching to 64bit. Warn only 
		true
	else
		zenity --warning --width="${W}" --text="Your system is NOT 64 bit.
		\n${sysinfo}
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
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

# Add WiFi SSID
function setupWiFi()
{
	# Setup WiFi in wpa_supplicant
	# =========================================================================

	WIFI=$(zenity --forms --width=400 --height=300 --title="Setup WiFi in wpa_supplicant" --text="Add new WiFi network" \
		--add-entry="Enter the SSID of the wifi network to be added." \
		--add-password="Enter the password of selected wifi network")
	SSID=$(echo "$WIFI" | cut -d'|' -f1)
	PSK=$(echo "$WIFI" | cut -d'|' -f2)
	PRIORITY=10
	
	case "$?" in
	0)
		if [ -n "$(grep 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev' '/etc/wpa_supplicant/wpa_supplicant.conf')" ]; then
			sudo chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
			echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=IT\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$PRIORITY\"\n}\n" | tee /etc/wpa_supplicant/wpa_supplicant.conf
			case $? in
			0)
				zenity --info --width="${W}" --text "New WiFi has been added, reboot AstroPi." --title="${W_Title}"
				sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			1)
				zenity --error --width="${W}" --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
				sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			esac
		fi
	;;
	1)
		zenity --info --width="${W}" --text "No changes have been made to your current configuration" --title="${W_Title}"
		exit 0
	;;
	-1)
		zenity --error --width="${W}" --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 0
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
        zenity --error --width="${W}" --text="$1\n\nContact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
        trap - ERR
        exit 1
    }

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
    # Update dependencies and libraries for INDI
    (
        steps=("Updating package list" "Installing packages")
        percentages=(5 90)
        commands=( "sudo apt-get update -y" "sudo apt-get -y install git cdbs dkms cmake fxload libev-dev libgps-dev libgsl-dev libgsl0-dev libraw-dev libusb-dev libusb-1.0-0-dev zlib1g-dev libftdi-dev libftdi1-dev libjpeg-dev libkrb5-dev libnova-dev libtiff-dev libfftw3-dev librtlsdr-dev libcfitsio-dev libgphoto2-dev build-essential libdc1394-22-dev libboost-dev libboost-regex-dev libcurl4-gnutls-dev libtheora-dev liblimesuite-dev libavcodec-dev libavdevice-dev" )

        run_steps "Installing dependencies for INDI" commands percentages
    ) 
    if [ $? -ne 0 ]; then err_exit "Error installing dependencies required for INDI build"; fi

    # =================================================================
    # Build INDI Core
    if [ ! -d "${WorkDir}/indi-cmake" ]; then mkdir -p "${WorkDir}/indi-cmake"; fi
    cd "${WorkDir}/indi-cmake" || err_exit "Cannot cd to indi-cmake dir"
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
	
	echo "# Check KStars AstroPi"
	if [ ! -d "${WorkDir}"/kstars-cmake ]; then mkdir -p "${WorkDir}"/kstars-cmake; fi
	if [ ! -d "${HOME}"/.indi/logs ]; then mkdir -p "${HOME}"/.indi/logs; fi
	if [ ! -d "${HOME}"/.local/share/kstars/logs ]; then mkdir -p "${HOME}"/.local/share/kstars/logs; fi
	cd "${WorkDir}"/kstars-cmake || exit 1	
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
				${commands[$i]} 2>&1 | while IFS= read -r line; do
            		echo "# $line"
        		done
				{
					status=$?
					if (( status != 0 )); then
						zenity --error --width=${W} \
							--text="Error during <b>${steps[$i]}</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" \
							--title="${W_Title}"
						echo "# Cleaning CMake Project..."
						if [ -d "${WorkDir}" ]; then 
							sudo rm -rf "${WorkDir}"
						fi	
						exit 1
					fi
				}
			done
    		echo "100"
    		echo "# Installation complete!"
	) | zenity --progress --title="Building and Installing KStars AstroPi" --text="Starting build and installation..." --percentage=0 --auto-close --width="${Wprogress}"


	(($? != 0)) && zenity --error --width=${W} --text="Error build and install <b>KStars AstroPi</b>
	\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
  	
   	echo "# Cleaning CMake Project..."
	if [ -d "${WorkDir}" ]; then 
		sudo rm -rf "${WorkDir}"
	fi

	zenity --info --width=${W} --text="KStars AstroPi $KStars_v allredy installed" --title="${W_Title}"
}
