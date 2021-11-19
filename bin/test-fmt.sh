#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/vid-trim-rev,v 1.3 2021/10/26 19:26:13 bruce Exp $

if [ $# -ne 2 -o "x$1" = "x-h" ]; then
    cat               <<EOF
Usage:
        vid-rm-trim File Rel

Rel syntax:
    rev1:rev2   Between rev1 and rev2, including rev1 and rev2.
    rev1::rev2  Between rev1 and rev2, excluding rev1 and rev2.
    rev:        rev and following revisions on the same branch.
    rev::       After rev on the same branch.
    :rev        rev and previous revisions on the same branch.
    ::rev       Before rev on the same branch.
    rev         Just rev.

Note: this assumes you are on the same system that hosts the master files.
EOF
    exit 1
fi

# --------------------
# Config
export gpFile=$1
export gpRel=$2

# --------------------
# Validate

if [ ! -f $gpFile ]; then
    echo     "Error: could not find $gpFile"
    exit     1
fi
if [ ! -f CVS/Root ]; then
    echo       "Error: You are not in a CVS workspace."
    exit       1
fi

export CVSROOT=$(cat CVS/Root)
export cPath=$(cat CVS/Repository)

if [ ! -f $CVSROOT/$cPath/${gpFile},v ]; then
    cat     <<EOF
Error: could not find $CVSROOT/$cPath/${gpFile},v
        Is $CVSROOT mounted?
EOF
    exit     1
fi

echo
tValid=$(echo $gpRel | tr -d '[0-9.:]')
if [ -n "$tValid" ]; then
    echo "Error: Rel can only contain: [0-9.:]"
    exit 1
fi
tFound=0
if [ ${gpRel#::} != $gpRel ]; then
    echo "Notice: this will delete revisions before ${gpRel#::}"
    tFound=1
fi
if [ ${gpRel%::} != $gpRel ]; then
    echo "Notice: this will delete revisions after ${gpRel#::} including HEAD"
    tFound=1
fi
if [ $tFound -eq 0 -a ${gpRel#:} != $gpRel ]; then
    echo "Notice: this will delete revisions before, and including ${gpRel#::}"
    tFound=1
fi
if [ $tFound -eq 0 -a ${gpRel%:} != $gpRel ]; then
    echo "Notice: this will delete revisions after, and including ${gpRel#::} including HEAD"
    tFound=1
fi
if [ $tFound -eq 0 -a ${gpRel#*::} != $gpRel ]; then
    echo "Notice: this will delete revisions between,"
    echo "but not including, the specified revisions."
    tFound=1
fi
if [ $tFound -eq 0 ]; then
    echo "Notice: this only deletes revision $gpRel"
    tFound=1
fi

cat <<EOF

Notice: This is a very distructive operation.
- A copy of the file will be put in $CVSROOT/archive/.
  See $CVSROOT/archive.log for the copy actions.
- To recover disk space you will need to manually remove the files from
  $CVSROOT/archive/.
- Each run of vid-rel-trim, with the same file, will create more
  copies in $CVSROOT/archive/.

EOF
read -p "Continue? (enter or ^C)"
echo

# --------------------
# Link to the file to be modified
mkdir $CVSROOT/archive 2>/dev/null

cat <<EOF >>$CVSROOT/archive.log
$(date)
ln -v --backup=numbered $CVSROOT/$cPath/${gpFile},v $CVSROOT/archive"
EOF

echo
echo "Copy:"
ln -v --backup=numbered $CVSROOT/$cPath/${gpFile},v $CVSROOT/archive | tee -a $CVSROOT/archive.log
ls $CVSROOT/archive/${gpFile},v*
read -p "Continue? (enter or ^C)"
echo

# --------------------
echo "cvs admin -o $gpRel $gpFile"
read -p "Continue? (enter or ^C)"
echo

tBefore=$(ls -lh $CVSROOT/$cPath/${gpFile},v | awk '{print $5}')

echo "cvs admin -o $gpRel $gpFile"
cvs admin -o $gpRel $gpFile
sync -f $CVSROOT

tAfter=$(ls -lh $CVSROOT/$cPath/${gpFile},v | awk '{print $5}')

cat <<EOF
Size before: $tBefore
Size after:  $tAfter
EOF
