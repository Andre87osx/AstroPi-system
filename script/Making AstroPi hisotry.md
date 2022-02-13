```
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
```

# AstroPi Making Guide for expert #
## This guide is not for beginners, requires the use of the terminal and is made very superficially assuming that the user has linux and bash bases ##
### To download the already pre-made version follow the link and the guide to the installation of the already complete and working system ###

### - Download Raspberry Pi imager
https://www.raspberrypi.org/software/
choose reccomanded and flash your SD (for AstroPi choose an 128 GB micro SD XC for best performances)

### - Insert SD in your pc and create in BOOT partition one new file without extension called "ssh" and one new file called "wpa_supplicant.conf"
Edit with text edit the new file "wpa_supplicant.conf" and past the code (attention fill out SSID and PSK with your wifi data):

```
##############################################
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=IT

network={
    ssid="YOUR_SSID"
    psk="YOUR_WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}
##############################################
```

### - Eject the SD from PC and put in your raspberry and power on

### - Install putty in your PC
https://putty.it.uptodown.com/windows 
connnect to host "raspberrypi"
Login woth user "pi" and password "raspberry"
run "sudo raspi-config"
In interfaces option set VNC to ON
In display opzion choose MOD 82
In raspi config set memory video to 128mb
In advanced optiont expand yuor file system (very important)
reboot

### - In your PC install VNC viewer and connect to AstroPi
https://www.realvnc.com/en/connect/download/viewer/
connect via VNC using "raspberrypi" with host (user "pi" password "raspberry")
Follow the initial raspberry pi os configuaration 
Change default pi password to "astropi" in raspi-config o in terminal

### - Add new user and password for security and better ekos performance
``` 
sudo adduser astropi
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi,lpadmin astropi
sudo su - astropi
sudo pkill -u pi
sudo deluser pi
sudo deluser -remove-home pi

```

### - Change the pi entry (or whichever usernames have superuser rights) to:
```
sudo nano /etc/sudoers.d/010_pi-nopasswd
# find the followink and make the change

pi ALL=(ALL) NOPASSWD: ALL
to
astropi ALL=(ALL) PASSWD: ALL
```

### - Grant direct access to the desktop to the new user
```
sudo nano /etc/lightdm/lightdm.conf
find the line with 
#autologin-user=
change it to
autologin-user=astropi (no comment #)
```

### - Change the hostname so we can connect with VNC even without knowing which IP we have
```
sudo nano /etc/hostname
sudo nano /etc/hosts
```

### - Create link to AstroPi git for future upgrade and mantenance
```
cd $HOME
mkdir Astrophoto
git clone https://github.com/Andre87osx/AstroPi-system.git
cd AstroPi-system
git config credential.helper store
cd
mv $HOME/AstroPi-system $HOME/.AstroPi-system
git -C $HOME/.AstroPi-system pull
chmod +x $HOME/.AstroPi-system/Script/*.sh
```

### Create the app icon in home folder
```
cat > $HOME/AstroPi-system.desktop <<- EOF
[Desktop Entry]
Type=Application
Name=AstroPi-system
Name[en_GB]=AstroPi-system
Name[it_IT]=AstroPi-system
GenericName=AstroPi-system
GenericName[en_GB]=AstroPi-system
Comment=Update AstroPi and application
Comment[en_GB]=Update AstroPi and application
Icon=/usr/share/icons/Adwaita/scalable/emblems/emblem-system-symbolic.svg
Exec=/home/astropi/.Update.sh
NotShowIn=GNOME;XFCE;
StartupNotify=true
Categories=Utility;
NoDisplay=false
EOF
```

- And create the app script
```
cat > $HOME/.Update.sh <<- EOF
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
cd /home/astropi/.AstroPi-system
echo "$password" | sudo -S git reset --hard
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
EOF
```
```
sudo chmod +x $HOME/.Update.sh
```

### Install samba to make astropi visible on the network of your pc's and download the photos captured with comfort
```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install samba samba-common-bin
```

- Edit samba configuration, and at bottom of the file add the followin
```
sudo nano /etc/samba/smb.conf
```
Past this
```
[global]
netbios name = AstroPi
server string = The AstroPi File Sharing
workgroup = WORKGROUP

[HOMEPI]
path = /home/Astrophoto
comment = No comment
writeable=Yes
create mask=0777
directory mask=0777
public=no
```

- Crate samba account and password (for semplicity put "astropi" for all)
```
sudo smbpasswd -a astropi
sudo service smbd restart
```

### - Install autohotspot service (full guide and rights https://www.raspberryconnect.com/projects/65-raspberrypi-hotspot-accesspoints/158-raspberry-pi-auto-wifi-hotspot-switch-direct-connection)
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install hostapd
sudo apt-get install dnsmasq
sudo systemctl unmask hostapd
sudo systemctl disable hostapd
sudo systemctl disable dnsmasq
```

- Edit hostpad
```
sudo nano /etc/hostapd/hostapd.conf
```

Past this
```
################################
#2.4GHz setup wifi 80211 b,g,n
interface=wlan0
driver=nl80211
ssid=AstroPi
hw_mode=g
channel=8
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=1234567890
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP TKIP
rsn_pairwise=CCMP

#80211n - Change GB to your WiFi country code
country_code=IT
ieee80211n=1
ieee80211d=1
##################################
```
```
sudo nano /etc/default/hostapd
```
Change:
#DAEMON_CONF=""
to
DAEMON_CONF="/etc/hostapd/hostapd.conf"

Check the DAEMON_OPTS="" is preceded by a #, so is #DAEMON_OPTS=""

```
sudo nano /etc/dnsmasq.conf
```

Add this at the bottom
```
#############################
#AutoHotspot Config
#stop DNSmasq from using resolv.conf
no-resolv
#Interface to use
interface=wlan0
bind-interfaces
dhcp-range=10.0.0.50,10.0.0.150,12h
###############################
```

- Edit interfaces
```
sudo nano /etc/network/interfaces
```

Check if only are present this line

```
# interfaces(5) file used by ifup(8) and ifdown(8) 
# Please note that this file is written to be used with dhcpcd 
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf' 
# Include files from /etc/network/interfaces.d: 
source-directory /etc/network/interfaces.d 
```
```
sudo nano /etc/dhcpcd.conf
```

Add at the bottom

```
nohook wpa_supplicant
```
```
sudo nano /etc/systemd/system/autohotspot.service
```
Past this

```
##################################
[Unit]
Description=Generates an internet Hotspot
After=multi-user.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/autohotspot
Environment=DISPLAY=:0
[Install]
WantedBy=multi-user.target

#################################
```

```
sudo systemctl enable autohotspot.service
```

```
sudo nano /usr/bin/autohotspot
```
Past this
```
#################################
#!/bin/bash
#version 0.961-N/HS

#You may share this script on the condition a reference to RaspberryConnect.com 
#must be included in copies or derivatives of this script. 

#A script to switch between a wifi network and a non internet routed Hotspot
#Works at startup or with a seperate timer or manually without a reboot
#Other setup required find out more at
#http://www.raspberryconnect.com

wifidev="wlan0" #device name to use. Default is wlan0.
#use the command: iw dev ,to see wifi interface name 

IFSdef=$IFS
cnt=0
#These four lines capture the wifi networks the RPi is setup to use
#wpassid=$(awk '/ssid="/{ print $0 }' /etc/wpa_supplicant/wpa_supplicant.conf | awk -F'ssid=' '{ print $2 }' | sed 's/\r//g'| awk 'BEGIN{ORS=","} {print}' | sed 's/\"/''/g' | sed 's/,$//')
#IFS=","
#ssids=($wpassid)
#IFS=$IFSdef #reset back to defaults


#Note:If you only want to check for certain SSIDs
#Remove the # in in front of ssids=('mySSID1'.... below and put a # infront of all four lines above
# separated by a space, eg ('mySSID1' 'mySSID2')
#ssids=('mySSID1' 'mySSID2' 'mySSID3')

#Enter the Routers Mac Addresses for hidden SSIDs, seperated by spaces ie 
#( '11:22:33:44:55:66' 'aa:bb:cc:dd:ee:ff' ) 
mac=('11:22:33:44:55:66')

ssidsmac=("${ssids[@]}" "${mac[@]}") #combines ssid and MAC for checking

createAdHocNetwork()
{
    echo "Creating Hotspot"
    ip link set dev "$wifidev" down
    ip a add 10.0.0.5/24 brd + dev "$wifidev"
    ip link set dev "$wifidev" up
    dhcpcd -k "$wifidev" >/dev/null 2>&1
    systemctl start dnsmasq
    systemctl start hostapd
}

KillHotspot()
{
    echo "Shutting Down Hotspot"
    ip link set dev "$wifidev" down
    systemctl stop hostapd
    systemctl stop dnsmasq
    ip addr flush dev "$wifidev"
    ip link set dev "$wifidev" up
    dhcpcd  -n "$wifidev" >/dev/null 2>&1
}

ChkWifiUp()
{
	echo "Checking WiFi connection ok"
        sleep 20 #give time for connection to be completed to router
	if ! wpa_cli -i "$wifidev" status | grep 'ip_address' >/dev/null 2>&1
        then #Failed to connect to wifi (check your wifi settings, password etc)
	       echo 'Wifi failed to connect, falling back to Hotspot.'
               wpa_cli terminate "$wifidev" >/dev/null 2>&1
	       createAdHocNetwork
	fi
}


chksys()
{
    #After some system updates hostapd gets masked using Raspbian Buster, and above. This checks and fixes  
    #the issue and also checks dnsmasq is ok so the hotspot can be generated.
    #Check Hostapd is unmasked and disabled
    if systemctl -all list-unit-files hostapd.service | grep "hostapd.service masked" >/dev/null 2>&1 ;then
	systemctl unmask hostapd.service >/dev/null 2>&1
    fi
    if systemctl -all list-unit-files hostapd.service | grep "hostapd.service enabled" >/dev/null 2>&1 ;then
	systemctl disable hostapd.service >/dev/null 2>&1
	systemctl stop hostapd >/dev/null 2>&1
    fi
    #Check dnsmasq is disabled
    if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service masked" >/dev/null 2>&1 ;then
	systemctl unmask dnsmasq >/dev/null 2>&1
    fi
    if systemctl -all list-unit-files dnsmasq.service | grep "dnsmasq.service enabled" >/dev/null 2>&1 ;then
	systemctl disable dnsmasq >/dev/null 2>&1
	systemctl stop dnsmasq >/dev/null 2>&1
    fi
}


FindSSID()
{
#Check to see what SSID's and MAC addresses are in range
ssidChk=('NoSSid')
i=0; j=0
until [ $i -eq 1 ] #wait for wifi if busy, usb wifi is slower.
do
        ssidreply=$((iw dev "$wifidev" scan ap-force | egrep "^BSS|SSID:") 2>&1) >/dev/null 2>&1 
        #echo "SSid's in range: " $ssidreply
	printf '%s\n' "${ssidreply[@]}"
        echo "Device Available Check try " $j
        if (($j >= 10)); then #if busy 10 times goto hotspot
                 echo "Device busy or unavailable 10 times, going to Hotspot"
                 ssidreply=""
                 i=1
	elif echo "$ssidreply" | grep "No such device (-19)" >/dev/null 2>&1; then
                echo "No Device Reported, try " $j
		NoDevice
        elif echo "$ssidreply" | grep "Network is down (-100)" >/dev/null 2>&1 ; then
                echo "Network Not available, trying again" $j
                j=$((j + 1))
                sleep 2
	elif echo "$ssidreply" | grep "Read-only file system (-30)" >/dev/null 2>&1 ; then
		echo "Temporary Read only file system, trying again"
		j=$((j + 1))
		sleep 2
	elif echo "$ssidreply" | grep "Invalid exchange (-52)" >/dev/null 2>&1 ; then
		echo "Temporary unavailable, trying again"
		j=$((j + 1))
		sleep 2
	elif echo "$ssidreply" | grep -v "resource busy (-16)"  >/dev/null 2>&1 ; then
               echo "Device Available, checking SSid Results"
		i=1
	else #see if device not busy in 2 seconds
                echo "Device unavailable checking again, try " $j
		j=$((j + 1))
		sleep 2
	fi
done

for ssid in "${ssidsmac[@]}"
do
     if (echo "$ssidreply" | grep -F -- "$ssid") >/dev/null 2>&1
     then
	      #Valid SSid found, passing to script
              echo "Valid SSID Detected, assesing Wifi status"
              ssidChk=$ssid
              return 0
      else
	      #No Network found, NoSSid issued"
              echo "No SSid found, assessing WiFi status"
              ssidChk='NoSSid'
     fi
done
}

NoDevice()
{
	#if no wifi device,ie usb wifi removed, activate wifi so when it is
	#reconnected wifi to a router will be available
	echo "No wifi device connected"
	wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
	exit 1
}

chksys
FindSSID

#Create Hotspot or connect to valid wifi networks
if [ "$ssidChk" != "NoSSid" ] 
then
       if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
       then #hotspot running and ssid in range
              KillHotspot
              echo "Hotspot Deactivated, Bringing Wifi Up"
              wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
              ChkWifiUp
       elif { wpa_cli -i "$wifidev" status | grep 'ip_address'; } >/dev/null 2>&1
       then #Already connected
              echo "Wifi already connected to a network"
       else #ssid exists and no hotspot running connect to wifi network
              echo "Connecting to the WiFi Network"
              wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
              ChkWifiUp
       fi
else #ssid or MAC address not in range
       if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
       then
              echo "Hostspot already active"
       elif { wpa_cli status | grep "$wifidev"; } >/dev/null 2>&1
       then
              echo "Cleaning wifi files and Activating Hotspot"
              wpa_cli terminate >/dev/null 2>&1
              ip addr flush "$wifidev"
              ip link set dev "$wifidev" down
              rm -r /var/run/wpa_supplicant >/dev/null 2>&1
              createAdHocNetwork
       else #"No SSID, activating Hotspot"
              createAdHocNetwork
       fi
fi

########################################
```

```
sudo chmod +x /usr/bin/autohotspot
```

```
sudo systemctl enable autohotspot.service
```

### Install ASTAP and catalogue (photometry catalogs are also included)
```
cd $HOME
wget https://deac-fra.dl.sourceforge.net/project/astap-program/linux_installer/astap_armhf.deb
wget https://deac-fra.dl.sourceforge.net/project/astap-program/star_databases/h17_star_database_mag17_astap.deb
wget https://pilotfiber.dl.sourceforge.net/project/astap-program/star_databases/v17_star_database_mag17_colour_astap.deb
# INSTALL THEM AND REMOOVE THE .DEB FILE
```

### Install OA CAPTURE
wget http://www.openastroproject.org/wp-content/uploads/2020/12/raspbian-10/oacapture_1.8.0-1_armhf.deb
INSTALL AND THEN DELETE DEB FILE

### Make a img backup
########################################################
BACKUP CLONE SD IN 16GB
########################################################

- Install Psrink
```
wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
sudo chmod +x pishrink.sh
sudo mv pishrink.sh /usr/local/bin
```

- Check the mount point path of your USB drive by entering 
```
lsblk
```
- Copy all your data to an img file by using the dd command. 
```
sudo dd if=/dev/mmcblk0 of=/media/astropi/BCK/AstroPi_last.img bs=1M status=progress
```

- Navigate to the USB drive's root directory.
```
cd /media/astropi/BCK
```
- Use pishrink with the -z parameter, which zips your image up with gzip. 
```
sudo pishrink.sh -z AstroPi_last.img
```



if [ -d "$WORKING_DIR" ]; then rm -Rf $WORKING_DIR; fi


##############################################################
IMG 001 created
##############################################################

##############################################################
IMG 002 created 26/03/2021
##############################################################

pcmanfm --set-wallpaper="/home/astropi/.AstroPi-system/Loghi&background/AstroPi_wallpaper.jpg"

X MOD LX PANNEL 
/home/astropi/.config/lxpanel/LXDE-pi/panels

##############################################################
Switching the kernel to 64-bit
Prerequisites
This assumes you are on the latest Raspbian Buster with all the updates installed.

You can check whether you’re on Buster or not with:

lsb_release -a
Which will output something like:

Distributor ID: Raspbian
Description:    Raspbian GNU/Linux 10 (buster)
Release:        10
Codename:       buster
And you want to install all updates with:

sudo apt update
sudo apt upgrade
Now to verify the 64-bit kernel exists:

ls /boot/kernel8.img
If it exists, it will simply print out the path to it. Otherwise, it will tell you: No such file or directory.

Switching
Now that we made sure we’re up to date and the 64-bit kernel exists, let’s switch to it!

Edit /boot/config.txt with your favorite editor, for example nano:

sudo nano /boot/config.txt
Go to the very end of the file and add this line:

arm_64bit=1
Hit CTRL + X, confirm to save with Y, and hit enter twice.

Now reboot to boot with the new, 64-bit kernel!

sudo systemctl reboot
Verifying
Verify you are running the 64-bit kernel with:

uname -a
Which will output something like:

Linux raspberrypi 4.19.97-v8+ #1294 SMP PREEMPT Thu Jan 30 13:27:08 GMT 2020 aarch64 GNU/Linux
