#!/bin/bash
## Author: Sean Reyboz
## Display the current backlight percentage 

echo "$(brightnessctl | grep "Current" | awk '{print $4}' | cut -d\( -f2 | cut -d\) -f1)"
