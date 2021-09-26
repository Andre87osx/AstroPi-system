#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Bash variables
#=========================================================================

if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ]; then
	StatHotSpot=Disable
else
	StatHotSpot=Enable
fi

# Bash functios
#=========================================================================
chkARM64()
{
	sysinfo=$(uname -a)
	if [ -n "$(grep 'arm_64bit=1' '/boot/config.txt')" ]; then
		true
	else
		zenity --warning --width=$W --text="Your system is NOT 64 bit.\n$sysinfo\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v"
	fi
}

sysClean()
{
	(
		echo "# Remove unnecessary lib..."
		echo "$password" | sudo -S apt-get clean
		echo "# Cleaning GIT dir"
		if [ -d "$GitDir" ]; then
			echo "$password" | sudo -S chown -R "$USER":"$USER" "$GitDir"
			cd "$GitDir" || exit 1
			git repack -a -d
		fi
		echo "# Cleaning Project..."
		if [ -d "$WorkDir" ]; then echo "$password" | sudo -S rm -rf "$WorkDir"; fi
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>deleting .Projects dir</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

	) | zenity --progress --title="AstroPi System $AstroPi_v" --percentage=1 --pulsate --auto-close --auto-kill --width=$Wprogress
}

chkUsr()
{
	if [ "$(whoami)" = "root" ]; then
		# This function must be implemented v1.3/v1.4
		exit
	fi
}

sysUpgrade()
{
sources=/etc/apt/sources.list.d/astroberry.list
	(
		echo "# Preparing update"
		# Check APT Source
		if [ ! -f "$sources" ]; then
			echo "$password" | sudo -S chmod 775 /etc/apt/sources.list.d
			wget -O - https://www.astroberry.io/repo/key | sudo apt-key add -
			echo -e "deb https://www.astroberry.io/repo/ buster main" | sudo tee /etc/apt/sources.list.d/astroberry.list
			(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>sources.list.d</b>\n. Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		fi
		# Implement USB memory dump
		echo "$password" | sudo -S sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>usbfs_memory_mb.</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		# Hold some update
		echo "$password" | sudo -S apt-mark hold kstars-bleeding indi-full libindi-dev
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>hold kstars-bleeding</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		
		# =================================================================
		echo "# Run Software Updater..."
		# Run APT FULL upgrade
		echo "$password" | sudo -S apt-get update && sudo apt-get -y dist-upgrade && sudo apt -y full-upgrade
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating system AstroPi</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Remove unnecessary libraries"
		# Clean APT
		echo "$password" | sudo -S apt -y autoremove
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>APT autoremove</b>.\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Updating all AstroPi script"
		# Copy script from GIT to AstroPi
		echo "$password" | sudo -S cp "$GitDir"/Script/autohotspot.service /etc/systemd/system/autohotspot.service
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating AstroPi Hotspot.service</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S cp "$GitDir"/Script/autohotspot /usr/bin/autohotspot
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating AstroPi Hotspot script</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		# // This part is deprecated after v1.3
		if [ -f "$HOME"/'AstroPi system updater' ]; then
			echo "$password" | sudo -S rm -rf "$HOME"/'AstroPi system updater'
		fi
		if [ -f "$HOME"/.Update.sh ]; then
			echo "$password" | sudo -S rm -rf "$HOME"/.Update.sh
		fi
		######################################
		# Copy AstroPi icon and make executable
		echo "$password" | sudo -S cp "$GitDir"/Script/AstroPi.desktop /usr/share/applications/AstroPi.desktop
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating AstroPi Launcher</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S chmod +x /usr/share/applications/AstroPi.desktop
		# Copy .Update.sh and make executable
		echo "$password" | sudo -S cp "$GitDir"/Script/.Update.sh /usr/bin/.Update.sh
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating .Update.sh</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S chmod +x /usr/bin/.Update.sh
		# Set default wallpaper
		pcmanfm --set-wallpaper="$GitDir"/Loghi&background/AstroPi_wallpaper.png
		# Copy LX setting for start bar
		echo "$password" | sudo -S cp "$GitDir"/Script/panel "$HOME"/.config/lxpanel/LXDE-pi/panels/panel
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>editing lxpanels</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# All have done"
		zenity --info --width=$W --text="All updates have been successfully installed" --title="AstroPi System $AstroPi_v"

	) | zenity --progress --title="AstroPi System $AstroPi_v" --percentage=1 --pulsate --auto-close --auto-kill --width=$Wprogress
	
}

setupWiFi()
{
	# Setup WiFi in wpa_supplicant
	# =========================================================================

	WIFI=$(zenity --forms --width=400 --height=300 --title="Setup WiFi in wpa_supplicant" --text="Add new WiFi network" \
		--add-entry="Enter the SSID of the wifi network to be added." \
		--add-password="Enter the password of selected wifi network")
	SSID=$(echo "$WIFI" | cut -d'|' -f1)
	PSK=$(echo "$WIFI" | cut -d'|' -f2)
	
	case "$?" in
	0)	
		echo "$password" | sudo -S rm /etc/wpa_supplicant/wpa_supplicant.conf
		echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=IT\n\nnetwork={\n   ssid=\"$SSID\"\n   scan_ssid=1\n   psk=\"$PSK\"\n   key_mgmt=WPA-PSK\n}\n" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
		case $? in
		0)
			zenity --info --width=$W --text "New WiFi has been created, reboot AstroPi." --title="AstroPi System $AstroPi_v"
		;;
		1)
			zenity --error --width=$W --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		;;
		esac
	;;
	1)
		zenity --info --width=$W --text "No changes have been made to your current configuration" --title="AstroPi System $AstroPi_v"
	;;
	-1)
		zenity --error --width=$W --text="Error in wpa_supplicant write. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
	;;
	esac
}

chkHotspot()
{
	# Disable AstroPi auto hotspot
	# =========================================================================
	if [ "$StatHotSpot" == Disable ]; then
		echo "$password" | sudo -S systemctl disable autohotspot.service
		(($? != 0)) && zenity --error --width=$W --text="I couldn't disable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=$W --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"--title="AstroPi System $AstroPi_v" && exit 1
		zenity --info --width=$W --text "The auto hotspot service is now <b>disable</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi" --title="AstroPi System $AstroPi_v"
	else
	# Enable AstroPi auto hotspot
	# =========================================================================
		echo "$password" | sudo -S echo "nohook wpa_supplicant" >>/etc/dhcpcd.conf
		(($? != 0)) && zenity --error --width=$W --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S systemctl enable autohotspot.service
		(($? != 0)) && zenity --error --width=$W --text="I couldn't enable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		zenity --info --width=$W --text "The auto hotspot service is now <b>active</b>. Connect to AstroPi wifi and use VNC AstroPi hotspot connection" --title="AstroPi System $AstroPi_v"
	fi
}

chkINDI()
{
	(
		# =================================================================
		echo "# Install dependencies..."
		echo "$password" | sudo -S apt-get -y install build-essential cmake git libstellarsolver-dev libeigen3-dev libcfitsio-dev zlib1g-dev libindi-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev gsc gsc-data
		(($? != 0)) && zenity --width=$W --error --text="Error installing Kstars dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S apt-get install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev
		(($? != 0)) && zenity --error --width=$W --text="Error installing INDI Core dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S apt-get -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
		(($? != 0)) && zenity --error --width=$W --text="Error installing INDI Driver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S apt -y install git cmake qt5-default libcfitsio-dev libgsl-dev wcslib-dev
		(($? != 0)) && zenity --error --width=$W --text="Error installing Stellarsolver dependencies\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Checking INDI Core..."
		if [ ! -d "$WorkDir"/indi-cmake ]; then mkdir -p "$WorkDir"/indi-cmake; fi
		cd "$WorkDir" || exit
		wget -c https://github.com/indilib/indi/archive/refs/tags/v"$Indi_v".tar.gz -O - | tar -xz -C "$WorkDir"
		cd "$WorkDir"/indi-cmake || exit
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug "$WorkDir"/indi-"$Indi_v"
		(($? != 0)) && zenity --error --width=$W --text="Error <b>CMake</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		sleep 1s
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S make install
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Instal</b> INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Checking INDI 3rd Party Library"
		cd "$WorkDir" || exit
		wget -c https://github.com/indilib/indi-3rdparty/archive/refs/tags/v"$Indi_v".tar.gz -O - | tar -xz -C "$WorkDir"
		if [ ! -d "$WorkDir"/indi3rdlib-cmake ]; then mkdir -p "$WorkDir"/indi3rdlib-cmake; fi
		cd "$WorkDir"/indi3rdlib-cmake || exit
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug -DBUILD_LIBS=1 "$WorkDir"/indi-3rdparty-"$Indi_v"
		(($? != 0)) && zenity --error --width=$W --text="Error <b>CMake</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		sleep 1s
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S make install
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Instal</b> INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Check INDI 3rd Party Driver"
		if [ ! -d "$WorkDir"/indi3rd-cmake ]; then mkdir -p "$WorkDir"/indi3rd-cmake; fi
		cd "$WorkDir"/indi3rd-cmake || exit
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug "$WorkDir"/indi-3rdparty-"$Indi_v"
		(($? != 0)) && zenity --error --width=$W --text="Error <b>CMake</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		sleep 1s
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S make install
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> Instal INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Checking Stellarsolver"
		if [ ! -d "$WorkDir"/stellarsolver-cmake ]; then mkdir -p "$WorkDir"/stellarsolver-cmake; fi
		cd "$WorkDir" || exit
		git clone https://github.com/rlancaste/stellarsolver.git
		cd "$WorkDir"/stellarsolver-cmake || exit
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "$WorkDir"/stellarsolver
		(($? != 0)) && zenity --error --width=$W --text="Error CMake Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error Make Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		sleep 1s
		make -j 2
		(($? != 0)) && zenity --error --width=$W --text="Error Make Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "$password" | sudo -S make install
		(($? != 0)) && zenity --error --width=$W --text="Error Make Instal Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "$password" | sudo -S rm -rf "$WorkDir"

		# =================================================================
		echo "# All finished."
		zenity --info --text="INDI and Driver has been updated to version $Indi_v" --width=$W --title="AstroPi System $AstroPi_v"

	) | zenity --progress --title="AstroPi System $AstroPi_v" --percentage=1 --pulsate --auto-close --auto-kill --width=$Wprogress
}

chkKStars()
{
	(
		# =================================================================
		echo "# Check KStars AstroPi"
		if [ ! -d "$HOME"/.indi/logs ]; then mkdir -p "$HOME"/.indi/logs; fi
		(($? != 0)) && zenity --error --width=$W --text="Error <b>INDI log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		if [ ! -d "$HOME"/.local/share/kstars/logs ]; then mkdir -p "$HOME"/.local/share/kstars/logs; fi
		(($? != 0)) && zenity --error --width=$W --text="Error <b>KSTARS log dir</b>\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		if [ ! -d "$WorkDir"/kstars-cmake ]; then mkdir -p "$WorkDir"/kstars-cmake; fi
		cd "$WorkDir"/kstars-cmake || exit
		cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo "$GitDir"/kstars-astropi
		(($? != 0)) && zenity --error --width=$W --text="Error <b>CMake</b>  KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
	
		# =================================================================
		echo "# Install KStars AstroPi $KStars_v"
		make -j2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		sleep 1s
		make -j2
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Make</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "$password" | sudo -S make install
		(($? != 0)) && zenity --error --width=$W --text="Error <b>Install</b> KStars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1

		# =================================================================
		echo "# Removing the temporary files"
		echo "$password" | sudo -S rm -rf "$WorkDir"

		# =================================================================
		echo "# All finished."
		zenity --info --width=$W --text="KStars AstroPi $KStars_v allredy installed" --title="AstroPi System $AstroPi_v"

	) | zenity --progress --title="AstroPi System $AstroPi_v" --percentage=1 --pulsate --auto-close --auto-kill --width=$Wprogress

}

## Starting AstroPi GUI
#=========================================================================
ans=$(zenity --list --width=$W --height=$H --title="AstroPi System $AstroPi_v" --cancel-label=Exit --hide-header --text "Choose an option or exit" --radiolist --column "Pick" --column "Option" \
	FALSE "Setup my WiFi" \
	FALSE "$StatHotSpot AstroPi hotspot" \
	FALSE "Check for update" \
	FALSE "System Cleaning" \
	FALSE "Install INDI and Driver $Indi_v" \
	FALSE "Install KStars AstroPi $KStars_v")
    
	case $? in
	0)
		if [ "$ans" == "Check for update" ]; then
			sysUpgrade
			chkARM64
			lxpanelctl restart # Restart LX for able new change icon
	
		elif [ "$ans" == "Setup my WiFi" ]; then
			setupWiFi

		elif [ "$ans" == "$StatHotSpot AstroPi hotspot" ]; then
			chkHotspot

		elif [ "$ans" == "Install INDI and Driver $Indi_v" ]; then
			chkINDI

		elif [ "$ans" == "Install Kstars AstroPi $KStars_v" ]; then
			chkKStars

		elif [ "$ans" == "System Cleaning" ]; then
			sysClean

		fi
	;;
	1)
	exit 0
	;;
	-1)
	zenity --warning --width=$W --text="Something went wrong... Reload AstroPi System" --title="AstroPi System $AstroPi_v" && exit 1
	;;
	esac
