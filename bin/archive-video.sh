#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/archive-video.sh,v 1.2 2019/07/21 22:02:21 bruce Exp $

if [ $# -eq 0 ]; then 
    cat <<EOF
archive-video.sh dir
EOF
    exit 1
fi

# --------------------
cDir=$1

cExclude='--exclude=~ --exclude=*.tmp --exclude=*.bak --exclude=*.sav --exclude=proxy --exclude=thumbs --exclude=scripts'
cId=$(date-id -d)

tar --dereference --hard-dereference $cExclude --checkpoint=.5000 -czvf $cDir-$cId.tgz $cDir
