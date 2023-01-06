#!/bin/bash

if [ $# -ne 1 ]; then
    cat <<EOF
Usage:
        quick-dump.sh DBNAME
EOF
    exit 1
fi

tHost=$(hostname)
tHost=${tHost%%.*}
tCmd="mysqldump -u root -p $1 -R >$(date +%F_%H-%M)_$1_$tHost.sql"
echo $tCmd
mysqldump -u root -p $1 >$(date +%F_%H-%M)_$1_$tHost.sql
