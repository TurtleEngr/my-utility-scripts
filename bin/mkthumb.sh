#!/bin/bash

# Make half size images and thumb-nail images (8 times smaller)

for i in *.jpg; do
    echo "Processing: $i"
    t=${i%.jpg}
    jpegtopnm $i | pnmscale -reduce 2 | pnmtojpeg --quality=50 >${t}-x2.jpg
    jpegtopnm $i | pnmscale -reduce 8 | pnmtojpeg --quality=50 >${t}-x8.jpg
done
