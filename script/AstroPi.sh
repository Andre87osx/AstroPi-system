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
if [ -f ${HOME}/.local/share/astropi/include/functions.sh ]; then
	source ${HOME}/.local/share/astropi/include/functions.sh
else
	zenity --warning --width=300 --text="Something went wrong...
	AstroPi System is not correctly installed" --title="AstroPi-System" && exit 1
fi

# Chk USER and create path
chkUser

# Define if hotspot is active or disabled
if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ]; then
	StatHotSpot=Disable		# Hotspot is active
else
	StatHotSpot=Enable		# Hotspot is disabled
fi

########################## Starting AstroPi GUI ##########################
# Powered with zenity lib. See https://help.gnome.org/users/zenity/stable/

function AdminSystem() {
	rc=1 # OK button return code =0 , all others =1
	text="<big><b>Admin ${W_Title}</b></big>\n(C) 2022 - AstroPi Team
	\n<b>Admin System</b>
	\nFind all the functions to administer Linux AstroPi; system updates, backups and network management
	\n<b>Admin KStars</b>
	\nDedicated functions to administer KStars AstroPi; KStars and INDI updates, KStars backups, and peripheral management
	\n<b>Extra</b>
	\nFind out the guide for the System and Kstars and many more tricks"

	while [ ${rc} -eq 1 ]; do
		ans=$(zenity --info --icon-name="solar-system" --title="${W_Title}" --width=${W} --height=${H} \
			--text="${text}" \
			--ok-label Quit \
			--extra-button UpdateSystem \
			--extra-button CleaningUp \
			--extra-button $StatHotSpot AstroPi hotspot \
		)
		rc=$?
		echo "You have chosen to run:"
		echo ${ans}
		if [[ ${ans} = "AdminSystem" ]]
		then
			echo "Running the Rover"
		elif [[ ${ans} = "AdminKStars" ]]
		then
			echo "Stopping the Rover"
		elif [[ ${ans} = "Extra" ]]
		then
			echo "Rover turning Left"
		fi
	done
}
# Main windows >>>>
rc=1 # OK button return code =0 , all others =1
text="<big><b>Wellcome to ${W_Title}</b></big>\n(C) 2022 - AstroPi Team
\n<b>Admin System</b>
Find all the functions to administer Linux AstroPi; system updates, backups and network management
\n<b>Admin KStars</b>
Dedicated functions to administer KStars AstroPi; KStars and INDI updates, KStars backups, and peripheral management
\n<b>Extra</b>
Find out the guide for the System and Kstars and many more tricks"

while [ ${rc} -eq 1 ]; do
	ans=$(zenity --info --icon-name="solar-system" --title="${W_Title}" --width=${W} --height=${H} \
		--text="${text}" \
		--ok-label Quit \
		--extra-button AdminSystem \
		--extra-button AdminKStars \
		--extra-button Extra \
	)
	rc=$?
	echo "You have chosen to run:"
	echo ${ans}
	if [[ ${ans} = "AdminSystem" ]]
	then
		echo "Running the Rover"
		AdminSystem
	elif [[ ${ans} = "AdminKStars" ]]
	then
		echo "Stopping the Rover"
	elif [[ ${ans} = "Extra" ]]
	then
		echo "Rover turning Left"
	elif [[ ${rc} -eq 0 ]]
	then
		echo "Quit AstroPi System"
		exit 0
	fi
done
# Main windows <<<<



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
