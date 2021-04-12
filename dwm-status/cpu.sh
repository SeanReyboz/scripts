#!/bin/bash
## Author: Sean Reyboz

### Get cpu temp
sensors | egrep "^Tdie" | cut -d\+ -f2
