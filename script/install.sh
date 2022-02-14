#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# Run this script as USER
# Type in console 'bash <your script path>/install.sh'

#=========================================================================
# Create version of AstroPi
majorRelease=1                                      # Major Release
minorRelease=5                                      # Minor Release
AstroPi_v=${majorRelease}.${minorRelease}           # Actual Stable Release

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
https://github.com/Andre87osx/AstroPi-system/issues"
#=========================================================================

# Ask super user password.
ask_pass=$( zenity --password --title="${W_Title}" )
if [ ${ask_pass} ]; then
	# User write password and press OK
	# Makes sure that the sudo user password matches
	until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
		zenity --warning --text="<b>WARNING! User password is wrong...</b>
		\nTry again or sign out" --width=${W} --title="${W_Title}"
		if password=$( zenity --password  --width=${W} --title="${W_Title}" ); then break; else exit 0; fi
	done
else
	# User press CANCEL button
	# Quit script
	exit 0
fi

# Chk USER and create path
if [[ -z ${USER} ]] && [[ ${USER} != root ]]; then
	echo "Run this script as user not as root"
	echo " "
	echo "Read how to use at top of this script"
	zenity --error --text="<b>WARNING! Run this script as user not as root</b>
	\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title="${W_Title}"
	exit 1
else
	appDir=${HOME}/.local/share/astropi
	echo "Wellcome to AstroPi System"
	echo "=========================="
	if [ ! -d ${appDir} ]; then
		mkdir -p ${appDir}
	fi
fi

echo "Check for internet connection"
connection=$( wget -q --spider https://github.com/Andre87osx/AstroPi-system )
while ${connection} ; do
	echo "AstroPi is online!"
	echo ""
	echo "Downloading AstroPi v${AstroPi_v}..."
	echo ""
	( wget -c https://github.com/Andre87osx/AstroPi-system/archive/refs/tags/v"${AstroPi_v}".tar.gz -O - | \
	tar --strip-components=1 -xz -C ${appDir} ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
	zenity --progress --title="Downloading AstroPi v${AstroPi_v}..." --pulsate --auto-close --auto-kill --width=420
	echo ""
    
	# Install all script in default path
	cd ${appDir}/script || exit 1
	for f in ./*.sh; do
		exit_stat=1
   		echo ${ask_pass} | sudo -S cp "${appDir}"/script/"${f}" /usr/bin/"${f}" && exit_stat=0
		echo ${ask_pass} | sudo -S chmod +x /usr/bin/"${f}" && exit_stat=0
		echo "Install ${f} in	/usr/bin/"
		if [ ${exit_stat} -ne 0 ]; then
			zenity --error --width=${W} --text="Something went wrong <b>installing ${f}...</b>
			\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
			exit 1
		fi
	done
	for f in ./*.desktop; do
		exit_stat=1
   		echo ${ask_pass} | sudo -S cp "${appDir}"/script/"${f}" /usr/share/applications/"${f}" && exit_stat=0
		echo ${ask_pass} | sudo -S chmod +x /usr/share/applications/"${f}" && exit_stat=0
		echo "Install ${f} in	/usr/share/applications/"
		if [ ${exit_stat} -ne 0 ]; then
			zenity --error --width=${W} --text="Something went wrong <b>installing ${f}...</b>
			\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
			exit 1
		fi
	done
	while true; do
		cd ${appDir}/script || exit 1
		echo ${ask_pass} | sudo -S cp "${appDir}"/script/autohotspot.service /etc/systemd/system/autohotspot.service
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating AstroPi Hotspot.service</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "Install autohotspot.service in	/etc/systemd/system/"
		
		echo ${ask_pass} | sudo -S cp "${appDir}"/script/autohotspot /usr/bin/autohotspot
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating AstroPi Hotspot script</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "Install autohotspot in	/usr/bin/"
		
		echo ${ask_pass} | sudo -S cp "${appDir}"/script/panel "${HOME}"/.config/lxpanel/LXDE-pi/panels/panel
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>editing lxpanels</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "Install panel in	${HOME}/.config/lxpanel/LXDE-pi/panels/"
		
		echo ${ask_pass} | sudo -S cp "${appDir}"/script/parking.py /usr/bin/parking.py
		(($? != 0)) && zenity --error --width=$W --text="Something went wrong in <b>Updating parking.py</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="AstroPi System $AstroPi_v" && exit 1
		echo "Install parking.py in	/usr/bin/"
	done
    
	# Set default wallpaper
	pcmanfm --set-wallpaper="${appDir}/include/AstroPi_wallpaper.png"
    
	# Restart LX for able new settings
	lxpanelctl restart 
    
	# Installation is finished
	echo ""
	echo "The installation of AstroPi v${AstroPi_v} is completed. Launch AstroPi to try it out"
	zenity --info --width=${W} --text="<b><big>The installation of AstroPi v${AstroPi_v} is completed.</big>
	\nLaunch AstroPi to try it out</b>" --title="${W_Title}"
    
	# STOP LOOP
	break
done
