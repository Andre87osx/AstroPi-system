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

while true; do
   if [[ $perc_used -ge $allert_space || $free_space -ge $min_free_space ]]; then
      # Available memory conditions are NOT respected
      echo "STOP START KStars - AstroPi used_disk ${perc_used}% free_space ${free_space}GB"
      zenity --warning --width=400 --height=200 --text "<b>Minimum free disk space requirements are not met!</b>
      \nYou have used ${perc_used}% and have ${free_space}GB free\n<b>Please do disk cleanup</b>"
      exit=1 && break
      else
      # Available memory conditions are met
      echo "Start KStars - AstroPi used_disk ${perc_used}% free_space ${free_space}GB"
      (kstars &) && exit=0 && break
   fi
done
# Be careful while KStars is started
sleep 10s

# Chk exit status
#=========================================================================
if [[ $exit -eq 1 ]]; then
   # Exit script launcher with exit status error
   exit 1
fi

# Check the PID of kstars AstroPi
#=========================================================================
appname=kstars
app_pid=$(pidof "$appname")
if [[ "$app_pid" == "" ]]; then
   echo "FAILURE: PID is empty"
   exit 1
fi

while : ; do
   chkpid=$(pidof "$appname")
   if [[ "${app_pid}" == "${chkpid}" ]] ; then
      # KStars - AstroPi works
      # Wait for next check
      sleep 300s
      else
         if [[ "$chkpid" == "" ]]; then
            echo "KStars- AstroPi is closed by User"
            break;
         else
            echo "FAILURE: KStars- AstroPi crashed. The telescope will be parked and the INDI services stopped"
            ${Script_Dir} | python parking.py
            break;
         fi
   fi
done
