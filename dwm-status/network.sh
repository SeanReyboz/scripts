#!/bin/bash
## Author: Sean Reyboz
## A simple script to display the current network status (offline, lan or wlan)

## Eth
eth="enp0s23"
## Wifi
wlan="wlp2s0"

### Check which interface is being used, and display a message accordingly
if [ -r "/sys/class/net/$wlan/carrier" ]; then
        echo "$(nmcli -t -f active,ssid, dev wifi | grep '^yes' | cut -d ':' -f2)"
elif [ -r "cat /sys/class/net/$eth/carrier" ]; then 
        echo "LAN Connected"
else
        echo "No network"
fi

