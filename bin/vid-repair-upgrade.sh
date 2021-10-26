#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/vid-repair-upgrade.sh,v 1.2 2021/10/26 19:26:13 bruce Exp $

cat <<EOF
Repair the kdenlive files, by doing an upgrades across the versions.

First run get-ver.sh File.kdenlive
To get the list of kdenlive versions.

Checkout the earliest version. Copy it to a new file name.
cvs update -r 1.1 File.kdenlive
cvs update -A File.kdenlive
cp File.kdenlive tmp.kdenlive

Save the script to a editor file.
Modify the tName for the file to be converted. (tmp.kdenlive)
Also modify the list of versions, starting with the earliest to latest.
Cut/paste the script. You can "tail -f t.tmp"

At each iteration make a small changed to the project's metadata, and save.

If the new version works, then copy it back to the original name, and commit.
cvs update -A File.kdenlive
cp tmp.kdenlive File.kdenlive
cvs commit -m "Repaired with repair-upgrade.sh"
EOF
exit 1

rm t.tmp
tName=2017-07-29-raw3.kdenlive
for i in \
    Kdenlive-17.04.1b-x86_64.AppImage \
    Kdenlive-17.12.0d-x86_64.AppImage \
    kdenlive-18.12.1-x86_64.appimage \
    kdenlive-19.04.3-x86_64.appimage \
    kdenlive-19.08.3-x86_64.appimage; do
    tVer=$(grep kdenliveversion $tName | sed 's;[<>/]; ;g' | awk '{print $3}')
    echo $i $tVer >>t.tmp
    /rel/archive/software/ThirdParty/kdenlive/$i $tName
done
tVer=$(grep kdenliveversion $tName | sed 's;[<>/]; ;g' | awk '{print $3}')
echo $tVer >>t.tmp
