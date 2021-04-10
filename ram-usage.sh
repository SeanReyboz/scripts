#!/bin/bash

## Bash script to get the current RAM usage

## in case a `free` alias exists, unset it 
[[ $(alias | grep "free" ]] && unalias free

## Get the amount of ram currently being used
used=$(free | grep "Mem" | awk '{print ($3/1024)/($2/1024)*100}' | cut -d'.' -f1 )

## Get the percentage of available memory
percentage=$(free -h | awk '/^Mem/ {print $3}')

## Display the human readable value for used RAM + percentage
echo "$used ($percentage%)"
