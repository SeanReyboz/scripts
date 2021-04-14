#!/bin/bash
## Author: Sean Reyboz
## Get the current song from spotify

## Dependencies: `playerctl`

### Defining some variables
TITLE=$(playerctl metadata title)
ARTIST=$(playerctl metadata artist)

if [[ $(playerctl status) = "Playing" ]]; then
        echo "$TITLE - $ARTIST"
elif [[ $(playerctl status) = "Paused" ]]; then
        echo "Paused"
else
        echo "Not running"
fi
