#!/bin/bash
## Author: Sean Reyboz
## Small script that displays the current Master Audio volume

### Check if the Master  Volume is muted, if not, display the Volume percentage
if [ $(pactl list sinks | egrep "Mute:" | awk '{print $2}') == "yes" ]; then
        echo "Muted"
else
        echo $(pactl list sinks | egrep "Volume: front-left:" | awk '{print $5}')
fi

