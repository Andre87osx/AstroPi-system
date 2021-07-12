#!/bin/bash                                              
#               _             _____ _ 
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) | 
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########
# DECLARE INDI VERSION
INDI_V=1.9.1
######################################
ans=$(zenity  --list  --title="AstroPi System" --width=350 --height=250 --cancel-label=Exit --hide-header --text "Choose an option or exit" --radiolist  --column "Pick" --column "Option" TRUE "Check for update" FALSE "Setup my WiFi" FALSE "Disable/Enable AstroPi hotspot" FALSE "Install/Upgrade INDI and Driver" FALSE "Install/Upgrade Kstars AstroPi"); 
if [ "$ans" == "Check for update" ];
then 
 (
# =================================================================
echo "5"
echo "# Preparing update" ; sleep 2
FILE=/etc/apt/sources.list.d/astroberry.list
if [ ! -f "$FILE" ]; then
wget -O - https://www.astroberry.io/repo/key | sudo apt-key add -
sudo su -c "echo 'deb https://www.astroberry.io/repo/ buster main' > /etc/apt/sources.list.d/astroberry.list"
fi
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>sources.list.d</b>\n. Contact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S sh -c 'echo 256 > /sys/module/usbcore/parameters/usbfs_memory_mb'
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>usbfs_memory_mb.</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S apt-mark hold kstars-bleeding
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>hold kstars-bleeding</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "25"
echo "# Run Software Updater..." ; sleep 2
echo "$password" | sudo -S apt-get update && sudo apt-get -y dist-upgrade && sudo apt -y full-upgrade
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>Updating system AstroPi</b>\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "50"
echo "# Remove unnecessary libraries" ; sleep 2
echo "$password" | sudo -S apt -y autoremove
(( $? != 0 )) && zenity --error --text="Something went wrong in <b>APT autoremove</b>.\nContact support at <b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "75"
echo "# Processing..." ; sleep 2
# Empty

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
  --text="AstroPi System" \
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
echo "$password" | sudo -S rm /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\ncountry=IT\n\nnetwork={\n   ssid=\"$SSID\"\n   scan_ssid=1\n   psk=\"$PSK\"\n   key_mgmt=WPA-PSK\n}\n" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
(( $? != 0 )) && zenity --error --text="Non sono riuscito ad aggiornare i dati. Contatta il supporto\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
zenity --info --width=400 --height=200 --text "La nuova rete WiFi è stata inserita, riavvia il sistema."
exit

elif [ "$ans" == "Disable/Enable AstroPi hotspot" ];
then
# Disable AstroPi auto hotspot
#######################################
  if [ -n "$(grep 'nohook wpa_supplicant' '/etc/dhcpcd.conf')" ];
  then
    echo "$password" | sudo -S systemctl disable autohotspot
    (( $? != 0 )) && zenity --error --text="I couldn't disable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    echo "$password" | sudo -S sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
    (( $? != 0 )) && zenity --error --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    zenity --info --width=300 --height=200 --text "The auto hotspot service is now <b>disabled</b>. Remember to turn it back on if you want to use AstroPi in the absence of WiFi"

  else
# Enable AstroPi auto hotspot
#######################################  
    echo "$password" | sudo -S echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf
    (( $? != 0 )) && zenity --error --text="I couldn't enter the data. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    echo "$password" | sudo -S systemctl enable autohotspot.service
    (( $? != 0 )) && zenity --error --text="I couldn't enable autohotspot. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
    zenity --info --width=300 --height=200 --text " The auto hotspot service is now <b>active</b>. In the absence of wifi, hotspots will be generated directly from AstroPi"
fi

elif [ "$ans" == "Install/Upgrade INDI and Driver" ];
then
     (
# =================================================================
echo "5"
echo "# Install dependencies..." ; sleep 2
echo "$password" | sudo -S apt-get -y install build-essential cmake git libstellarsolver-dev libeigen3-dev libcfitsio-dev zlib1g-dev libindi-dev extra-cmake-modules libkf5plotting-dev libqt5svg5-dev libkf5xmlgui-dev libkf5kio-dev kinit-dev libkf5newstuff-dev kdoctools-dev libkf5notifications-dev qtdeclarative5-dev libkf5crash-dev gettext libnova-dev libgsl-dev libraw-dev libkf5notifyconfig-dev wcslib-dev libqt5websockets5-dev xplanet xplanet-images qt5keychain-dev libsecret-1-dev breeze-icon-theme libqt5datavisualization5-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di Kstars\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
echo "$password" | sudo -S apt-get install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
echo "$password" | sudo -S apt-get -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di INDI Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
echo "$password" | sudo -S apt -y install git cmake qt5-default libcfitsio-dev libgsl-dev wcslib-dev
(( $? != 0 )) && zenity --error --text="Errore nell'installazione delle dipendenze di Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1

# =================================================================
echo "15"
echo "# Checking INDI Core..." ; sleep 2
if [ ! -d $HOME/.Projects ]; then echo "$password" | sudo -S mkdir $HOME/.Projects; fi
if [ -d $HOME/.Projects/indi-"$INDI_V" ]; then echo "$password" | sudo -S rm -rf $HOME/.Projects/indi-"$INDI_V"; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects
echo "$password" | sudo -S wget -c https://github.com/indilib/indi/archive/refs/tags/v"$INDI_V".tar.gz -O - | sudo tar -xz -C $HOME/.Projects
if [ ! -d $HOME/.Projects/indi-cmake ]; then echo "$password" | sudo -S mkdir $HOME/.Projects/indi-cmake; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects/indi-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $HOME/.Projects/indi-"$INDI_V"
(( $? != 0 )) && zenity --error --text="Errore CMake INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Instal INDI Core\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "25"
echo "# Checking INDI 3rd Party Library" ; sleep 2
if [ ! -d $HOME/.Projects ]; then echo "$password" | sudo -S mkdir $HOME/.Projects; fi
if [ -d $HOME/.Projects/indi-3rdparty-"$INDI_V" ]; then echo "$password" | sudo -S rm -rf $HOME/.Projects/indi-3rdparty-"$INDI_V"; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects
echo "$password" | sudo -S wget -c https://github.com/indilib/indi-3rdparty/archive/refs/tags/v"$INDI_V".tar.gz -O - | sudo tar -xz -C $HOME/.Projects
if [ ! -d $HOME/.Projects/indi3rdlib-cmake ]; then echo "$password" | sudo -S  mkdir $HOME/.Projects/indi3rdlib-cmake; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects/indi3rdlib-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug -DBUILD_LIBS=1 $HOME/.Projects/indi-3rdparty-"$INDI_V"
(( $? != 0 )) && zenity --error --text="Errore CMake INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Instal INDI 3rd Party Library\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "50"
echo "# Controllo la versione di INDI 3rd Party Driver" ; sleep 2
if [ ! -d $HOME/.Projects/indi3rd-cmake ]; then echo "$password" | sudo -S mkdir -p $HOME/.Projects/indi3rd-cmake; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects/indi3rd-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $HOME/.Projects/indi-3rdparty-"$INDI_V"
(( $? != 0 )) && zenity --error --text="Errore CMake INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Instal INDI 3rd Party Driver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "75"
echo "# Checking Stellarsolver" ; sleep 2
if [ ! -d $HOME/.Projects ]; then echo "$password" | sudo -S mkdir $HOME/.Projects; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
if [ -d $HOME/.Projects/stellarsolver ]; then echo "$password" | sudo -S rm -rf $HOME/.Projects/stellarsolver; fi
cd $HOME/.Projects
git clone https://github.com/rlancaste/stellarsolver.git
if [ ! -d $HOME/.Projects/stellarsolver-cmake ]; then echo "$password" | sudo -S mkdir $HOME/.Projects/stellarsolver-cmake; fi
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects/stellarsolver-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo $HOME/.Projects/stellarsolver
(( $? != 0 )) && zenity --error --text="Error CMake Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Error Make Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Instal Stellarsolver\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit

# =================================================================
echo "90"
echo "# Quasi fatto!" ; sleep 2

# =================================================================
echo "# All finished." ; sleep 2
echo "100"
) |
zenity --progress \
  --title="AstroPi System" \
  --text="AstroPi System" \
  --percentage=0 \
  --auto-close \
  --width=300 \
  --auto-kill

exit_status=$?
if [ $exit_status -eq 1 ]; then 
zenity --error --text="Something went wrong. Contact support at\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit 1
else
zenity --info --text="All updates have been successfully installed" --width=300 --title="AstroPi System"
exit 0
fi

elif [ "$ans" == "Install/Upgrade Kstars AstroPi" ];
then
    zenity --info --width=400 --height=200 --text "La compilazione di Kstar richiede almeno 30 min attendere fino al completamento"
     (
# =================================================================
echo "5"
echo "# Controllo Kstars AstroPi" ; sleep 2
if [ -d $HOME/.Projects/kstars-cmake ]; then echo "$password" | sudo -S rm -rf $HOME/.Projects/kstars-cmake; fi
echo "$password" | sudo -S mkdir -p $HOME/.Projects/kstars-cmake
echo "$password" | sudo -S chmod 777 -R $HOME/.Projects
cd $HOME/.Projects/kstars-cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo $HOME/.AstroPi-system/kstars-astropi
(( $? != 0 )) && zenity --error --text="Errore CMake  Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
# =================================================================
echo "25"
echo "# installo / Aggiorno Kstars AstroPi" ; sleep 2
make -j $(expr $(nproc) + 2)
(( $? != 0 )) && zenity --error --text="Errore Make Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
# =================================================================
echo "50"
echo "$password" | sudo -S make install
(( $? != 0 )) && zenity --error --text="Errore Make Install Kstars AstroPi\n<b>https://github.com/Andre87osx/AstroPi-system/issues</b>" --width=300 --title="AstroPi System" && exit
# =================================================================
echo "75"
echo "# Yet a moment..." ; sleep 2

# =================================================================
echo "# All finished." ; sleep 2
echo "100"

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
zenity --info --text="Kstars AstroPi allredy installed" --width=300 --title="AstroPi System"
fi
fi
