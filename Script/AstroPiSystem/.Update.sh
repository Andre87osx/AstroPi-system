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
for i in ${!functions[@]}
do
    ${functions[$i]}
done

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x /home/astropi/.AstroPi-system/Script/*.sh

# the script makes sure that the user sudo password is correct
(( $? != 0 )) && zenity --error --text="<b>Incorrect user password</b>\n\nError in AstroPi System" --width=300 --title="AstroPi - user password required" && exit 1

# Information window for any extension of the waiting time
zenity --info --title="AstroPi System" --text="I prepare the files to run the latest version of AstroPi System.\n<b>The operation can last a few minutes</b>" --width=300 --timeout=10

# =================================================================
# Check the AstroPi repo for update."
echo "$password" | sudo -S git -C /home/astropi/.AstroPi-system pull
exit_status=$?
if [ $exit_status -eq 1 ]; then 
cd /home/astropi/.AstroPi-system/
echo "$password" | sudo -S git reset --hard origin/main
echo "$password" | sudo -S git -C /home/astropi/.AstroPi-system pull
fi
# =================================================================

# I make sure that the scripts are executable
echo "$password" | sudo -S chmod +x /home/astropi/.AstroPi-system/Script/*.sh

# I export the password to the script AstroPi.sh
export password
/$HOME/.AstroPi-system/Script/AstroPi.sh

# launch AstroPi.sh
echo "$password" | sudo -S /$HOME/.AstroPi-system/Script/AstroPi.sh
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System"
exit 0
