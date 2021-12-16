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
AstroPi_v=1.5
KStars_v=3.5.4v1.5
Indi_v=1.9.1

# Chk and create secure user path
if [[ -z ${USER} ]] && [[ ${USER} != root ]];
then
	zenity --error --text="<b>Run this script as USER noot a root</b>\n\nError in AstroPi System" --width=$W --title="AstroPi System" && exit 1
else
	GitDir="$HOME"/.AstroPi-system
	WorkDir="$HOME"/.Projects
fi


# Get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

#=========================================================================

# Sudo password request.
password=$(zenity --password  --width=$W --title="AstroPi System $AstroPi_v")
(( $? != 0 )) && exit

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$GitDir"/Script/*.sh

# The script makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect user password</b>\n\nError in AstroPi System" --width=$W --title="AstroPi - user password required" && exit 1

(
echo "# Check internet connection first"
if wget -q --spider https://github.com/Andre87osx/AstroPi-system; then

echo "# Check if GIT dir exist"
	if [ ! -d "$GitDir" ]; then
		cd "$home" || exit 1
		git clone https://github.com/Andre87osx/AstroPi-system.git
		mv "$home"/AstroPi-system "$GitDir"
	fi
echo "# Check the AstroPi git for update."
	if ! git -C "$GitDir" pull; then
		cd "$GitDir" || exit 1
		git reset --hard
		echo "$password" | sudo -S chown -R "$USER":"$USER" "$GitDir" | git -C "$GitDir" pull || git reset --hard origin/main
		git -C "$GitDir" pull || zenity --error --text="<b>Something went wrong. I can't update the repository files.</b>\n\nContact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues" --width=$W --title="AstroPi - System $AstroPi_v" && exit 1
	fi
fi
echo "# Loading AstroPi - System."

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x -R "$GitDir"/Script

) | zenity --progress --title="Loading AstroPi - System $AstroPi_v..." --percentage=1 --pulsate --auto-close --auto-kill --width=$Wprogress

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

# Start AstroPi.sh
bash "$GitDir"/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=$W --title="AstroPi - System $AstroPi_v" && exit 1
exit 0
