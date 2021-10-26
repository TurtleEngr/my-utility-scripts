#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/archive-video.sh,v 1.3 2021/10/26 19:26:08 bruce Exp $

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
