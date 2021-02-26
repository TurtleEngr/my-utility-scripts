#!/bin/bash

mkdir orig
for i in *.jpg; do
    ln "$i" orig
    jhead -ft  -nf%Y-%m-%d.%H%M%S "$i"
done
for i in *.jpg; do
    jhead -v "$i" >$i.txt
done
