#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Define if hotspot is active or disabled
if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ]; then
	StatHotSpot=Disable		# Hotspot is active
else
	StatHotSpot=Enable		# Hotspot is disabled
fi

# Define path bash script
Script_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Check if you run the script as USER
function chkWhoami()
{
	if [[ -z ${USER} ]] && [[ ${USER} != root ]]; then
		zenity --error --text="<b>Run this script as USER not as root</b>\n
		Error in AstroPi System" --width=${W} --title="${W_Title}"
		exit 1
	fi
}

# Check if GSC
function chkIndexGsc()
{
	(
		echo "# Check GSC catalog for Simulaor"
		if [ ! -d /usr/share/GSC ]; then
			mkdir -p "${HOME}"/gsc | cd "${HOME}"/gsc
			if [ ! -f "${HOME}"/gsc/bincats_GSC_1.2.tar.gz ]; then
				echo "# Download GSC catalog for Simulaor"
				wget -O bincats_GSC_1.2.tar.gz http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/tar.gz?bincats/GSC_1.2 2>&1 | 
				sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | zenity \
				--progress --title="Downloading GSC..." --pulsate --auto-close --auto-kill --width=${Wprogress}
			fi
			echo "# Install GSC catalog for Simulaor"
			tar -xvzf bincats_GSC_1.2.tar.gz
			cd "${HOME}"/gsc/src || exit 1
			make -j $(expr $(nproc) + 2)
			mv gsc.exe gsc
			echo "${password}" | sudo -S cp gsc /usr/bin/
			cp -r ${HOME}/gsc /usr/share/
			echo "${password}" | sudo -S mv /usr/share/gsc /usr/share/GSC
			echo "${password}" | sudo -S rm -r /usr/share/GSC/bin-dos
			echo "${password}" | sudo -S rm -r /usr/share/GSC/src
			echo "${password}" | sudo -S rm /usr/share/GSC/bincats_GSC_1.2.tar.gz
			echo "${password}" | sudo -S rm /usr/share/GSC/bin/gsc.exe
			echo "${password}" | sudo -S rm /usr/share/GSC/bin/decode.exe
			echo "${password}" | sudo -S rm -r "${HOME}"/gsc
			if [ -z "$(grep 'export GSCDAT' /etc/profile)" ]; then
				cp /etc/profile /etc/profile.copy
				echo "export GSCDAT=/usr/share/GSC" >> /etc/profile
			fi
		else
			zenity --info --width=${W} --text="<b>GSC allredy exist.</b>
			For issue contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		fi
	
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>Install GSC.</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Check Astrometry Index for solving
function chkIndexAstro()
{
	IndexPath "${HOME}"/.local/share/kstars/astrometry
	WrongPath=/usr/local/share/astrometry/*.fits
	echo "Check old Index installations..."	
	if [ -f "${WrongPath}" ]; then
		echo "Move Index files to correct path"
		cd /usr/local/share/astrometry || exit 1
		echo "${password}" | sudo -S mv *.fits "${IndexPath}"
		echo "${password}" | sudo -S chown -R "${USER}":"${USER}" "${IndexPath}"
	fi
	echo "Check all Index, if missing download it..."
	if ${GitDir}/Script/astrometry.sh; then
		true
	else
		zenity --error --width=${W} --text="Something went wrong in <b>Install Index Astrometry.</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Check if system work on 64bit kernel
function chkARM64()
{
	sysinfo=$(uname -a)
	if [ -n "$(grep 'arm_64bit=1' '/boot/config.txt')" ]; then
		# Do not force automatic switching to 64bit. Warn only 
		true
	else
		zenity --warning --width=${W} --text="Your system is NOT 64 bit.\n
		$sysinfo\n
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
	fi
}

# Check if Hotspot service works fine
function chksysHotSpot()
{
	# After some system updates hostapd gets masked using Raspbian Buster, and above. This checks and fixes  
	# the issue and also checks dnsmasq is ok so the hotspot can be generated.
	# Check Hostapd is unmasked and disabled
	if systemctl -all list-unit-files hostapd.service | grep "hostapd.service masked" >/dev/null 2>&1 ;then
		echo "${password}" | sudo -S systemctl unmask hostapd.service >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files hostapd.service | grep "hostapd.service enabled" >/dev/null 2>&1 ;then
		echo "${password}" | sudo -S systemctl disable hostapd.service >/dev/null 2>&1
		echo "${password}" | sudo -S systemctl stop hostapd >/dev/null 2>&1
	fi
	# Check dnsmasq is disabled
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service masked" >/dev/null 2>&1 ;then
		echo "${password}" | sudo -S systemctl unmask dnsmasq >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service enabled" >/dev/null 2>&1 ;then
		echo "${password}" | sudo -S systemctl disable dnsmasq >/dev/null 2>&1
		echo "${password}" | sudo -S systemctl stop dnsmasq >/dev/null 2>&1
	fi
}

# Cleanup the system
function sysClean()
{
	(
		echo "# Remove unnecessary lib..."
		echo "${password}" | sudo -S apt-get clean
		echo "# Cleaning GIT dir"
		if [ -d "${GitDir}" ]; then
			echo "${password}" | sudo -S chown -R "${USER}":"${USER}" "${GitDir}"
			cd "${GitDir}" || exit
			if ! [ git repack -a -d ]; then
				zenity --error --width=${W} --text="${W_err_generic}" --title="${W_Title}"
				exit 1
			fi
		fi
		echo "# Cleaning Project..."
		if [ -d "${WorkDir}" ]; then 
			echo "${password}" | sudo -S rm -rf "${WorkDir}"
		fi
		zenity --info --width=${W} --text="The cleaning was done correctly" --title="${W_Title}"
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>System Cleanup</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Update RaspberryPi OS, library, app and AstroPi System
function sysUpgrade()
{
sources=/etc/apt/sources.list.d/astroberry.list
	(
		echo "# Preparing update"
		# Check APT Source stops unwanted updates
		if [ -f "$sources" ]; then
			echo "${password}" | sudo -S chmod 777 /etc/apt/sources.list.d/astroberry.list
			echo -e "# deb https://www.astroberry.io/repo/ buster main" | sudo tee /etc/apt/sources.list.d/astroberry.list
			(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>sources.list.d</b>
			\n. Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
			echo "${password}" | sudo -S chmod 644 /etc/apt/sources.list.d/astroberry.list
		fi
		# Implement USB memory dump
		echo "${password}" | sudo -S sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# Hold some update
		echo "${password}" | sudo -S apt-mark hold kstars-bleeding kstars-bleeding-data
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>hold kstars-bleeding</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S apt-mark hold indi-full libindi-dev libindi1 indi-bin
		
		# =================================================================
		echo "# Run Software Updater..."
		# Run APT FULL upgrade
		echo "${password}" | sudo -S apt update && echo "${password}" | sudo -S apt -y full-upgrade
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating system AstroPi</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Updating all AstroPi script"
		# Copy script from GIT to AstroPi
		echo "${password}" | sudo -S cp "${GitDir}"/Script/autohotspot.service /etc/systemd/system/autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating AstroPi Hotspot.service</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S cp "${GitDir}"/Script/autohotspot /usr/bin/autohotspot
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating AstroPi Hotspot script</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		# // This part is deprecated after v1.3
		if [ -f "${HOME}"/'AstroPi system updater' ]; then
			echo "${password}" | sudo -S rm -rf "${HOME}"/'AstroPi system updater'
		fi
		if [ -f "${HOME}"/.Update.sh ]; then
			echo "${password}" | sudo -S rm -rf "${HOME}"/.Update.sh
		fi
		# =================================================================
		# Copy AstroPi launcher and make executable
		echo "${password}" | sudo -S cp "${GitDir}"/Script/AstroPi.desktop /usr/share/applications/AstroPi.desktop
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating AstroPi Launcher</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S chmod +x /usr/share/applications/AstroPi.desktop
		# Copy .Update.sh and make executable
		echo "${password}" | sudo -S cp "${GitDir}"/Script/.Update.sh /usr/bin/.Update.sh
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating .Update.sh</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S chmod +x /usr/bin/.Update.sh
		# Copy kstars.sh and make executable
		echo "${password}" | sudo -S cp "${GitDir}"/Script/kstars.sh /usr/bin/kstars.sh
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating kstars.sh</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S chmod +x /usr/bin/kstars.sh
		# Copy parking.py and make executable
		echo "${password}" | sudo -S cp "${GitDir}"/Script/parking.py /usr/bin/.Update.sh
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating parking.py</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S chmod +x /usr/bin/parking.py
		# Set default wallpaper
		pcmanfm --set-wallpaper="${GitDir}/icons/AstroPi_wallpaper.png"
		# Copy LX setting for task bar
		echo "${password}" | sudo -S cp "${GitDir}"/Script/panel "${HOME}"/.config/lxpanel/LXDE-pi/panels/panel
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>editing lxpanels</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# All have done"
		zenity --info --width=${W} --text="All updates have been successfully installed" --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
			zenity --error --width=${W} --text="Something went wrong in <b>System Update</b>
			Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
			exit 1
		else
			exit 0
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
			echo "${password}" | sudo -S chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
			echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=IT\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$PRIORITY\"\n   key_mgmt=WPA-PSK\n}\n" | tee /etc/wpa_supplicant/wpa_supplicant.conf
			case $? in
			0)
				zenity --info --width=${W} --text "New WiFi has been added, reboot AstroPi." --title="${W_Title}"
				echo "${password}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			1)
				zenity --error --width=${W} --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
				echo "${password}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			esac
		else
			echo "${password}" | sudo -S chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
			echo "\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$((PRIORITY--))\"\n   key_mgmt=WPA-PSK\n}\n" | tee -a /etc/wpa_supplicant/wpa_supplicant.conf
			case $? in
			0)
				zenity --info --width=${W} --text "New WiFi has been added, reboot AstroPi." --title="${W_Title}"
				echo "${password}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			1)
				zenity --error --width=${W} --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
				echo "${password}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			esac	
		fi
	;;
	1)
		zenity --info --width=${W} --text "No changes have been made to your current configuration" --title="${W_Title}"
	;;
	-1)
		zenity --error --width=${W} --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	;;
	esac
}

# Enable / Disable HotSpot services
function chkHotspot()
{
	# Disable AstroPi auto hotspot
	# =========================================================================
	if [ "$StatHotSpot" == Disable ]; then
		echo "${password}" | sudo -S systemctl disable autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't disable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"--title="${W_Title}" && exit 1
		zenity --info --width=${W} --text "The auto hotspot service is now <b>disable</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi" --title="${W_Title}"
	else
	# Enable AstroPi auto hotspot
	# =========================================================================
		echo "${password}" | sudo -S echo "nohook wpa_supplicant" >>/etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S systemctl enable autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		zenity --info --width=${W} --text "The auto hotspot service is now <b>active</b>. Connect to AstroPi wifi and use VNC AstroPi hotspot connection" --title="${W_Title}"
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
		echo "# Install dependencies..."
		#echo "${password}" | sudo -S apt-get -y install patchelf
		#(($? != 0)) && zenity --width=${W} --error --text="Error installing PatchELF\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S apt-get -y install build-essential cmake git libstellarsolver-dev libeigen3-dev libcfitsio-dev zlib1g-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev gsc gsc-data
		(($? != 0)) && zenity --width=${W} --error --text="Error installing Kstars dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S apt-get install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev
		(($? != 0)) && zenity --error --width=${W} --text="Error installing INDI Core dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S apt-get -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
		(($? != 0)) && zenity --error --width=${W} --text="Error installing INDI Driver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${password}" | sudo -S apt -y install git cmake qt5-default libcfitsio-dev libgsl-dev wcslib-dev
		(($? != 0)) && zenity --error --width=${W} --text="Error installing Stellarsolver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

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
		echo "${password}" | sudo -S make install
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
		echo "${password}" | sudo -S make install
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
		echo "${password}" | sudo -S make install
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
		echo "${password}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error Make Instal Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "${password}" | sudo -S rm -rf "${WorkDir}"

		# =================================================================
		echo "# All finished."
		zenity --info --text="INDI and Driver has been updated to version $Indi_v" --width=${W} --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
}

# Install / Update KStars AstroPi 
function chkKStars()
{
	(
		echo "# Download KStars $KStars_v from AstroPi GIT..."
		if [ ! -d "${WorkDir}"/kstars-cmake ]; then mkdir -p "${WorkDir}"/kstars-cmake; fi
		cd "${WorkDir}" || exit 1
		wget -c https://github.com/Andre87osx/AstroPi-system/archive/refs/tags/v"$AstroPi_v".tar.gz -O - | tar -xz -C "${WorkDir}"
		
		# =================================================================
		echo "# Check KStars AstroPi"
		if [ ! -d "${HOME}"/.indi/logs ]; then mkdir -p "${HOME}"/.indi/logs; fi
		(($? != 0)) && zenity --error --width=${W} --text="Error MKdir <b>INDI log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		if [ ! -d "${HOME}"/.local/share/kstars/logs ]; then mkdir -p "${HOME}"/.local/share/kstars/logs; fi
		(($? != 0)) && zenity --error --width=${W} --text="Error MKdir <b>KStars log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		cd "${WorkDir}"/kstars-cmake || exit 1
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "${WorkDir}"/AstroPi-system-"$AstroPi_v"/kstars-astropi
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b>  KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	
		# =================================================================
		echo "# Install KStars AstroPi $KStars_v"
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "${password}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Install</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "${password}" | sudo -S rm -rf "${WorkDir}"

		# =================================================================
		echo "# All finished."
		zenity --info --width=${W} --text="KStars AstroPi $KStars_v allredy installed" --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width="${Wprogress}"
}

## Starting AstroPi GUI
#=========================================================================
ans=$(zenity --list --width=${W} --height=$H --title="${W_Title}" --cancel-label=Exit --hide-header --text "Choose an option or exit" --radiolist --column "Pick" --column "Option" \
	FALSE "Setup my WiFi" \
	FALSE "$StatHotSpot AstroPi hotspot" \
	FALSE " " \
	FALSE "System Cleaning" \
	FALSE "Check for update" \
	FALSE "Install INDI and Driver $Indi_v" \
	FALSE "Install KStars AstroPi $KStars_v" \
	FALSE "Install GSC and Index" )	
    
	case $? in
	0)
		if [ "$ans" == "Check for update" ]; then
			chkWhoami
			sysUpgrade
			chksysHotSpot
			chkARM64
			lxpanelctl restart # Restart LX for able new change icon
	
		elif [ "$ans" == "Setup my WiFi" ]; then
			chkWhoami
			setupWiFi

		elif [ "$ans" == "$StatHotSpot AstroPi hotspot" ]; then
			chkWhoami
			chkHotspot

		elif [ "$ans" == "Install INDI and Driver $Indi_v" ]; then
			chkWhoami
			chkINDI

		elif [ "$ans" == "Install KStars AstroPi $KStars_v" ]; then
			chkWhoami
			chkKStars
		
		elif [ "$ans" == "Install GSC and Index" ]; then
			chkWhoami
			chkIndexGsc

		elif [ "$ans" == "System Cleaning" ]; then
			chkWhoami
			sysClean
		fi
	;;
	1)
	exit 0
	;;
	-1)
	zenity --warning --width=${W} --text="Something went wrong... Reload AstroPi System" --title="${W_Title}" && exit 1
	;;
	esac
