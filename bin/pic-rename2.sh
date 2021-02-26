#!/bin/bash

for i in $(ls *.JPG); do
    mv $i ${i%JPG}jpg
done

chmod a-x,u+rw *.jpg

# Include previous file name with %f
#jhead -ft  -n%Y-%m-%d.%H%M%S.%f *.jpg

jhead -ft  -n%Y-%m-%d.%H%M%S *.jpg
for i in *.jpg; do
    jhead -v $i >$i.txt
done
