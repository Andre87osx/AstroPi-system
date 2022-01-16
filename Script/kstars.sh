#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
# KStars AstroPi launcher and monitor

Script_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Check disk space and load KStars - AstoPi
#=========================================================================
allert_space=60                                         # 60% maximum used space
min_free_space=40                                       # 40GB minimum free disk space
disk_space=$(df -h | awk '$1=="/dev/root"{print $2}')
disk_space=${disk_space::-1}                            # Total disk space ONLY decimal number
free_space=$(df -h | awk '$1=="/dev/root"{print $4}')
free_space=${free_space::-1}                            # Total free disk space ONLY decimal number
perc_used=$(df -h | awk '$1=="/dev/root"{print $5}')
perc_used=${perc_used::-1}                              # Percentage disk usage ONLY decimal number

exit_stat=""
while true; do
	if [[ $perc_used -ge $allert_space || $min_free_space -ge $free_space  ]]; then
		# Available memory conditions are NOT respected
		echo "STOP START KStars - AstroPi used_disk ${perc_used}% free_space ${free_space}GB"
		zenity --warning --width=400 --height=200 --text "<b>Minimum free disk space requirements are not met!</b>
		\nYou have used ${perc_used}% and have ${free_space}GB free\n<b>Please do disk cleanup</b>"
		exit_stat=1
		break
	else
		# Available memory conditions are met
		echo "Start KStars - AstroPi used_disk ${perc_used}% free_space ${free_space}GB"
		exit_stat=0
		break
	fi
done

# Chk exit status
#=========================================================================
if [[ $exit_stat -eq 1 ]]; then
	# Exit script launcher with exit status error
	exit 1
fi

# Start KStars - AstroPi
# Wait to know the output status of kStars, if = 0 the user has closed KStars, if != 0 a crash has occurred
#=========================================================================
if kstars; then
	# Close the script safetly
	echo "KStars- AstroPi is closed by user correctly"
	exit 0
else
	echo "FAILURE: KStars- AstroPi crashed. The telescope will be parked and the INDI services stopped"
	(kstars &)		# Re-open KStars - AstroPi for use DBUS to control devices
	sleep 10s		# Wait until kstars has started completely
	${Script_Dir}		# Go to bash directory
	python parking.py	# Launch parking script
	pkill kstars		# Close Kstars - AstroPi
	exit 0
fi
