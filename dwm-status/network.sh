#!/bin/bash
## Author: Sean Reyboz
## A simple script to display the current network status (offline, lan or wlan)

## pattern
eth="enp*"
wlan="wl*"

### Check which interface is being used, and display a message accordingly
if [ $(cat /sys/class/net/$wlan/carrier) 2>/dev/null == "1"  ]
then
    echo "$(nmcli -t -f active,ssid, dev wifi | grep '^yes' | cut -d ':' -f2)"
elif [ $(cat /sys/class/net/$eth/carrier) 2>/dev/null == "1" ]
then 
    echo "LAN Connected"
else
    echo "No network"
fi

