#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | |  (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# Run this script as USER
# Type in console 'bash <your script path>/update.sh'

# Import common array and functions
if [ -f ${HOME}/.local/share/astropi/include/functions.sh ]; then
	source ${HOME}/.local/share/astropi/include/functions.sh
else
	zenity --error --width=300 --text="Something went wrong...
	AstroPi System is not correctly installed" --title="AstroPi-System" && exit 1
fi

# Ask super user password.
ask_pass

# Chk USER and create path
chkUser

# List APT cmd to perform full system update
apt_commands=(
'apt-get update'
'apt-get upgrade'
'apt-get full-upgrade'
'apt autopurge'
'apt autoremove'
'apt autoclean'
)

# Install all script in default path
function install_script()
{
	for FILE in ${appDir}/bin/*; do
		cd ${appDir}/bin || exit 1
		if [ echo ${ask_pass} | sudo -S cp ./AstroPi.sh /usr/bin/AstroPi.sh ]; then
			echo "Install AstroPi.sh in /usr/bin/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./kstars.sh /usr/bin/kstars.sh ]; then
			echo "Install kstars.sh in /usr/bin/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./AstroPi.desktop /usr/share/applications/AstroPi.desktop ]; then
			echo "Install AstroPi.desktop in /usr/share/applications/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./kstars.desktop /usr/share/applications/kstars.desktop ]; then
			echo "Install kstars.desktop in /usr/share/applications/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./bin/panel ${HOME}/.config/lxpanel/LXDE-pi/panels/panel ]; then
			echo "Install panel in ${HOME}/.config/lxpanel/LXDE-pi/panels/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./autohotspot.service /etc/systemd/system/autohotspot.service ]; then
			echo "Install autohotspot.service in /etc/systemd/system/"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./autohotspot /usr/bin/autohotspot ]; then	
			echo "Install autohotspot in /usr/bin/"
		fi
	done
	for FILE in ${appDir}/include/*; do
		cd ${appDir}/include || exit 1
		if [ echo ${ask_pass} | sudo -S cp ./solar-system-dark.svg /usr/share/icons/gnome/scalable/places/solar-system-dark.svg ]; then
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./solar-system.svg /usr/share/icons/gnome/scalable/places/solar-system.svg ]; then
			echo "Install AstroPi icons in /usr/share/icons/gnome/scalable/places"
		fi
		if [ echo ${ask_pass} | sudo -S cp ./kstars.svg /usr/share/icons/gnome/scalable/places/kstars.svg ]; then
			echo "Install KStars icons in /usr/share/icons/gnome/scalable/places"
		fi
	done
}

# Prepair fot update system
function system_pre_update()
{
	(	
		# Check APT Source and stops unwanted updates
		sources=/etc/apt/sources.list.d/astroberry.list
		if [ -f "${sources}" ]; then
			echo ${ask_pass} | sudo -S chmod 777 "${sources}"
			echo -e "# Stop unwonted update # deb https://www.astroberry.io/repo/ buster main" | sudo tee "${sources}"
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
		echo ${ask_pass} | sudo -S apt-mark hold kstars-bleeding kstars-bleeding-data \
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
			echo "System successfully updated on $(date)" >> ${appDir}/bin/update-log.txt
		elif [ ${exit_stat} -ne 0 ]; then
			echo "Error running $CMD on $(date), exit status code: ${exit_stat}" >> ${appDir}/bin/update-log.txt
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
	for f in ${appDir}/bin/*.sh; do
		echo "Make executable ${f} script"
		echo "${ask_pass}" | sudo -S chmod +x "${f}"
	done
	for f in ${appDir}/bin/*.py; do
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
	if [ -d ${HOME}/.AstroPi-system ]; then	
		echo ${ask_pass} | sudo -S rm -Rf ${HOME}/.AstroPi-system || exit 1
		echo "Remoove unused and old script"
	fi
	if [ -f /usr/bin/.Update.sh ]; then	
		echo ${ask_pass} | sudo -S rm -Rf /usr/bin/.Update.sh || exit 1
		echo "Remoove unused and old script"
	
	fi
	if [ -f /usr/share/applications/org.kde.kstars.desktop ]; then	
		echo ${ask_pass} | sudo -S rm -Rf /usr/share/applications/org.kde.kstars.desktop || exit 1
		echo "Remoove unused and old script"
	fi
	if [ -d ${appDir}/script ]; then	
		echo ${ask_pass} | sudo -S rm -Rf -d ${appDir}/script || exit 1
		echo "Remoove unused and old script"
	fi
		
	# Installation is finished
	echo ""
	echo "The installation of AstroPi v${AstroPi_v} is completed. Launch AstroPi to try it out"
	zenity --info --width=${W} --text="<b><big>The installation of AstroPi v${AstroPi_v} is completed.</big>
	\nLaunch AstroPi to try it out</b>" --title="${W_Title}"
    
	# STOP LOOP
	break
done
