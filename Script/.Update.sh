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
Indi_v=1.9.1		# Dased on INDI 1.9.1 Core
#=========================================================================

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="Something went wrong...\nContact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# Chk USER and create path
if [[ -z ${USER} ]] && [[ ${USER} != root ]];
then
	zenity --error --text="<b>Run this script as USER not as root</b>\n\nError in AstroPi System" --width=${W} --title="${W_Title}"
	exit 1
else
	GitDir="${HOME}"/.AstroPi-system
	WorkDir="${HOME}"/.Projects
fi

# Sudo password request.
password=$(zenity --password  --width=${W} --title="${W_Title}") ]
exit_stat=$?
if [ ${exit_stat} -ne 0 ]; then
	# User press CANCEL button
	exit 0
else
	# User write password and press OK
	# Makes sure that the user sudo password is correct
	until (echo $password | sudo -S echo '' 2>/dev/null); do
		zenity --warning --text="<b>The password is incorrect.</b>\n\nTry again or sign out" --width=${W} --title="${W_Title}"
		if password=$(zenity --password  --width=${W} --title="${W_Title}"); then true; else exit 0; fi
	done
fi

# Check and update AstroPi GIT
(
echo "# Check internet connection first"
if [ wget -q --spider https://github.com/Andre87osx/AstroPi-system ]; then
	echo "# Check if GIT dir exist"
	if [ ! -d "${GitDir}" ]; then
		cd "${HOME}" || exit 1
		git clone https://github.com/Andre87osx/AstroPi-system.git
		mv "${HOME}"/AstroPi-system "${GitDir}"
	fi
	echo "# Loading AstroPi - System."
	if [ ! git -C "${GitDir}" pull ]; then
		cd "${GitDir}" || exit 1
		git reset --hard
		echo "$password" | sudo -S chown -R "${USER}":"${USER}" "${GitDir}" | git -C "${GitDir}" pull || git reset --hard origin/main
		git -C "${GitDir}" pull || zenity --error --text="${W_err_generic}" --width=${W} --title="${W_Title}" && exit 1
	fi
fi

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x -R "${GitDir}"/Script

) | zenity --progress --title="Loading AstroPi - System ${AstroPi_v}..." --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}

# Export the variable to AstroPi.sh script
export password
export AstroPi_v
export GitDir
export WorkDir
export KStars_v
export Indi_v
export W
export H
export Wprogress
export W_err_generic
export W_Title

# Start AstroPi.sh
if [ bash "${GitDir}"/Script/AstroPi.sh ]; then
	exit 0
else
	zenity --error --text="${W_err_generic}" --width=${W} --title="${W_Title}"
	exit 1
fi
