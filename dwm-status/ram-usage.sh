#!/bin/bash
## Author: Sean Reyboz
## bash script to get the current RAM usage

### in case a free alias exists, unset it 
[[ $(alias | grep "free") ]] && unalias free

### Get the percentage of available memory
percentage=$(free | grep "Mem" | awk '{print ($3/1024)/($2/1024)*100}' | cut -d'.' -f1 )

### Get the amount of ram currently being used
used=$(free -h | awk '/^Mem/ {print $3}')

### Display the human readable value for used RAM + percentage
echo "$used ($percentage%)"

### Only display the human readable value
#echo $used

### Only display the percentage
#echo "($percentage%)"
