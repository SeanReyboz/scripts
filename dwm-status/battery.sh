#!/usr/bin/env bash

# Author: Sean Reyboz
# Script to get the battery status

# Variables --------------------------------
bat="BAT0"
batDir="/sys/class/power_supply/$bat"
batCap="$batDir/capacity"
batStatus="$batDir/status"

# Read both battery capacity & status 
[[ -r "$batCap" ]]    && read cap  < "$batCap"    || exit
[[ -r "$batStatus" ]] && read stat < "$batStatus" || exit

[[ $cap -le 5 ]] && [[ $stat = 'Discharging' ]] && {
    notify-send -u critical "Warning" "Low battery"
}

# Print the capacity
printf '%s%%\n' "$cap"
