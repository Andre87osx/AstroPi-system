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
AstroPi_v=v1.3 - Beta
GitDir="$HOME"/.AstroPi-system
for i in ${!functions[@]}
do
    ${functions[$i]}
done

# Sudo password request. 
password=$(zenity --password  --width=300 --title="AstroPi System")

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$GitDir"/Script/*.sh

# The script makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect user password</b>\n\nError in AstroPi System" --width=300 --title="AstroPi - user password required" && exit 1

# Check internet connection first
wget -q --spider https://github.com/Andre87osx/AstroPi-system
if [ $? -eq 0 ]; then

# Check the AstroPi git for update.
	git -C "$GitDir" pull
	if [ "$?" -ne 0 ]; then
		if [ !-d "$GitDir" ]; then
			cd "$HOME" || exit
			git clone https://github.com/Andre87osx/AstroPi-system.git
			mv $HOME/AstroPi-system $HOME/.AstroPi-system
		else
			cd "$GitDir"
			git reset --hard
		fi

	
        chmod +x "$GitDir"/Script/*.sh
        chmod +x "$GitDir"/AstroPiSystem/*.sh
			


# Export the variable to AstroPi.sh script
export password

# Start AstroPi.sh
"$GitDir"/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
exit 0
