#!/bin/bash
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Bash variables
#=========================================================================
AstroPi_V=v.1.3

# Sudo password request.
password=$(zenity --password  --width=300 --title="AstroPi System $AstroPi_V")

# Make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$HOME"/.AstroPi-system/Script/*.sh

# Makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect User or Password</b>\n\nError in AstroPi System" --width=300 --title="AstroPi - user password required" && exit 1

# Information window for the waiting time
zenity --info --title="AstroPi System $AstroPi_V" --text="Check if the local GIT is up to date, readable and executable.\n<b>The operation can last a few minutes</b>" --width=300 --timeout=5

# Check the AstroPi GIT for update.
git -C "$HOME"/.AstroPi-system pull
if [ $? = 0 ]; then
	echo "GIT is up to date"
else
	# Check connection first
	wget -q --spider https://github.com/Andre87osx/AstroPi-system
	if [ $? == 0 ]; then
		zenity --warning --title="AstroPi System $AstroPi_V" --text="AstroPi system seems corrupt or inaccessible.\n<b>I download the files from the GIT, and update it. This can take a few minutes.</b>" --width=300 --timeout=5
		echo "$password" | sudo -S rm -rf "$GitDir"
		cd "$HOME" || exit
		git clone https://github.com/Andre87osx/AstroPi-system.git
		mv "$HOME"/AstroPi-system "$HOME"/.AstroPi-system
		git -C "$HOME"/.AstroPi-system pull || exit
	else
		echo "I can not update the GIT because it lacks an internet connection"
	fi
fi

# Make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$HOME"/.AstroPi-system/Script/*.sh

# Export variable to AstroPi.sh
export password
"$HOME"/.AstroPi-system/Script/AstroPi.sh

# Starting AstroPi.sh
echo "$password" | sudo -S "$HOME"/.AstroPi-system/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong trying to start AstroPi System. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System $AstroPi_V" && exit 1
exit 0
