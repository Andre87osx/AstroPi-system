#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | |  (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
# KStars AstroPi launcher and monitor

# Found bash path dir Kstar.sh
Script_Dir="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" >/dev/null 2>&1 && pwd )"

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
		echo "WARNING TO START KStars AstroPi.
		\nThe memory requirements on the disk are not met used_disk ${perc_used}% free_space ${free_space}GB"
		if ( zenity --question --width=350 --title="KStars AstroPi" --ok-label "Yes" --cancel-label "No" \
			--text "<b>WARNING TO START KStars AstroPi.
			\nMinimum free disk space requirements are not met!</b>
			\nYou have used ${perc_used}% and have ${free_space}GB free\n<b>Please do disk cleanup</b>
			\nYou still relly want to start KStars AstroPi?" ); then 
			exit_stat=0
			break
		else 
			exit_stat=1
			break 
		fi
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
# Wait to know the output status of kStars, 
# if = 0 the user has closed KStars
# if != 0 a crash has occurred
#=========================================================================
if kstars > /dev/null 2>&1; then
	# Close the script
	echo "KStars - AstroPi is closed by user correctly"
	exit 0
else
	echo "FAILURE: KStars- AstroPi crashed. The telescope will be parked and the INDI services stopped"
 	time=$( date '+%F_%H:%M:%S' )			# Set current date and time
	zenity --warning --width=350 --title="KStars AstroPi" --text="<b>KStars AstroPi crashed...</b>
	\nThe telescope will be parked and the INDI services stopped on ${time}.
	\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" &	
	# Re-open KStars - AstroPi for use DBUS to control devices
 	( kstars & )
 	interval=5
	while true; do
    		if pgrep -x "kstars" > /dev/null; then
        		echo "KStars is running."
	  		cd ${HOME}/.local/share/astropi/bin		# Go to app directory
  			python parking.py				# Launch parking script
    		else
        		echo "KStars is not running."
    		fi
    		sleep $interval
	done		
	exit 0
fi
