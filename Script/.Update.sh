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
Indi_V=1.9.1
KStars_V=3.5.5v1.3-Beta
AstroPi_V=v.1.3
GitDir="$HOME"/.AstroPi-system
WorkDir="$HOME"/.Projects

for i in ${!functions[@]}
do
    ${functions[$i]}
done

# Bash functios
#=========================================================================
chkUsr()
{
if [ "$(whoami)" = "root" ]; then
	su - astropi || exit 1
fi
}

buildGit()
{
echo "$password" | sudo -S rm -rf "$GitDir"
cd "$HOME" || exit
git clone https://github.com/Andre87osx/AstroPi-system.git
mv "$HOME"/AstroPi-system "$GitDir"
git -C "$GitDir" pull
}

#=========================================================================
# Sudo password request. 
password=$(zenity --password  --width=300 --title="AstroPi System $AstroPi_V")

#=========================================================================
# Make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$GitDir"/Script/*.sh

#=========================================================================
# Makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect User or Password</b>\n\nError in AstroPi System" --width=300 --title="AstroPi - user password required" && exit 1

#=========================================================================
# Information window for the waiting time
zenity --info --title="AstroPi System $AstroPi_V" --text="Check if the local GIT is up to date, readable and executable.\n<b>The operation can last a few minutes</b>" --width=300

#=========================================================================
# Check if whoami is user not root
chkUsr

#=========================================================================
# Check the AstroPi GIT for update.
git -C "$GitDir" pull | zenity --progress --title="AstroPi System $AstroPi_V" --text="AstroPi System $AstroPi_V" \
				--percentage=0 \
				--auto-close \
				--width=300 \
				--auto-kill \
				--pulsante
case $? in
0)
	true
;;
1)
	# Check firs connection
	wget -q --spider https://github.com/Andre87osx/AstroPi-system
	if [ $? -eq 0 ]; then
		builGit | zenity --progress \
				--title="AstroPi System $AstroPi_V" \
				--text="AstroPi System $AstroPi_V" \
				--percentage=0 \
				--auto-close \
				--width=300 \
				--auto-kill \
				--pulsante		
	else
		echo "I can not update the GIT because it lacks an internet connection"
	fi
;;
-1)
	# Check firs connection
	wget -q --spider https://github.com/Andre87osx/AstroPi-system
	if [ $? -eq 0 ]; then
		builGit | zenity --progress \
				--title="AstroPi System $AstroPi_V" \
				--text="AstroPi System $AstroPi_V" \
				--percentage=0 \
				--auto-close \
				--width=300 \
				--auto-kill \
				--pulsante
	else
		echo "I can not update the GIT because it lacks an internet connection"
	fi
        ;;
        esac

#=========================================================================
# Make sure that the scripts are executable
echo "$password" | sudo -S chmod +x "$GitDir"/Script/*.sh

#=========================================================================
# Export all variable to AstroPi.sh
export password
"$GitDir"/Script/AstroPi.sh
export Indi_V
"$GitDir"/Script/AstroPi.sh
export KStars_V
"$GitDir"/Script/AstroPi.sh
export AstroPi_V
"$GitDir"/Script/AstroPi.sh
export GitDir
"$GitDir"/Script/AstroPi.sh
export WorkDir
"$GitDir"/Script/AstroPi.sh

#=========================================================================
# Starting AstroPi.sh
echo "$password" | sudo -S "$GitDir"/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong trying to start AstroPi System. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System $AstroPi_V" && exit 1
exit 0
