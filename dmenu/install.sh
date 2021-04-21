#!/bin/bash

for script in $(ls | grep -v "install.sh")
do
    sudo cp $script /usr/bin
    sudo chmod 755 /usr/bin/$script 
done

