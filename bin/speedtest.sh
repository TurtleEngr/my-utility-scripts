#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/speedtest.sh,v 1.7 2023/03/25 22:21:42 bruce Exp $

# This despends on: SpeedTest
# Source: https://github.com/taganaka/SpeedTest
# See /etc/CHANGE for details
# Local code at: /home/bruce/ver/public/app/SpeedTest

# ----------
if [ ! -x /usr/local/bin/SpeedTest ]; then
    echo Error: SpeedTest is not installed.
    exit 1
fi

# ----------
export cMaxDown=55
export cMaxUp=10

export cMinDown=50
export cMinUp=9

export cOutput=/tmp/speedtest.log
if [ $(whoami) = "root" ]; then
    cOutput=/var/log/speedtest.log
fi

# ----------
pRun=1
if [ ".$1" = ".-n" ]; then
    pRun=0
    if [ ! -r $cOutput ]; then
        echo $cOutput does not exist. First run with no -n
        exit 1
    fi
fi

# ----------
if [ $pRun -eq 1 ]; then
    echo 'Running SpeedTest -> ' $cOutput
    echo '# --------------------' >>$cOutput
    echo -n '# ' >>$cOutput
    date >>$cOutput
    timeout 5m SpeedTest --output text >>$cOutput
fi

export tDone=1
if ! grep -q DOWNLOAD_SPEED $cOutput; then
    tDone=0
fi
if ! grep -q UPLOAD_SPEED $cOutput; then
    tDone=0
fi
if [ $tDone -ne 1 ]; then
    echo SpeedTest timedout after 5 min. So no results available.
    exit 1
fi

tDown=$(grep DOWNLOAD_SPEED $cOutput | tail -n 1)
tDown=${tDown#DOWNLOAD_SPEED=}
tDown=${tDown%.*}

tUp=$(grep UPLOAD_SPEED $cOutput | tail -n 1)
tUp=${tUp#UPLOAD_SPEED=}
tUp=${tUp%.*}

echo $tDown Mbps, expected $cMinDown to $cMaxDown
echo $tUp Mbps, expected $cMinUp to $cMaxUp

tErr=0
if [ $tDown -lt $cMinDown ]; then
    tErr=1
    echo Problem: download is slow
fi
if [ $tUp -lt $cMinUp ]; then
    tErr=1
    echo Problem: upload is slow
fi
exit $tErr
