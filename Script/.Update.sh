#!/bin/bash                                              
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Variables
#=========================================================================
AstroPi_v=1.5		# Actual stable version
KStars_v=3.5.4v1.5	# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.1		# Based on INDI 1.9.1 Core
#=========================================================================

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at\nhttps://github.com/Andre87osx/AstroPi-system/issues"

# Chk USER and create path
if [[ -z ${USER} ]] && [[ ${USER} != root ]];
then
	zenity --error --text="<b>Run this script as USER not as root</b>\n\nError in AstroPi System" --width=${W} --title="${W_Title}"
	exit 1
else
	GitDir="${HOME}"/.AstroPi-system	# Deprecated after v1.5
	WorkDir="${HOME}"/.Projects
	AppDir="${HOME}"/.local/share/astropi
fi

# Sudo password request.
password=$(zenity --password  --width=${W} --title="${W_Title}")
exit_stat=$?
if [ ${exit_stat} -ne 0 ]; then
	# User press CANCEL button
	exit 0
else
	# User write password and press OK
	# Makes sure that the user sudo password is correct
	until [ $"(echo $password | sudo -S echo '' >/dev/null 2>&1)" ]; do
		zenity --warning --text="<b>The user password is wrong. Try again...</b>\n
		For issue contact support at\nhttps://github.com/Andre87osx/AstroPi-system/issues" --width=${W} --title="${W_Title}"
		exit 1
	done
fi

# Check AstroPi System
(
	if [ ! -d "${AppDir}" ]; then
		mkdir -p "${AppDir}"
	fi
	echo "# Check for internet connection"
	if [ "$(wget -q --spider https://github.com/Andre87osx/AstroPi-system)" ]; then
		echo "# AstroPi are connected"
		if [ ! -f "${AppDir}/.Update.sh" ]; then
			wget https://github.com/Andre87osx/AstroPi-system/blob/v"${AstroPi_v}"/Script/AstroPi.sh
		fi
	else
		if [ ! -f "${AppDir}/AstroPi.sh" ]; then
			zenity --warning --text="<b>AstroPi System is not installed correctly.</b>
			Connect to the internet to be able to download the necessary updates. 
			\nThe program will be finished. Try again" --width=${W} --title="${W_Title}"
			exit 1
		fi
	fi

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x -R "${AppDir}"/*.sh >/dev/null 2>&1
echo "$password" | sudo -S chmod +x -R "${AppDir}"/*.py >/dev/null 2>&1

) | zenity --progress --title="Loading AstroPi - System v${AstroPi_v}..." --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}

# Export the variable to AstroPi.sh script
export password
export AstroPi_v
export GitDir
export AppDir
export WorkDir
export KStars_v
export Indi_v
export W
export H
export Wprogress
export W_err_generic
export W_Title

# Start AstroPi.sh
if [ "$(bash "${Appdir}"/AstroPi.sh)" ]; then
	exit 0
else
	zenity --error --text="${W_err_generic}" --width=${W} --title="${W_Title}"
	exit 1
fi
