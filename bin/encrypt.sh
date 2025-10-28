#!/bin/bash

#--------------------
if [[ $# -eq 0 ]]; then
    cat <<EOF
encrypt.sh FileList
EOF
    exit 1
fi

# ====================
gpFileList="$*"
cKeyList='-r barafnel@gmail.com'

for i in $gpFileList; do
    if [[ ! -r $i ]]; then
        echo "Error: $i is not found or not readable"
        exit 1
    fi
done

for i in $gpFileList; do
    echo "Encrypting: $i"
    gpg -z 6 -a --pgp8 $cKeyList --encrypt-files $i
done
say -r done
