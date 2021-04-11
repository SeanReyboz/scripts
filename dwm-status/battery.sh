#!/bin/bash
## Author: Sean Reyboz
## Script to get the battery status
bat="BAT0"

### Print out the percentage of the battery
[[ -r "/sys/class/power_supply/$bat/capacity" ]] && echo "$(cat /sys/class/power_supply/$bat/capacity)%" 
