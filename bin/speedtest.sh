#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/speedtest.sh,v 1.3 2020/04/15 06:14:15 bruce Exp $

# This despends on: SpeedTest
# See /etc/CHANGE for details

# ----------
if [ ! -x /usr/local/bin/SpeedTest ]; then
    echo Error: SpeedTest is not installed.
    echo See /etc/CHANGE for details
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
    SpeedTest --output text >>$cOutput
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
