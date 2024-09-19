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
KStars_v=3.5.6v1.7							# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.1								# Based on INDI 1.9.1 Core

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# GUI windows width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# System full info, linux version and aarch
sysinfo=$(uname -sonmr)

# Calculate cmake processor
JOBS=$(grep -c ^processor /proc/cpuinfo)

# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

# Disk usage
diskUsagePerc=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $5}')
diskUsageFree=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $4}')

# Create next AstoPi versions
#//FIXME
function next_v()
{
	#//FIXME
	next_AstroPi_v=("${AstroPi_v%.*}.$((${AstroPi_v##*.}+1))")
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
		WorkDir=${HOME}/.Projects			# Working path for cmake
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
	# Ensure unbuffer is installed
	if ! command -v unbuffer &> /dev/null; then
    		sudo apt-get install -y expect
	fi
 
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
		for f in "${HOME}"/"${file_old[@]}".*; do sudo rm -Rf "$f"; done
  
		zenity --info --width="${W}" --text="Cleaning was done correctly" --title="${W_Title}"
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width="${Wprogress}"
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width="${W}" --text="Something went wrong in <b>System Cleanup</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
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
			echo -e "country=IT\nctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nap_scan=1\n\nupdate_config=1\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$PRIORITY\"\n}\n" | tee /etc/wpa_supplicant/wpa_supplicant.conf
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
	(
		echo "# Download Indi $Indi_v..."
		if [ ! -d "${WorkDir}" ]; then mkdir "${WorkDir}"; fi
		cd "${WorkDir}" || exit 1
		wget -c https://github.com/indilib/indi/archive/refs/tags/v"$Indi_v".tar.gz -O - | tar -xz -C "${WorkDir}"
		wget -c https://github.com/indilib/indi-3rdparty/archive/refs/tags/v"$Indi_v".tar.gz -O - | tar -xz -C "${WorkDir}"
		git clone https://github.com/rlancaste/stellarsolver.git

		# =================================================================
		# echo "# Install dependencies..."
		# #echo "${ask_pass}" | sudo -S apt-get -y install patchelf
		# #(($? != 0)) && zenity --width=${W} --error --text="Error installing PatchELF\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# echo "${ask_pass}" | sudo -S apt-get -y install build-essential cmake git libstellarsolver-dev libeigen3-dev libcfitsio-dev zlib1g-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev gsc gsc-data
		# (($? != 0)) && zenity --width=${W} --error --text="Error installing Kstars dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# echo "${ask_pass}" | sudo -S apt-get install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev
		# (($? != 0)) && zenity --error --width=${W} --text="Error installing INDI Core dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# echo "${ask_pass}" | sudo -S apt-get -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
		# (($? != 0)) && zenity --error --width=${W} --text="Error installing INDI Driver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# echo "${ask_pass}" | sudo -S apt -y install git cmake qt5-default libcfitsio-dev libgsl-dev wcslib-dev
		# (($? != 0)) && zenity --error --width=${W} --text="Error installing Stellarsolver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Checking INDI Core..."
		if [ ! -d "${WorkDir}"/indi-cmake ]; then mkdir -p "${WorkDir}"/indi-cmake; fi
		cd "${WorkDir}"/indi-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug "${WorkDir}"/indi-"$Indi_v"
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Instal</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================		
		#echo "# Fix Indi $Indi_v for ARM_64..."
		#cd "${WorkDir}"/indi-3rdparty-"$Indi_v" || exit 1
		#for f in $(find lib* -type f -name *bin | grep -E 'x64|64' | sed '/arm64/d' | xargs); do echo "=> Checking $f" ; patchelf --debug --print-soname $f; echo "------"; done

		# =================================================================
		echo "# Checking INDI 3rd Party Library"
		if [ ! -d "${WorkDir}"/indi3rdlib-cmake ]; then mkdir -p "${WorkDir}"/indi3rdlib-cmake; fi
		cd "${WorkDir}"/indi3rdlib-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug -DBUILD_LIBS=1 "${WorkDir}"/indi-3rdparty-"$Indi_v"
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Instal</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================		
		#echo "# Fix Indi $Indi_v for ARM_64..."
		#cd "${WorkDir}"/indi-3rdparty-"$Indi_v" || exit 1
		#for f in $(find lib* -type f -name *bin | grep -E 'x64|64' | sed '/arm64/d' | xargs); do echo "=> Checking $f" ; patchelf --debug --print-soname $f; echo "------"; done

		# =================================================================
		echo "# Check INDI 3rd Party Driver"
		if [ ! -d "${WorkDir}"/indi3rd-cmake ]; then mkdir -p "${WorkDir}"/indi3rd-cmake; fi
		cd "${WorkDir}"/indi3rd-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_FXLOAD=1 "${WorkDir}"/indi-3rdparty-"$Indi_v"
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> Instal INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Checking Stellarsolver"
		if [ ! -d "${WorkDir}"/stellarsolver-cmake ]; then mkdir -p "${WorkDir}"/stellarsolver-cmake; fi
		cd "${WorkDir}"/stellarsolver-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "${WorkDir}"/stellarsolver
		(($? != 0)) && zenity --error --width=${W} --text="Error CMake Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error Make Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error Make Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error Make Instal Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "${ask_pass}" | sudo -S rm -rf "${WorkDir}"

		# =================================================================
		echo "# All finished."
		zenity --info --text="INDI and Driver has been updated to version $Indi_v" --width=${W} --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
}

# Install / Update KStars AstroPi 
function chkKStars()
{
	(	
		echo "# Check KStars AstroPi"
		if [ ! -d "${WorkDir}"/kstars-cmake ]; then mkdir -p "${WorkDir}"/kstars-cmake; fi
		if [ ! -d "${HOME}"/.indi/logs ]; then mkdir -p "${HOME}"/.indi/logs; fi
		(($? != 0)) && zenity --error --width=${W} --text="Error MKdir <b>INDI log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		if [ ! -d "${HOME}"/.local/share/kstars/logs ]; then mkdir -p "${HOME}"/.local/share/kstars/logs; fi
		(($? != 0)) && zenity --error --width=${W} --text="Error MKdir <b>KStars log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		cd "${WorkDir}"/kstars-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "${appDir}"/kstars-astropi
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b>  KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && sudo rm -rf "${WorkDir}" && exit 1
	
		# =================================================================
		echo "# Install KStars AstroPi $KStars_v"
		make -j $JOBS
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		sudo make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Install</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		sudo rm -rf "${WorkDir}"

		# =================================================================
		echo "# All finished."
		zenity --info --width=${W} --text="KStars AstroPi $KStars_v allredy installed" --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width="${Wprogress}"
}
