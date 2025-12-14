#!/usr/bin/env python
# -*- coding: utf-8 -*-
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | |  (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
# KStars AstroPi emergency telescope parking script

import gobject
import os
import sys
import time

gobject.threads_init()

from dbus import glib
glib.init_threads()

import dbus

# Configuration
INDI_PORT = "7624"
DRIVER_NAMES = ["indi_eqmod_telescope"]
MAX_DEVICE_WAIT = 30  # seconds
# Primary: eqmod specific, Secondary: generic mount keywords for fallback
MOUNT_KEYWORDS = ['eqmod', 'EQMOD', 'Eqmod', 'eqmod_telescope', 'telescope', 'Telescope', 'mount', 'Mount', 'EQ']

def log(message):
    """Print timestamped log message"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def connect_to_kstars():
    """Connect to KStars via DBUS, return interface or None"""
    try:
        log("Connecting to KStars via DBUS...")
        bus = dbus.SessionBus()
        remote_object = bus.get_object("org.kde.kstars", "/KStars/INDI")
        iface = dbus.Interface(remote_object, 'org.kde.kstars.INDI')
        log("KStars DBUS connection established")
        return iface
    except dbus.exceptions.DBusException as e:
        log(f"ERROR: Cannot connect to KStars via DBUS: {e}")
        return None
    except Exception as e:
        log(f"ERROR: Unexpected error connecting to KStars: {e}")
        return None

def start_indi_devices(iface):
    """Start INDI devices and wait for them to load"""
    try:
        log(f"Starting INDI on port {INDI_PORT} with driver(s): {DRIVER_NAMES}")
        iface.start(INDI_PORT, DRIVER_NAMES)
    except Exception as e:
        log(f"ERROR: Failed to start INDI devices: {e}")
        return False
    
    log("Waiting for INDI devices to load...")
    start_time = time.time()
    
    while True:
        try:
            devices = iface.getDevices()
            log(f"Found {len(devices)} device(s): {devices}")
            
            if len(devices) >= len(DRIVER_NAMES):
                log("All INDI devices loaded successfully")
                return True
            
            # Check timeout
            if time.time() - start_time > MAX_DEVICE_WAIT:
                log(f"ERROR: Timeout waiting for INDI devices (waited {MAX_DEVICE_WAIT}s)")
                return False
            
            time.sleep(1)
        except Exception as e:
            log(f"ERROR: Failed to get INDI devices: {e}")
            if time.time() - start_time > MAX_DEVICE_WAIT:
                return False
            time.sleep(1)

def find_mount(iface, devices):
    """Find connected mount device - prioritize already connected mount"""
    if not devices:
        log("ERROR: No devices available")
        return None
    
    # Step 1: Look for ALREADY CONNECTED mount (most reliable)
    log("Searching for already connected mount...")
    for device in devices:
        try:
            state = iface.getPropertyState(device, "CONNECTION")
            if state == "Ok":
                # Check if it matches eqmod keywords
                device_lower = device.lower()
                is_eqmod = any(keyword.lower() in device_lower for keyword in MOUNT_KEYWORDS[:4])
                if is_eqmod:
                    log(f"Found CONNECTED EQMOD mount: {device} (state: {state})")
                    return device
                else:
                    log(f"Found connected mount: {device} (state: {state})")
                    return device
        except Exception as e:
            log(f"DEBUG: Could not check {device}: {e}")
            continue
    
    # Step 2: Look for eqmod driver specifically (not yet connected)
    log("No connected mount found, searching for EQMOD device...")
    eqmod_device = None
    for device in devices:
        device_lower = device.lower()
        for keyword in MOUNT_KEYWORDS[:4]:  # eqmod keywords only
            if keyword.lower() in device_lower:
                log(f"Found EQMOD device (not connected): {device}")
                eqmod_device = device
                break
        if eqmod_device:
            break
    
    if eqmod_device:
        return eqmod_device
    
    # Step 3: Look for any mount with generic keywords
    log("No EQMOD found, searching for any mount device...")
    for device in devices:
        device_lower = device.lower()
        for keyword in MOUNT_KEYWORDS[4:]:  # generic keywords
            if keyword.lower() in device_lower:
                log(f"Found generic mount: {device}")
                return device
    
    # Step 4: Fallback - if nothing matched, list available devices for debugging
    log(f"WARNING: No matching mount device found")
    log(f"Available devices: {devices}")
    log("Available device connection states:")
    for device in devices:
        try:
            state = iface.getPropertyState(device, "CONNECTION")
            log(f"  - {device} (connection state: {state})")
        except:
            log(f"  - {device} (state unknown)")
    
    # Try to use first available device as last resort
    if devices:
        log(f"Using first available device as last resort: {devices[0]}")
        return devices[0]
    
    return None

def connect_mount(iface, mount):
    """Connect to the mount"""
    try:
        log(f"Connecting to mount: {mount}")
        iface.setSwitch(mount, "CONNECTION", "CONNECT", "On")
        iface.sendProperty(mount, "CONNECTION")
        
        # Wait for connection
        start_time = time.time()
        while True:
            state = iface.getPropertyState(mount, "CONNECTION")
            if state == "Ok":
                log(f"Mount {mount} connected successfully")
                return True
            elif time.time() - start_time > 10:  # 10 second timeout
                log(f"ERROR: Timeout connecting to mount (state was {state})")
                return False
            time.sleep(0.5)
    except Exception as e:
        log(f"ERROR: Failed to connect mount: {e}")
        return False

def stop_mount_motion(iface, mount):
    """Stop any current mount motion"""
    try:
        log("Stopping mount motion...")
        iface.setSwitch(mount, "TELESCOPE_ABORT_MOTION", "ABORT_MOTION", "On")
        iface.sendProperty(mount, "TELESCOPE_ABORT_MOTION")
        time.sleep(1)
        return True
    except Exception as e:
        log(f"ERROR: Failed to stop mount motion: {e}")
        return False

def park_mount(iface, mount):
    """Send mount to park position"""
    try:
        log("Sending mount to park position...")
        iface.setSwitch(mount, "TELESCOPE_PARK", "PARK", "On")
        iface.sendProperty(mount, "TELESCOPE_PARK")
        
        # Wait for park to complete
        start_time = time.time()
        while True:
            state = iface.getPropertyState(mount, "TELESCOPE_PARK")
            if state == "Ok":
                log("Mount parked successfully!")
                return True
            elif time.time() - start_time > 60:  # 60 second timeout
                log(f"ERROR: Timeout waiting for mount to park (state was {state})")
                return False
            log(f"  Parking in progress... (state: {state})")
            time.sleep(2)
    except Exception as e:
        log(f"ERROR: Failed to park mount: {e}")
        return False

def disconnect_mount(iface, mount):
    """Disconnect from the mount"""
    try:
        log(f"Disconnecting from mount: {mount}")
        iface.setSwitch(mount, "CONNECTION", "DISCONNECT", "On")
        iface.sendProperty(mount, "CONNECTION")
        time.sleep(1)
        return True
    except Exception as e:
        log(f"WARNING: Failed to disconnect mount: {e}")
        return True  # Don't fail on disconnect

def stop_indi(iface):
    """Stop INDI server"""
    try:
        log(f"Stopping INDI server on port {INDI_PORT}")
        iface.stop(INDI_PORT)  # Fixed: use variable, not string "port"
        time.sleep(1)
        return True
    except Exception as e:
        log(f"WARNING: Failed to stop INDI: {e}")
        return True  # Don't fail on INDI stop

def main():
    """Main emergency parking sequence"""
    log("========== TELESCOPE EMERGENCY PARKING SEQUENCE ==========")
    
    # Step 1: Connect to KStars
    iface = connect_to_kstars()
    if iface is None:
        log("CRITICAL: Cannot reach KStars. Cannot proceed with parking.")
        return 1
    
    # Step 2: Start INDI devices
    if not start_indi_devices(iface):
        log("CRITICAL: Failed to start INDI devices.")
        return 1
    
    # Step 3: Get device list and find mount
    try:
        devices = iface.getDevices()
    except Exception as e:
        log(f"CRITICAL: Failed to get devices: {e}")
        return 1
    
    mount = find_mount(iface, devices)
    if not mount:
        log("CRITICAL: Cannot find mount device.")
        return 1
    
    # Step 4: Connect to mount
    if not connect_mount(iface, mount):
        log("WARNING: Failed to connect to mount, attempting to park anyway...")
    
    # Step 5: Stop any motion
    stop_mount_motion(iface, mount)
    
    # Step 6: Park the mount
    if not park_mount(iface, mount):
        log("WARNING: Mount may not be fully parked.")
        # Don't return error - try to disconnect anyway
    
    # Step 7: Disconnect and cleanup
    disconnect_mount(iface, mount)
    stop_indi(iface)
    
    log("========== PARKING SEQUENCE COMPLETE ==========")
    return 0

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        log("Interrupted by user")
        sys.exit(1)
    except Exception as e:
        log(f"FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
