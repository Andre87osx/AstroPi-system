#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# Run this script as USER
# Type in console bash $HOME/.local/share/astropi/astropi.sh
# This script have GUI, is not performed for console

# Import common array and functions
source ${HOME}/.local/share/astropi/include/functions.sh

# Ask super user password.
ask_pass

# Chk USER and create path
chkUser

# Define if hotspot is active or disabled
if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ]; then
	StatHotSpot=Disable		# Hotspot is active
else
	StatHotSpot=Enable		# Hotspot is disabled
fi

# Define path bash script
Script_Dir="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" >/dev/null 2>&1 && pwd )"

## Starting AstroPi GUI
#=========================================================================
ans=$( zenity --list --width=${W} --height=$H --title="${W_Title}" --cancel-label=Exit --hide-header --text "Choose an option or exit" --radiolist --column "Pick" --column "Option" \
	FALSE "Setup my WiFi" \
	FALSE "$StatHotSpot AstroPi hotspot" \
	FALSE " " \
	FALSE "System Cleaning" \
	FALSE "Check for update" \
	FALSE "Update INDI and Driver $Indi_v" \
	FALSE "Update KStars AstroPi $KStars_v" \
	FALSE "Check GSC and Index" )	
    
	case $? in
	0)
		if [ "$ans" == "Check for update" ]; then
			sysUpgrade
			chksysHotSpot
			chkARM64
			lxpanelctl restart # Restart LX for able new change icon
	
		elif [ "$ans" == "Setup my WiFi" ]; then
			setupWiFi

		elif [ "$ans" == "$StatHotSpot AstroPi hotspot" ]; then
			chkHotspot

		elif [ "$ans" == "Update INDI and Driver $Indi_v" ]; then
			chkINDI

		elif [ "$ans" == "Update KStars AstroPi $KStars_v" ]; then
			chkKStars
		
		elif [ "$ans" == "Check GSC and Index" ]; then
			chkIndexGsc

		elif [ "$ans" == "System Cleaning" ]; then
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
