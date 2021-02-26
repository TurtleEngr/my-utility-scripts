#!/bin/bash

for i in *.jpg; do
	t=${i%.jpg}_t.jpg
	if [ $i != ${i%_t.jpg} ]; then
		continue
	fi
	if [ -f $t ]; then
		echo "Already exists: $i"
		continue
	fi
	echo "Create: $t"
	jpegtopnm $i 2>/dev/null |
	pnmscale -reduce 8 2>/dev/null |
	ppmtojpeg 2>/dev/null >$t
done
# pbmreduce  8
