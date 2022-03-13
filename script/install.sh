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
SCREEN_WIDTH=$( xwininfo -root | awk '$1=="Width:" {print $2}' )
SCREEN_HEIGHT=$( xwininfo -root | awk '$1=="Height:" {print $2}' )

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
https://github.com/Andre87osx/AstroPi-system/issues"

apt_commands=(
'apt-get update'
'apt-get upgrade'
'apt-get full-upgrade'
'apt autopurge'
'apt autoremove'
'apt autoclean'
)

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

# Install all script in default path
function install_script()
{
	exit_stat=1
	cd ${appDir}/script || exit 1
	if [[ -f ./AstroPi.sh ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/AstroPi.sh /usr/bin/AstroPi.sh
		echo "Install AstroPi.sh in /usr/bin/"
	fi
	if [[ -f ./kstars.sh ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/kstars.sh /usr/bin/kstars.sh
		echo "Install kstars.sh in /usr/bin/"
	fi
	if [[ -f ./AstroPi.desktop ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/AstroPi.desktop /usr/share/applications/AstroPi.desktop
		echo "Install AstroPi.desktop in /usr/share/applications/"
	fi
	if [[ -f ./kstars.desktop ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/kstars.desktop /usr/share/applications/kstars.desktop
		echo "Install kstars.desktop in /usr/share/applications/"
	fi
	if  [[ -f ./panel ]]; then
		cp ${appDir}/script/panel ${HOME}/.config/lxpanel/LXDE-pi/panels/panel
		echo "Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
	fi
	if [[ -f ./autohotspot.service ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/autohotspot.service /etc/systemd/system/autohotspot.service
		echo "Install autohotspot.service in /etc/systemd/system/"
	fi
	if [[ -f ./autohotspot ]]; then
		echo ${ask_pass} | sudo -S cp ${appDir}/script/autohotspot /usr/bin/autohotspot
		echo "Install autohotspot in /usr/bin/"
	fi 
}

# Prepair fot update system
function system_pre_update()
{
	(	
		# Check APT Source and stops unwanted updates
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f "${sources}" ]; then
			echo ${ask_pass} | sudo -S chmod 777 "${sources}"
			echo -e "# Stop unwonted update deb https://www.astroberry.io/repo/ buster main" | sudo tee "${sources}"
			(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>sources.list.d</b>
			\n.Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
			echo ${ask_pass} | sudo -S chmod 644 "${sources}"
		fi
		
		# Implement USB memory dump
		echo "# Preparing update"
		echo ${ask_pass} | sudo -S sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
		
		# Hold some update
		echo "# Hold some update"
		echo ${ask_pass} | sudo -S apt-mark hold kstars-bleeding kstars-bleeding-data zenity \
		indi-full libindi-dev libindi1 indi-bin
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>hold some application</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	
	) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>System PRE Update</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
		exit 1
	fi
}

# Get full AstoPi System update
function system_update()
{
	for CMD in "${apt_commands[@]}"; do
		echo ""
		echo "Running $CMD"
		echo ""
		(
			echo "# Running Update ${CMD}"
			echo "${ask_pass}" | sudo -S ${CMD} -y
			sleep 1s
		) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
		exit_stat=$?
		if [ ${exit_stat} -eq 0 ]; then
			echo "System successfully updated on $(date)" >> ${appDir}/script/update-log.txt
		elif [ ${exit_stat} -ne 0 ]; then
			echo "Error running $CMD on $(date), exit status code: ${exit_stat}" >> ${appDir}/script/update-log.txt
			zenity --error --width=${W} --text="Something went wrong in <b>System Update ${CMD}</b>
			\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}"
			exit 1
		fi
	done	
	
}

echo "Check for internet connection"
release="https://github.com/Andre87osx/AstroPi-system/archive/refs/tags/v${AstroPi_v}.tar.gz -O -"
connection=$( wget -q --spider https://github.com/Andre87osx/AstroPi-system )
while ${connection}; do
	echo "AstroPi is online!"
	echo ""
	echo "Downloading AstroPi v${AstroPi_v}..."
	echo ""
	( wget -c ${release} | tar --strip-components=1 -xz -C "${appDir}" ) 2>&1 | \
	sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
	zenity --progress --title="Downloading AstroPi v${AstroPi_v}..." --pulsate --auto-close --auto-kill --width=420
	echo ""

	# Make all script executable
	for f in ${appDir}/script/*.sh; do
		echo "Make executable ${f} script"
		echo "${ask_pass}" | sudo -S chmod +x "${f}"
	done
	for f in ${appDir}/script/*.py; do
		echo "Make executable ${f} script"
		echo "${ask_pass}" | sudo -S chmod +x "${f}"
	done
    
	# Install all script in default path
	install_script
	
	# Perform PRE update
	system_pre_update
	
	# Get full AstoPi System update
	system_update
	
	# Add permanent link in bashrc
	if [ -n "$(grep 'alias AstroPi=' '${HOME}/.bashrc')" ]; then
		# The permanent link allredy exist 
		true
	else
		echo "alias AstroPi='/usr/bin/AstroPi.sh'" >>${HOME}/.bashrc
	fi
	
	# Set default wallpaper
	pcmanfm --set-wallpaper="${appDir}/include/AstroPi_wallpaper.png"
    
	# Restart LX for able new change icon and wallpaper
	lxpanelctl restart
	
	# Delete old AstroPi installations and GIT	
	if [ -d ${HOME}/.AstroPi-system ]; then	
		echo ${ask_pass} | sudo -S rm -Rf ${HOME}/.AstroPi-system || exit 1	
	fi
	if [ -f /usr/bin/.Update.sh ]; then	
		echo ${ask_pass} | sudo -S rm -Rf /usr/bin/.Update.sh || exit 1	
	fi
    
	# Installation is finished
	echo ""
	echo "The installation of AstroPi v${AstroPi_v} is completed. Launch AstroPi to try it out"
	zenity --info --width=${W} --text="<b><big>The installation of AstroPi v${AstroPi_v} is completed.</big>
	\nLaunch AstroPi to try it out</b>" --title="${W_Title}"
    
	# STOP LOOP
	break
done
