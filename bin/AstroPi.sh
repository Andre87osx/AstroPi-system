#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# rev 1.6 april 2022
# Run this script as USER
# Type in console bash 'AstroPi'
# This script have GUI powered by zenity lib

# Import common array and functions
appDir=${HOME}/.local/share/astropi
if [ -f ${appDir}/include/functions.sh ] && [ -f ${appDir}/include/array.sh ]; then
	source ${appDir}/include/functions.sh
	source ${appDir}/include/array.sh
else
	zenity --error --width=300 --text="Something went wrong...
	AstroPi System is not correctly installed" --title="AstroPi-System"
	exit 1
fi

# Ask super user password.
ask_pass

# Chk USER and create path
chkUser

########################## Starting AstroPi GUI ##########################
# Powered with zenity lib. See https://help.gnome.org/users/zenity/stable/

# AdminSystem windows >>>>
function AdminSystem() {
	# Define if hotspot is active or disabled
	if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ]; then
		StatHotSpot=Disable		# Hotspot is active
	else
		StatHotSpot=Enable		# Hotspot is disabled
	fi
	textS="<big><b>Admin ${W_Title}</b></big>\n(C) 2022 - AstroPi Team
	\n<b>${sysinfo}</b>
	\n<b>Storage details:</b>
	Main disk used at ${diskUsagePerc} Free disk space  ${diskUsageFree}"

	ansS=$( zenity --list --width=${W} --height=${H} --title="${W_Title}" --cancel-label=Main --hide-header --text "${textS}" --radiolist --column "Pick" --column "Option" --column "Details" \
		FALSE "$StatHotSpot AstroPi hotspot	" "=> On / Off WiFi Hotspot for use AstroPi outdoor" \
		FALSE "Setup my WiFi	" "=> Add new WiFi SSID connection" \
		FALSE "System Cleaning	" "=> Delete unused library and script and temp file" \
		FALSE "Check for System update	" "=> Update Linux AstroPi and chek for new System version" \
		FALSE "System Backup	" "=> Perform complete AstroPi backup in single compressed file" )	
    
	case $? in
	0)
		if [ "$ansS" == "Check for System update	" ]; then
			connection=$( wget -q --spider https://github.com/Andre87osx/AstroPi-system )
			updateSH=( https://raw.githubusercontent.com/Andre87osx/AstroPi-system/main/bin/update.sh )
			if ${connection}; then
				( curl ${updateSH} > update.sh ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
				zenity --progress --title="Downloading..." --pulsate --auto-close --auto-kill --width=420
				bash update.sh&
				exit 0
			else
			fi
	
		elif [ "$ansS" == "Setup my WiFi	" ]; then
			setupWiFi

		elif [ "$ansS" == "$StatHotSpot AstroPi hotspot	" ]; then
			chkHotspot

		elif [ "$ansS" == "System Cleaning	" ]; then
			sysClean

		elif [ "$ansS" == "System Backup	" ]; then
			# do somethings
		fi
	;;
	1)
	return 0
	;;
	-1)
	zenity --warning --width=${W} --text="Something went wrong... Reload AstroPi System" --title="${W_Title}" && exit 1
	;;
	esac
}
# AdminSystem windows <<<<

# AdminSystem KStars >>>>
function AdminKStars() {
kstarsV=$(kstars -v)
indiV=$(indiserver -v)
textK="<big><b>KStars ${W_Title}</b></big>\n(C) 2022 - AstroPi Team
\n<b>KStars AsroPi installed version</b>
${kstarsV}
\n<b>INDI Core installed version</b>
${indiV}"

ansK=$( zenity --list --width=${W} --height=${H} --title="${W_Title}" --cancel-label=Main --hide-header --text "${textK}" --radiolist --column "Pick" --column "Option" --column "Details" \
	FALSE "Update INDI and Driver $Indi_v	" "=> Update INDI core and Driver" \
	FALSE "Update KStars AstroPi $KStars_v	" "=> Update KStars AstroPi" \
	FALSE "Check GSC and Index	" "=> Check GSC catalog and Index for astrometry" \
	FALSE "Backup/Restore KStars	" "=> Make a backup or restore all KStars and INDI data" )	
    
	case $? in
	0)
		if [ "$ansK" = "Update INDI and Driver $Indi_v	" ]; then
			chkINDI

		elif [ "$ansK" = "Update KStars AstroPi $KStars_v	" ]; then
			chkKStars

		elif [ "$ansK" = "Check GSC and Index	" ]; then
			chkIndexGsc
		fi
	;;
	1)
	return 0
	;;
	-1)
	zenity --warning --width=${W} --text="Something went wrong... Reload AstroPi System" --title="${W_Title}" && exit 1
	;;
	esac
}
# AdminSystem KStars <<<<

# Main windows >>>>
rc=1 # OK button return code =0 , all others =1
textM="<big><b>Wellcome to ${W_Title}</b></big>\n(C) 2022 - AstroPi Team
\n<b>Admin System</b>
Find all the functions to administer Linux AstroPi; system updates, backups and network management
\n<b>Admin KStars</b>
Dedicated functions to administer KStars AstroPi; KStars and INDI updates, KStars backups, and devices management
\n<b>Extra</b>
Find out the guide for the System and Kstars and many more tricks"

while [ ${rc} -eq 1 ]; do
	ans=$(zenity --info --icon-name="solar-system-dark" --title="${W_Title}" --width=${W} --height=${H} \
		--text="${textM}" \
		--ok-label Quit \
		--extra-button AdminSystem \
		--extra-button AdminKStars \
		--extra-button Extra \
	)
	rc=$?
	echo "You have chosen to run:"
	echo ${ans}
	if [[ ${ans} == "AdminSystem" ]]
	then
		echo "Loading AdminSystem"
		AdminSystem
	elif [[ ${ans} == "AdminKStars" ]]
	then
		AdminKStars
		echo "Loading AdminKStars"
	elif [[ ${ans} == "Extra" ]]
	then
		Extra
		echo "Loading Extra"
	elif [[ ${rc} -eq 0 ]]
	then
		echo "Quit AstroPi System"
		exit 0
	fi
done
# Main windows <<<<