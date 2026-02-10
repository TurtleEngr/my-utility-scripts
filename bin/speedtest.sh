#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/speedtest.sh,v 1.8 2026/01/02 14:48:31 bruce Exp $

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
tIP=$(getmyip)
case tIP in
    107.220.116.250)
        export cMaxDown=350
        export cMaxUp=350
        export cMinDown=290
        export cMinUp=290
        ;;
    69.27.191.137)
        export cMaxDown=50
        export cMaxUp=25
        export cMinDown=40
        export cMinUp=20
        ;;
    *)
        export cMaxDown=350
        export cMaxUp=350
        export cMinDown=290
        export cMinUp=290
        ;;
esac

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
    timeout 4m SpeedTest --output text >>$cOutput
fi

export tDone=1
if ! grep -q DOWNLOAD_SPEED $cOutput; then
    tDone=0
fi
if ! grep -q UPLOAD_SPEED $cOutput; then
    tDone=0
fi
if [ $tDone -ne 1 ]; then
    echo SpeedTest timedout after 3 min. So no results available.
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
