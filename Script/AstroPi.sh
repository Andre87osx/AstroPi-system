#!/bin/bash                                              
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

ans=$(zenity  --list  --title="AstroPi System" --width=350 --height=250 --cancel-label=Exit --hide-header --text "Choose an option or exit" --radiolist  --column "Pick" --column "Option" TRUE "Check for update" FALSE "Setup my WiFi" FALSE "Disable/Enable AstroPi hotspot" FALSE "Install/Upgrade Kstrs AstroPi"); 
if [ "$ans" == "Check for update" ];
then 
 (
# =================================================================
echo "5"
echo "# Preparing update" ; sleep 2
FILE=/etc/apt/sources.list.d/astroberry.list
if [ -f "$FILE" ]; then
echo "$password" | sudo -S rm /etc/apt/sources.list.d/astroberry.list
fi
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>sources.list.d</b>\n. Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S sh -c 'echo 256 > /sys/module/usbcore/parameters/usbfs_memory_mb'
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>usbfs_memory_mb.</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "25"
echo "# Run Software Updater..." ; sleep 2
echo "$password" | sudo -S apt-get update && sudo apt-get -y dist-upgrade && sudo apt -y full-upgrade
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>Updating system AstroPi</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "50"
echo "# Install dependencies..." ; sleep 2
# echo "$password" | sudo -S apt-get -y install build-essential cmake git libeigen3-dev libcfitsio-dev zlib1g-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev
# (( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "75"
echo "# Remove unnecessary libraries" ; sleep 2
echo "$password" | sudo -S apt -y autoremove
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>APT autoremove</b>.\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "99"
echo "# Yet a moment" ; sleep 2
# Attualmente vuoto!

# =================================================================
echo "# All finished." ; sleep 2
echo "100"
# Attualmente vuoto!

) |
zenity --progress \
  --title="AstroPi System" \
  --text="First Task." \
  --percentage=1 \
  --auto-close \
  --width=300 \
  --auto-kill

exit_status=$?
if [ $exit_status -eq 1 ]; then 
zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
else
zenity --info --text="All updates have been successfully installed" --width=300 --title="AstroPi System" && exit 0
fi

elif [ "$ans" == "Setup my WiFi" ];
then 
# Setup WiFi in wpa_supplicant
#######################################
WIFI=`zenity --forms --width=400 --height=200 --title="Setup WiFi in wpa_supplicant" --text="Add new WiFi network" \
  --add-entry="Enter the SSID of the wifi network to be added." \
  --add-password="Enter the password of selected wifi network" `
SSID=`echo $WIFI | cut -d'|' -f1`
PSK=`echo $WIFI | cut -d'|' -f2`

echo "$password" | sudo -S cat >> /etc/wpa_supplicant/wpa_supplicant.conf <<- EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=IT
network={
  ssid="$SSID"
  scan_ssid=1
  psk="$PSK"
  key_mgmt=WPA-PSK
}
EOF
echo "$password" | sudo -S cat >> /etc/wpa_supplicant/wpa_supplicant.conf <<- EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=IT
network={
  ssid="$SSID"
  scan_ssid=1
  psk="$PSK"
  key_mgmt=WPA-PSK
}
EOF
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
exit 0

elif [ "$ans" == "Disable/Enable AstroPi hotspot" ];
then
# Disable AstroPi auto hotspot
#######################################
  if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ];
  then
    echo "$password" | sudo -S systemctl disable autohotspot
    echo "$password" | sudo -S sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
    zenity --info --width=300 --height=200 --text "The auto hotspot service is now <b>disabled</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi"
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    exit 0
  else
# Enable AstroPi auto hotspot
#######################################  
    echo "$password" | sudo -S echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf
    echo "$password" | sudo -S systemctl enable autohotspot.service
    zenity --info --width=300 --height=200 --text " The auto hotspot service is now <b>active</b>. In the absence of wifi, hotspots will be generated directly from AstroPi"
(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    exit 0
fi
elif [ "$ans" == "Install/Upgrade Kstrs AstroPi" ];
then
    zenity --info --width=400 --height=200 --text "La compilazione di Kstar richiede almeno 90min attendere fino al completamento"
     (
# =================================================================
echo "5"
echo "# Install dependencies..." ; sleep 2
echo "$password" | sudo -S apt-get -y install build-essential cmake git libeigen3-dev libcfitsio-dev zlib1g-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di Kstars\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S apt-get install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S apt -y install git cmake qt5-default libcfitsio-dev libgsl-dev wcslib-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "15"
echo "# Controllo INDI Core" ; sleep 2
PROJECTS_DIR=$HOME/Projects
if [ -d "$PROJECTS_DIR" ]; then rm -Rf $PROJECTS_DIR; fi
mkdir -p $HOME/Projects
cd $HOME/Projects
git clone --depth 1 https://github.com/indilib/indi.git
mkdir -p $HOME/Projects/indi-cmake
cd $HOME/Projects/indi-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $HOME/Projects/indi
(( $? != 0 )) && zenity --error --text="Errore CMake INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "25"
echo "# Installo / Aggiorno INDI Core" ; sleep 2
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Instal INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "50"
echo "# Installo / Aggiorno Stellarsolver" ; sleep 2
cd $HOME/Projects
git clone https://github.com/rlancaste/stellarsolver.git
mkdir -p $HOME/Projects/Stellarsolver-cmake
cd $HOME/Projects/Stellarsolver-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo $HOME/Projects/stellarsolver
make -j $(expr $(nproc) + 2)
echo "$password" | sudo -S make install

# =================================================================
echo "75"
echo "# Controllo Kstars AstroPi" ; sleep 2
mkdir $HOME/Projects/kstars-cmake
cd $HOME/Projects/kstars-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo $HOME/.AstroPi-system/kstars-astropi
# (( $? != 0 )) && zenity --error --text="Errore CMake  Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "99"
echo "# installo / Aggiorno Kstars AstroPi" ; sleep 2
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Install Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "# All finished." ; sleep 2
echo "100"
echo "$password" | sudo -S rm -rf $HOME/Projects
) |
zenity --progress \
  --title="AstroPi System" \
  --text="First Task." \
  --percentage=0 \
  --auto-close \
  --width=300 \
  --auto-kill

exit_status=$?
if [ $exit_status -eq 1 ]; then 
zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
else
zenity --info --text="All updates have been successfully installed" --width=300 --title="AstroPi System" && exit 0
fi
fi

(( $? != 0 )) && zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
exit 0
