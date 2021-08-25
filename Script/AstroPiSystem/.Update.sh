#!/bin/bash                                              
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Sudo password request. 
password=$(zenity --password  --width=300 --title="AstroPi System")
WorkDir="$HOME"/.AstroPi-system
for i in ${!functions[@]}
do
    ${functions[$i]}
done

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$WorkDir"/Script/*.sh

# the script makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect user password</b>\n\nError in AstroPi System" --width=300 --title="AstroPi - user password required" && exit 1

# Information window for the waiting time
zenity --info --title="AstroPi System" --text="I prepare the files to run the latest version of AstroPi System.\n<b>The operation can last a few minutes</b>" --width=300

# =========================================================================
# Check the AstroPi git for update.
	(
	# =================================================================
	echo "5"
	echo "# Preparing update"
	sleep 2s
        git -C "$WorkDir" pull
        case $? in
        0)
        	zenity --info --text="All file have been successfully updated" --width=300 --title="AstroPi System"
        ;;
        1)
		echo "$password" | sudo -S rm -rf "$WorkDir"
		cd "$HOME" || exit
		git clone https://github.com/Andre87osx/AstroPi-system.git
		mv $HOME/AstroPi-system $HOME/.AstroPi-system
		git -C "$WorkDir" pull
		zenity --info --text="All file have been successfully updated" --width=300 --title="AstroPi System"
        ;;
        -1)
		echo "$password" | sudo -S rm -rf "$WorkDir"
		cd "$HOME" || exit
		git clone https://github.com/Andre87osx/AstroPi-system.git
		mv $HOME/AstroPi-system $HOME/.AstroPi-system
		git -C "$WorkDir" pull
		zenity --info --text="All file have been successfully updated" --width=300 --title="AstroPi System"
        ;;
        esac

	# =================================================================
	echo "75"
	echo "# Make sure that the script are executable"
	sleep 2s
        chmod +x $HOME/.AstroPi-system/Script/*.sh
        chmod +x $HOME/.AstroPi-system/Script/AstroPiSystem/*.sh
			
	# =================================================================
	echo "100"
	echo "# One meore second"
        sleep 1s 
        
	) | zenity --progress \
	--title="AstroPi System $ASTROPI_V" \
	--text="AstroPi System $ASTROPI_V" \
	--percentage=0 \
	--auto-close \
	--width=300 \
	--auto-kill

# ========================================================================

# I export the password to the script AstroPi.sh
export password
/$HOME/.AstroPi-system/Script/AstroPi.sh

# launch AstroPi.sh
echo "$password" | sudo -S /$HOME/.AstroPi-system/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
exit 0
