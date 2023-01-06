#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | |  (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# rev 1.6 genuary 2023
# Run this script as USER
# Type in console 'bash <your script path>/install.sh'
# Autoload script, open console and paste
# curl https://raw.githubusercontent.com/Andre87osx/AstroPi-system/main/bin/install.sh > install.sh && bash install.sh

#=========================================================================
# Create version of AstroPi
majorRelease=1                                      # Major Release
minorRelease=6                                      # Minor Release
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

# Ask for the password only if the array "ask_pass" is empty. 
# Otherwise check only if the password is correct
if (( ${#ask_pass[@]} != 0 )); then
    if [ ${ask_pass} ]; then
		# Check the user password stored
		until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
			zenity --warning --text="<b>WARNING! User password is wrong...</b>
			\nTry again or sign out" --width=${W} --title=${W_Title}
			if ask_pass=$( zenity --password  --width=${W} --title=${W_Title} ); then break; else exit 0; fi
		done
	fi
else
	ask_pass=$( zenity --password --title="${W_Title}" )
	if [ ${ask_pass} ]; then
		# User write password and press OK
		# Makes sure that the sudo user password matches
		until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
			zenity --warning --text="<b>WARNING! User password is wrong...</b>
			\nTry again or sign out" --width=${W} --title=${W_Title}
			if ask_pass=$( zenity --password  --width=${W} --title=${W_Title} ); then break; else exit 0; fi
		done
	else
		# User press CANCEL button
		# Quit script
		exit 0
	fi
fi

# Chk USER and create path
if [[ -z ${USER} ]] && [[ ${USER} != root ]]; then
	echo "Run this script as user not as root"
	echo " "
	echo "Read how to use at top of this script"
	zenity --error --text="<b>WARNING! Run this script as user not as root</b>
	\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=${W} --title=${W_Title}
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
	(	
		exit_stat=1
		cd ${appDir}/bin || exit 1
		if [[ -f ./AstroPi.sh ]]; then
			echo "# Install AstroPi.sh in /usr/bin/"
			echo "Install AstroPi.sh in /usr/bin/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/AstroPi.sh /usr/bin/AstroPi.sh
		fi
		if [[ -f ./kstars.sh ]]; then
			echo "# Install kstars.sh in /usr/bin/"
			echo "Install kstars.sh in /usr/bin/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/kstars.sh /usr/bin/kstars.sh
		fi
		if [[ -f ./AstroPi.desktop ]]; then
			echo "# Install AstroPi.desktop in /usr/share/applications/"
			echo "Install AstroPi.desktop in /usr/share/applications/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/AstroPi.desktop /usr/share/applications/AstroPi.desktop
			
		fi
		if [[ -f ./kstars.desktop ]]; then
			echo "# Install kstars.desktop in /usr/share/applications/"
			echo "Install kstars.desktop in /usr/share/applications/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/kstars.desktop /usr/share/applications/kstars.desktop
			
		fi
		if  [[ -f ./panel ]]; then
			echo "# Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
			echo "Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
			cp ${appDir}/bin/panel ${HOME}/.config/lxpanel/LXDE-pi/panels/panel
		fi
		if [[ -f ./autohotspot.service ]]; then
			echo "# Install autohotspot.service in /etc/systemd/system/"
			echo "Install autohotspot.service in /etc/systemd/system/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/autohotspot.service /etc/systemd/system/autohotspot.service
			
		fi
		if [[ -f ./autohotspot ]]; then
			echo "# Install autohotspot in /usr/bin/"
			echo "Install autohotspot in /usr/bin/"
			echo ${ask_pass} | sudo -S cp ${appDir}/bin/autohotspot /usr/bin/autohotspot
		fi
		cd ${appDir}/include || exit 1
		if [[ -f ./solar-system-dark.svg ]]; then
			echo "# Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo ${ask_pass} | sudo -S cp ${appDir}/include/solar-system-dark.svg /usr/share/icons/gnome/scalable/places/solar-system-dark.svg
		fi
		if [[ -f ./solar-system.svg ]]; then
			echo "# Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
			echo ${ask_pass} | sudo -S cp ${appDir}/include/solar-system.svg /usr/share/icons/gnome/scalable/places/solar-system.svg
		fi
		if [[ -f ./kstars.svg ]]; then
			echo "# Install KStars icons in /usr/share/icons/gnome/scalable/places"
			echo "Install KStars icons in /usr/share/icons/gnome/scalable/places"
			echo ${ask_pass} | sudo -S cp ${appDir}/include/kstars.svg /usr/share/icons/gnome/scalable/places/kstars.svg
		fi
	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
}

# Prepair fot update system
function system_pre_update()
{
	(	
		# Check APT Source and stops unwanted updates
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f ${sources} ]; then
			echo ${ask_pass} | sudo -S chmod 777 ${sources}
			echo -e "# Stop unwonted update # deb https://www.astroberry.io/repo/ buster main" | sudo tee ${sources}
			(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>sources.list.d</b>
			\n.Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title} && exit 1
			echo ${ask_pass} | sudo -S chmod 644 ${sources}
		fi
		
		# Implement USB memory dump
		echo "# Preparing update"
		echo ${ask_pass} | sudo -S sh -c 'echo 1024 > /sys/module/usbcore/parameters/usbfs_memory_mb'
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>usbfs_memory_mb.</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title} && exit 1
		
		# Hold some update
		echo "# Hold some update"
		echo ${ask_pass} | sudo -S apt-mark hold kstars-bleeding kstars-bleeding-data \
		indi-full libindi-dev libindi1 indi-bin
		(($? != 0)) && zenity --error --width=${W} --text="Something went wrong in <b>hold some application</b>
		\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title="${W_Title}" && exit 1
	
	) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	exit_stat=$?
	if [ ${exit_stat} -ne 0 ]; then
		zenity --error --width=${W} --text="Something went wrong in <b>System PRE Update</b>
		Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
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
			echo ${ask_pass} | sudo -S ${CMD} -y
			sleep 1s
		) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
		exit_stat=$?
		if [ ${exit_stat} -eq 0 ]; then
			echo "System successfully updated on $(date)" >> ${appDir}/bin/update-log.txt
		elif [ ${exit_stat} -ne 0 ]; then
			echo "Error running $CMD on $(date), exit status code: ${exit_stat}" >> ${appDir}/bin/update-log.txt
			zenity --error --width=${W} --text="Something went wrong in <b>System Update ${CMD}</b>
			\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
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
	( 
		echo "# Check fo AstroPi v${AstroPi_v} download" 
		wget -c ${release} | tar --strip-components=1 -xz -C ${appDir} ) | \
		zenity --progress --title="Downloading AstroPi v${AstroPi_v}..." --pulsate --auto-close --auto-kill --width=420
	echo ""

	# Make all script executable
	
	for f in ${appDir}/bin/*.sh; do
		echo "Make executable ${f} script"
		echo ${ask_pass} | sudo -S chmod +x ${f} || echo "Error"
	done
	for f in ${appDir}/bin/*.py; do
		echo "Make executable ${f} script"
		echo ${ask_pass} | sudo -S chmod +x ${f} || echo "Error"
	done
    
	# Install all script in default path
	install_script
	
	# Perform PRE update
	system_pre_update
	
	# Get full AstoPi System update
	system_update
	
	# # Install ESO Fits view
	# (
	# 	echo "# Install ESO Fits View"
	# 	echo "${ask_pass}" | sudo -S apt install skycat -y
	# 	sleep 1s
	# ) | zenity --progress --title=${W_Title} --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}
	# exit_stat=$?
	# if [ ${exit_stat} -eq 0 ]; then
	# 	echo "ESO Fits view successfully installed on $(date)" >> ${appDir}/script/update-log.txt
	# elif [ ${exit_stat} -ne 0 ]; then
	# 	echo "Error running ESO Fits view on $(date), exit status code: ${exit_stat}" >> ${appDir}/script/update-log.txt
	# 	zenity --error --width=${W} --text="Something went wrong in <b>Error running ESO Fits view</b>
	# 	\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --title=${W_Title}
	# 	exit 1
	# fi
	
	# Add permanent link in bashrc
	if [ -n "$(grep 'alias AstroPi=' $HOME/.bashrc)" ]; then
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
	if [ -f ${HOME}/AstroPi* ]; then	
		echo ${ask_pass} | sudo -S rm -Rf ${HOME}/AstroPi* || exit 1	
	fi
	if [ -f ${HOME}/.Update.sh ]; then	
		echo ${ask_pass} | sudo -S rm -Rf ${HOME}/.Update.sh || exit 1	
	fi
	if [ -f /usr/share/applications/org.kde.kstars.desktop ]; then	
		echo ${ask_pass} | sudo -S rm -Rf /usr/share/applications/org.kde.kstars.desktop || exit 1	
	fi
	if [ -d ${appDir}/script ]; then	
		echo ${ask_pass} | sudo -S rm -Rf -d ${appDir}/script || exit 1	
	fi
		
	# Installation is finished
	echo ""
	echo "The installation of AstroPi v${AstroPi_v} is completed. Launch AstroPi to try it out"
	zenity --info --width=${W} --text="<b><big>The installation of AstroPi v${AstroPi_v} is completed.</big>
	\nLaunch AstroPi to try it out</b>" --title=${W_Title}
    
	# STOP LOOP
	break
done
