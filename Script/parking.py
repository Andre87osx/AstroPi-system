#!/usr/bin/env python
# -*- coding: utf-8 -*-
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
# KStars AstroPi launcher and monitor

import gobject
import os
import time

gobject.threads_init()

from dbus import glib
glib.init_threads()

# Create a session bus.
import dbus
bus = dbus.SessionBus()

# Create an object that will proxy for a particular remote object.
remote_object = bus.get_object("org.kde.kstars", # Connection name
                               "/KStars/INDI" # Object's path
                              )

# Get INDI interface
iface = dbus.Interface(remote_object, 'org.kde.kstars.INDI')

# Set here all the drivers you want to try to connect
myDriver = [ "indi_eqmod_mount" ]

# Start INDI devices
iface.start("7624", myDriver)

print "Waiting for INDI devices..."

# Create array for received ALL devices
devices = []

while True:
    devices = iface.getDevices()
    if (len(devices) < len(myDriver)):
        time.sleep(1)
    else:
        break;

print "We received the following devices from AstroPi :"

for device in devices:
    print(device)

# Need to find ONLY mount
# List of word corrisponging a mount (add MOUNT NAME)
search_words = ['telescope', 'Telescope', 'mount', 'Mount', 'EQ']

mymount = ''
found = False
for device in devices:
    for word in search_words:
        if word in device:
            mymount = device
            found = True
            break
    if found:
        break

print "Found %s as a mount"%(mymount)
print "Establishing connection to %s"%(mymount)

# Set connect switch to ON to connect the mount
iface.setSwitch(mymount, "CONNECTION", "CONNECT", "On")
# Send the switch to INDI server so that it gets processed by the driver
iface.sendProperty(mymount, "CONNECTION")

# Wait until mount are connected
telescopeState = "Busy"
while True:
    telescopeState = iface.getPropertyState(mymount, "CONNECTION")
    if (telescopeState != "Ok"):
        time.sleep(1)
    else:
        break

print "Connection to %s is established."%(mymount)
print "Commanding telescope to slew to coordinates of default HOME position..."

# Set Telescope RA,DEC coords in JNOW
iface.setNumber(mymount, "EQUATORIAL_EOD_COORD", "RA", 1.300)
iface.setNumber(mymount, "EQUATORIAL_EOD_COORD", "DEC", 89.369)
iface.sendProperty(mymount, "EQUATORIAL_EOD_COORD")

# Wait until slew is done
telescopeState = "Busy"
while True:
    telescopeState = iface.getPropertyState(mymount, "EQUATORIAL_EOD_COORD")
    if (telescopeState != "Ok"):
        time.sleep(1)
    else:
        break

print "Telescope slew is complete, now is in HOME position"

# Stop mount traking
print "Stop Mount tracking..."
iface.setSwitch(mymount, "TELESCOPE_ABORT_MOTION", "ABORT_MOTION", "On")
# Send the switch to INDI server so that it gets processed by the driver
iface.sendProperty(mymount, "TELESCOPE_ABORT_MOTION")

iface.setSwitch(mymount, "TELESCOPE_PARK_OPTION", "PARK_DEFAULT", "On")
# Send the switch to INDI server so that it gets processed by the driver
iface.sendProperty(mymount, "TELESCOPE_PARK_OPTION")

iface.setSwitch(mymount, "TELESCOPE_PARK", "PARK", "On")
# Send the switch to INDI server so that it gets processed by the driver
iface.sendProperty(mymount, "TELESCOPE_PARK")

# Wait until slew is done
telescopeState = "Busy"
while True:
    telescopeState = iface.getPropertyState(mymount, "EQUATORIAL_EOD_COORD")
    if (telescopeState != "Ok"):
        time.sleep(1)
    else:
        break;

# Stop INDI server
iface.stop("7624")
