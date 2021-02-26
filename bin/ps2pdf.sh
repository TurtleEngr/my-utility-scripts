#!/bin/bash

mkdir ~/tmp 2>/dev/null

pName=${1%.ps}
pParm=$*
for i in $pParm; do
	case $i in
		*.ps)
			echo "ps2ps $i"
			ps2ps $i ~/tmp/$i.tmp
		;;
		*.txt)
			echo "a2ps $i"
			a2ps -1 --output ~/tmp/$i.tmp $i
		;;
	esac
done

rm -f ~/tmp/$pName.tmp 2>/dev/null
for i in $pParm; do
	cat ~/tmp/$i.tmp >>~/tmp/$pName.tmp
done

echo "Creating: $pName.pdf"
ps2pdf ~/tmp/$pName.tmp $pName.pdf
