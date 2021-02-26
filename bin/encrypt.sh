#!/bin/bash
# Encrypt the list of files.  The files will be removed after encryption.

export GNUPGHOME=${GNUPGHOME:-~/.gnupg}
export pFileList="$*"

tNameList=""
tKeyList=""
PS3="Select a name (Enter to redisplay): "
select tName in CONTINUE LIST OTHER ABORT CLEAR $(gpg --list-public-keys --with-colons | grep '^pub:' | awk -F: '{print $10,$5}' | tr [:upper:] [:lower:] | sed 's/@/_at_/' | tr -s -c '[:alnum:]\n' _ | sed 's/_$//' | egrep 'equifax_com|trustedid_com' | sort) CONTINUE LIST OTHER ABORT CLEAR; do
	case $tName in
		'')
			echo "Invalid choice"
			continue
		;;
		CONTINUE)
			break
		;;
		LIST)
			echo -e "\nKeys: $tNameList"
			gpg --list-keys $tKeyList | grep uid
			continue
		;;
		ABORT)	echo "Aborting"
			exit 1
		;;
		CLEAR)
			tNameList=""
			tKeyList=""
			echo -e "\nKeys: $tNameList"
			continue
		;;
		OTHER)
			select tName in RETURN $(gpg --list-public-keys --with-colons | grep '^pub:' | awk -F: '{print $10,$5}' | tr [:upper:] [:lower:] | sed 's/@/_at_/' | tr -s -c '[:alnum:]\n' _ | sed 's/_$//' | egrep -v 'equifax_com|trustedid_com' | sort) RETURN; do
				case $tName in
					'')
						echo "Invalid choice"
					;;
					RETURN)
						break
					;;
				esac
				tKeyList="$tKeyList ${tName##*_}"
				tNameList="$tNameList -r ${tName##*_}"
				echo -e "\nKeys: $tNameList"
				gpg --list-keys $tKeyList | grep uid
			done
			echo -e "\nKeys: $tNameList"
			gpg --list-keys $tKeyList | grep uid
			continue
		;;
	esac
	tKeyList="$tKeyList ${tName##*_}"
	tNameList="$tNameList -r ${tName##*_}"
	echo -e "\nKeys: $tNameList"
	gpg --list-keys $tKeyList | grep uid
done

echo "gpg -z 6 -a --pgp8 $tNameList --encrypt-files $pFileList"
gpg -z 6 -a --pgp8 $tNameList --encrypt-files $pFileList

read -p "Delete $pFileList and *~ ?" pAns
if [ "$pAns" = 'y' ]; then
	shred -uzf $pFileList *~
fi
