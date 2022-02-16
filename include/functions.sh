#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

# Create version of AstroPi
majorRelease=1									# Major Release
minorRelease=5									# Minor Release
AstroPi_v=${majorRelease}.${minorRelease}		# Actual Stable Release
KStars_v=3.5.4v1.5								# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.1									# Based on INDI 1.9.1 Core

# Create next AstoPi versions
function next_v()
{
	#//FIXME
	next_AstroPi_v=("${AstroPi_v%.*}.$((${AstroPi_v##*.}+1))")
}

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# New width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# Ask super user password.
function ask_pass()
{
	ask_pass=$( zenity --password  --width=${W} --title="${W_Title}" )
	if [ ${ask_pass} ]; then
		# User write password and press OK
		# Makes sure that the sudo user password matches
		until $( echo "${ask_pass}" | sudo -S echo '' 2>/dev/null ); do
    	    zenity --warning --text="<b>WARNING! The user password not matches...</b>
			\nTry again or sign out" --width=${W} --title="${W_Title}"
			if password=$( zenity --password  --width=${W} --title="${W_Title}" ); then break; else exit 0; fi
		done
	else
		# User press CANCEL button
		# Quit script
		exit 0
	fi
}
