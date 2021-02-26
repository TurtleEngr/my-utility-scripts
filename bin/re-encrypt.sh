#!/bin/bash
# Decrypt the file(s), then re-encrypt them with the selected names.

gpg --list-public-keys --with-colons --batch | grep '^pub' | awk -F: '{print $5,$6,$10}'
tNameList=""
PS3="Select a name (Enter to redisplay): "
select tName in CONTINUE ABORT CLEAR $(gpg --list-public-keys --with-colons --batch | grep '^pub' | awk -F: '{print $10}' | sed 's/[^<]*<//' | sed 's/>//' | sort -i); do
	case $tName in
		CLEAR)
			tNameList=""
			echo -e "\nKeys: $tNameList"
			continue
		;;
		ABORT)	echo "Aborting"
			exit 1
		;;
		'')	echo "Invalid choice";;
		CONTINUE)	break;;
	esac
	tNameList="$tNameList -r $tName"
	echo -e "\nKeys: $tNameList"
done

echo "gpg -a $tNameList --encrypt-files $*"
gpg -a $tNameList --encrypt-files $*
rm -i $* *~
