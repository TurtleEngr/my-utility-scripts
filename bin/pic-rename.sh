#!/bin/bash

jhead -ft  -n%Y-%m-%d.%H%M%S.%f pict*.jpg
jhead -ft  -n%Y-%m-%d.%H%M%S.%f *.JPG

for i in *.jpg; do
	jhead -v $i >$i.txt
done
