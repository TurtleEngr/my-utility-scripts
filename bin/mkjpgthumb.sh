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
	jpegtopnm $i | \
	pnmscale .125 | \
	ppmtojpeg >$t
done
# pbmreduce  8
