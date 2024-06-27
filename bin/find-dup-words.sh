#!/bin/bash
# Usage:
#    find-dup-words.sh <FILE.txt

# Find consecutive repeated words and output the word and line number
awk '{
  for (i=1; i<=NF; i++)
    if($i == $(i+1))
      print $i, NR
}'
