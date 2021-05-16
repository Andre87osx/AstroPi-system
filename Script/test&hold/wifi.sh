# File name wifi.sh
read -r -p "Scrivi il tuo SSID " ssid
read -r -p "Scrivi la password " psw
##################
sudo cat > /etc/wpa_supplicant/wpa_supplicant.conf <<- EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=IT

network={
    ssid="$ssid"
    psk="$psw"
}
EOF
##################