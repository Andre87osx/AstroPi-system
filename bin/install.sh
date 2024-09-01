#!/bin/bash
# shellcheck source=/dev/null
# shellcheck disable=2043
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

# Check internet connectionions and if Git exist
# If connections is ok download library file
echo "wellcome to AstroPi installer"
echo ""
echo "Check internet connectionions and if Git exist"
echo ""
case "$(curl -s --max-time 2 -I https://github.com/Andre87osx/AstroPi-system | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) echo "HTTP connectivity is up"  && CONN="true"
  		curl https://raw.githubusercontent.com/Andre87osx/AstroPi-system/main/include/functions.sh > "${HOME}"/functions.sh
		echo ""
		echo "Library downloaded";;
  5)	echo "The web proxy won't let us through" && CONN="false"
  		zenity --error --text="The web proxy won't let us through"
		exit 1;;
  *)	echo "The network is down or very slow" && CONN="false"
		zenity --error --text="The network is down or very slow"
		exit 1;;
esac

# Start installation functions
while [ "${CONN}" == "true" ]; do
	# Start true loop
	# Import common array and functions
	# Usage: import "mylib"
	function import() {
		local mylib="${HOME}/${1}.sh"
		if [ -f "${mylib}" ]; then
			source "${mylib}"
		else
			echo "Error: Cannot find library at: ${mylib}"
			zenity --error --text="Could not find library at: ${mylib}"
			break && exit 1
		fi
	}
	import "functions" 

	# Ask super user password.
	ask_pass=$( zenity --password  --width=${W} --title="${W_Title}" )
	case $? in
	0)	until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
			zenity --warning --text="<b>WARNING! User password is wrong...</b>
			\nTry again or sign out" --width=${W} --title="${W_Title}"
			ask_pass=$( zenity --password  --width=${W} --title="${W_Title}" )
			case $? in
				1) exit 0;;
			esac
		done ;;
	1)
		# Close form input password
		exit 0;;
	esac
	
	# Grant superuser command without password
	echo "${ask_pass}" | sudo -S echo '' 2>/dev/null
	echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER-for-sudo-password" > /dev/null


	# Chk USER and create path
	chkUser

	# Download last AstroPi System script project
	release="https://github.com/Andre87osx/AstroPi-system/archive/refs/tags/v${AstroPi_v}.tar.gz -O -"
	echo "Downloading AstroPi v${AstroPi_v}..."
	echo ""
	( 
		echo "# Check for AstroPi v${AstroPi_v} download" 
		wget -c ${release} | tar --strip-components=1 -xz -C "${appDir}" ) | \
	zenity --progress --title="Downloading AstroPi v${AstroPi_v}..." --pulsate --auto-close --auto-kill --width=${Wprogress}
	echo ""
	# Make all script executable
	make_executable
    
	# Install all script in default path
	install_script
	
	# Perform PRE update
	system_pre_update
	
	# Get full AstoPi System update
	system_update
	
	# Add AstroPi link in console 
	isInFile=$(cat "${HOME}"/.bashrc | grep -c "alias AstroPi=")
	if [ $isInFile -eq 0 ]; then
		#string not contained in file
   		echo "alias AstroPi='/usr/bin/AstroPi.sh'" >>"${HOME}"/.bashrc
	else
   		#string is in file at least once
   		true
	fi
	
	# Set default wallpaper
	pcmanfm --set-wallpaper="${appDir}/include/AstroPi_wallpaper.png"
    
	# Restart LX for able new change icon and wallpaper
	lxpanelctl restart
	
	# Delete old AstroPi installations and GIT
	file_old=(
	'AstroPi'
 	'AstroPi-system'
	'AstroPi system updater'
	'Update'
 	'.Update'
	'install'
	'functions'
	'wget-log'
	)
	for f in "${HOME}"/"${file_old[@]}".*; do sudo rm -Rf "$f"; done
	
	if [ -d "${appDir}/script" ]; then	
		sudo rm -Rf -d "${appDir}"/script
	fi
		
	# Installation is finished
	echo ""
	echo "The installation of AstroPi v${AstroPi_v} is completed. Launch AstroPi to try it out"
	zenity --info --width=${W} --text="<b><big>The installation of AstroPi v${AstroPi_v} is completed.</big>
	\nLaunch AstroPi to try it out</b>" --title=${W_Title}
    
	# STOP LOOP
	break
done
