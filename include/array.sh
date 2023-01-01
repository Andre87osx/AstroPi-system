#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | |  (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########
# rev 1.6 april 2022

# Create version of AstroPi
majorRelease=1								# Major Release
minorRelease=6								# Minor Release
AstroPi_v=${majorRelease}.${minorRelease}	# Actual Stable Release
KStars_v=3.5.4v1.6							# Based on KDE Kstrs v.3.5.4
Indi_v=1.9.1								# Based on INDI 1.9.1 Core

# Get width and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# GUI windows width and height
W=$(( SCREEN_WIDTH / 5 ))
H=$(( SCREEN_HEIGHT / 3 ))
Wprogress=$(( SCREEN_WIDTH / 5 ))

W_Title="AstroPi System v${AstroPi_v}"
W_err_generic="<b>Something went wrong...</b>\nContact support at
<b>https://github.com/Andre87osx/AstroPi-system/issues</b>"

# System full info, linux version and aarch
sysinfo=$(uname -sonmr)

# Disk usage
diskUsagePerc=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $5}')
diskUsageFree=$(df -h --type=ext4 | awk '$1=="/dev/root"{print $4}')