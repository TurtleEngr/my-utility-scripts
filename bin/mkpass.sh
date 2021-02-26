#!/bin/bash
# Requires the apg program

# Create a password that has letters that easily understood over the
# phone, so avoid mn, bv, etc.  And avoid letter number confusion:
# oO0, 1lI, etc.

tNumPass=2
tMin=14
tMax=18
# -M NCL
# -E - exclude these char.

apg -n $tNumPass -a1 -m $tMin -x $tMax -MNCL -E1lI0OozbvdmnqQp
echo
apg -n $tNumPass -a0 -m $tMin -x $tMax -MNCLS -E\'\"\`\~\*$1lI0OozbvdmnqQp
