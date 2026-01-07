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

# Function to park the telescope safely
park_telescope() {
	local park_script="${Script_Dir}/parking.py"
	local max_attempts=3
	local attempt=0
	
	echo "EMERGENCY: Attempting to park telescope..."
	
	# Verify parking script exists
	if [[ ! -f "$park_script" ]]; then
		echo "ERROR: parking.py not found at $park_script"
		return 1
	fi
	
	# Try to execute parking script (parking.py uses DBUS, doesn't need GUI)
	while [[ $attempt -lt $max_attempts ]]; do
		((attempt++))
		echo "Parking attempt $attempt/$max_attempts..."
		
		if python "$park_script" > /tmp/parking_log_$$.txt 2>&1; then
			echo "SUCCESS: Telescope parked successfully"
			return 0
		else
			# Check if error is due to kstars not running via DBUS
			if grep -q "org.kde.kstars" /tmp/parking_log_$$.txt 2>/dev/null; then
				echo "KStars DBUS service not accessible, attempt $attempt"
				# Only try to restart kstars if we haven't exceeded attempts
				if [[ $attempt -lt $max_attempts ]]; then
					echo "Attempting to restart kstars for DBUS access..."
					# Start kstars WITHOUT GUI in background (headless mode)
					timeout 30 kstars --silent > /dev/null 2>&1 &
					KSTARS_PID=$!
					sleep 3  # Give kstars time to initialize DBUS service
				fi
			else
				# Some other error in parking script
				echo "ERROR in parking script:"
				cat /tmp/parking_log_$$.txt
			fi
		fi
		
		if [[ $attempt -lt $max_attempts ]]; then
			sleep 2
		fi
	done
	
	# Clean up temp log
	rm -f /tmp/parking_log_$$.txt
	
	echo "ERROR: Failed to park telescope after $max_attempts attempts"
	return 1
}

# Main execution
if kstars > /dev/null 2>&1; then
	# Close the script
	echo "KStars - AstroPi is closed by user correctly"
	exit 0
else
	# KStars crashed - emergency procedure
	echo "FAILURE: KStars crashed. Emergency telescope parking in progress..."
	time=$( date '+%F_%H:%M:%S' )
	
	# Show warning dialog (non-blocking with timeout)
	nohup zenity --warning --width=350 --title="KStars AstroPi - EMERGENCY" \
		--text="<b>KStars AstroPi crashed!</b>
\nEmergency parking sequence started at ${time}.
\n<b>DO NOT POWER OFF THE SYSTEM!</b>
\nThe telescope is being safely parked.
\nThis message will close in 60 seconds.
\nContact support: <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" \
		--timeout=60 > /dev/null 2>&1 &
	
	# Attempt to park the telescope
	if park_telescope; then
		echo "Parking sequence completed successfully at $(date '+%F_%H:%M:%S')"
		exit 0
	else
		echo "ERROR: Parking sequence failed. Check system status manually."
		echo "Mount position may be unsafe. Verify hardware status."
		exit 1
	fi
fi
