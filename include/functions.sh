#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########
# rev 1.6 april 2022

# Create next AstoPi versions
function next_v()
{
	#//FIXME
	next_AstroPi_v=("${AstroPi_v%.*}.$((${AstroPi_v##*.}+1))")
}

# Ask super user password.
function ask_pass()
{
	# Ask for the password only if the array "ask_pass" is empty. 
	# Otherwise check only if the password is correct
	if (( ${#ask_pass[@]} != 0 )); then
    	if [ ${ask_pass} ]; then
			# Check the user password stored
			until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
				zenity --warning --text="<b>WARNING! User password is wrong...</b>
				\nTry again or sign out" --width=${W} --title="${W_Title}"
				if ask_pass=$( zenity --password  --width=${W} --title="${W_Title}" ); then break; else exit 0; fi
			done
		fi
	else
		ask_pass=$( zenity --password --title="${W_Title}" )
		if [ ${ask_pass} ]; then
			# User write password and press OK
			# Makes sure that the sudo user password matches
			until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
				zenity --warning --text="<b>WARNING! User password is wrong...</b>
				\nTry again or sign out" --width=${W} --title="${W_Title}"
				if ask_pass=$( zenity --password  --width=${W} --title="${W_Title}" ); then break; else exit 0; fi
			done
		else
			# User press CANCEL button
			# Quit script
			exit 0
		fi
	fi
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
	else
		appDir=${HOME}/.local/share/astropi		# Defaul application path
		WorkDir=${HOME}/.Projects				# Working path for cmake
		echo "Wellcome to AstroPi System"
		echo "=========================="
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
			echo "${askP}" | sudo -S mv /usr/share/gsc /usr/share/GSC
			echo "${ask_pass}" | sudo -S rm -r /usr/share/GSC/bin-dos
			echo "${ask_pass}" | sudo -S rm -r /usr/share/GSC/src
			echo "${ask_pass}" | sudo -S rm /usr/share/GSC/bincats_GSC_1.2.tar.gz
			echo "${ask_pass}" | sudo -S rm /usr/share/GSC/bin/gsc.exe
			echo "${ask_pass}" | sudo -S rm /usr/share/GSC/bin/decode.exe
			echo "${ask_pass}" | sudo -S rm -r "${HOME}"/gsc
			if [ -z "$(grep 'export GSCDAT' /etc/profile)" ]; then
				cp /etc/profile /etc/profile.copy
				echo "export GSCDAT=/usr/share/GSC" >> /etc/profile
			fi
		else
			zenity --info --width=${W} --text="<b>GSC allredy exist.</b>
			\nFor issue contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		fi
	
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>Install GSC.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Check Astrometry Index for solving
function chkIndexAstro()
{
	IndexPath="${HOME}"/.local/share/kstars/astrometry
	WrongPath=/usr/local/share/astrometry
	echo "Check old Index installations..."	
	if [ -f "${WrongPath}"/*.fits ]; then
		echo "Move Index files to correct path"
		cd /usr/local/share/astrometry || exit 1
		echo "${ask_pass}" | sudo -S mv *.fits "${IndexPath}"
		echo "${ask_pass}" | sudo -S chown -R "${USER}":"${USER}" "${IndexPath}"
	fi
	echo "Check all Index, if missing download it..."
	if ${appDir}/script/astrometry.sh; then
		true
	else
		zenity --error --width=${W} --text="Something went wrong in <b>Install Index Astrometry.</b>
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
		zenity --warning --width=${W} --text="Your system is NOT 64 bit.
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
		echo "${ask_pass}" | sudo -S systemctl unmask hostapd.service >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files hostapd.service | grep "hostapd.service enabled" >/dev/null 2>&1 ;then
		echo "${ask_pass}" | sudo -S systemctl disable hostapd.service >/dev/null 2>&1
		echo "${ask_pass}" | sudo -S systemctl stop hostapd >/dev/null 2>&1
	fi
	# Check dnsmasq is disabled
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service masked" >/dev/null 2>&1 ;then
		echo "${ask_pass}" | sudo -S systemctl unmask dnsmasq >/dev/null 2>&1
	fi
	if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service enabled" >/dev/null 2>&1 ;then
		echo "${ask_pass}" | sudo -S systemctl disable dnsmasq >/dev/null 2>&1
		echo "${ask_pass}" | sudo -S systemctl stop dnsmasq >/dev/null 2>&1
	fi
}

# Cleanup the system
function sysClean()
{
	(
		echo "# Remove unnecessary lib..."
		echo "${ask_pass}" | sudo -S apt-get clean
		echo "# Delete old AstroPi version"
		if [ -d "${GitDir}" ]; then
			echo "${ask_pass}" | sudo -S rm -rf "${GitDir}"
		fi
		echo "# Cleaning CMake Project..."
		if [ -d "${WorkDir}" ]; then 
			echo "${ask_pass}" | sudo -S rm -rf "${WorkDir}"
		fi
		zenity --info --width=${W} --text="Cleaning was done correctly" --title="${W_Title}"
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
		# Check APT Source stops unwanted updates
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f "${sources}" ]; then
			echo "${ask_pass}" | sudo -S chmod 777 "${sources}"
			echo -e "# deb https://www.astroberry.io/repo/ buster main" | sudo tee "${sources}"
			(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>sources.list.d</b>
			\n.Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
			echo "${ask_pass}" | sudo -S chmod 644 "${sources}"
		fi
	(
		echo "# Preparing update"
		# Implement USB memory dump
		echo "${ask_pass}" | sudo -S sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		
		# Hold some update
		echo "${ask_pass}" | sudo -S apt-mark hold kstars-bleeding kstars-bleeding-data zenity \
		indi-full libindi-dev libindi1 indi-bin
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>hold some application</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		
		echo "# Run Linux AstroPi full upgrade..."
		# Run APT FULL upgrade
		echo "${ask_pass}" | sudo -S apt update && echo "${ask_pass}" | sudo -S apt -y full-upgrade
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>Updating system AstroPi</b>
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
			echo "${ask_pass}" | sudo -S chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
			echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=IT\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$PRIORITY\"\n   key_mgmt=WPA-PSK\n}\n" | tee /etc/wpa_supplicant/wpa_supplicant.conf
			case $? in
			0)
				zenity --info --width=${W} --text "New WiFi has been added, reboot AstroPi." --title="${W_Title}"
				echo "${ask_pass}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			1)
				zenity --error --width=${W} --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
				echo "${ask_pass}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			esac
		else
			echo "${ask_pass}" | sudo -S chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf
			echo "\n\nnetwork={\n   ssid=\"$SSID\"\n   psk=\"$PSK\"\n   scan_ssid=1\n   priority=\"$((PRIORITY--))\"\n   key_mgmt=WPA-PSK\n}\n" | tee -a /etc/wpa_supplicant/wpa_supplicant.conf
			case $? in
			0)
				zenity --info --width=${W} --text "New WiFi has been added, reboot AstroPi." --title="${W_Title}"
				echo "${ask_pass}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
			;;
			1)
				zenity --error --width=${W} --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
				echo "${ask_pass}" | sudo -S chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
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
		echo "${ask_pass}" | sudo -S systemctl disable autohotspot.service
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't disable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"--title="${W_Title}" && exit 1
		zenity --info --width=${W} --text "The auto hotspot service is now <b>disable</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi" --title="${W_Title}"
	else
	# Enable AstroPi auto hotspot
	# =========================================================================
		echo "${ask_pass}" | sudo -S echo "nohook wpa_supplicant" >>/etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=${W} --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		echo "${ask_pass}" | sudo -S systemctl enable autohotspot.service
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
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>CMake</b>  KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	
		# =================================================================
		echo "# Install KStars AstroPi $KStars_v"
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		make -j2
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "${ask_pass}" | sudo -S make install
		(($? != 0)) && zenity --error --width=${W} --text="Error <b>Install</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "${ask_pass}" | sudo -S rm -rf "${WorkDir}"

		# =================================================================
		echo "# All finished."
		zenity --info --width=${W} --text="KStars AstroPi $KStars_v allredy installed" --title="${W_Title}"

	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width="${Wprogress}"
}
