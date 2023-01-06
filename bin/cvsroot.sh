#!/bin/bash
# Select a cvs root to connect to.

function fUsage()
{
    more <<EOF
Usage:
        . cvsroot.sh

Description:
        All of the cvsroot.rc files that are found on the system will
        be used to collect the list of cvsroots that you can choose
        from.

        The directory part of the :pserver: and :ext: strings will
        be checked to see it those directories exist locally, so that
        you can set your CVSROOT to a one of the local directories.

cvsroot.rc files that will be used, if found:
        $cRCFileList

Local CVS directories that will be checked for CVSROOT:
        $cCVSDirList

Environment Variables:
        LOGNAME
        CVSROOT
        CVS_RSH (if not already set, set to ssh)
        CVSUser (set to LOGNAME, if not set)
        CVSUMASK (if not already set)
        RSYNC_RSH (if not already set, set to ssh)
        RSYNC_OPT (if not already set)

Format of cvsroot.rc files:
        # Blank lines and lines beginning with # are ignored.
        cvsroot-string
        local-dir

Example cvsroot.rc:
        /cvs
        :ext:\$LOGNAME@redwood.sfo.sychron.net:/data/cvs/redwood.cvs
        :ext:\$LOGNAME@redwood.sfo.sychron.net:/data/cvs/tool.cvs

Defects
        The script only works well with bash.

TBD
        * Create CVSUser place holder in .cvsroo.rc. Replace it with the
          CVSUser value.
        * Use LOGNAME and/or USER to set CVSUser
        * Can the ":ext:" path work if the user is omitted?
        * Clean the script
EOF
    exit 1
}

# ==============================
cRCFileList="$HOME/.cvsroot.rc /usr/local/etc/cvsroot.rc /etc/cvsroot.rc cvsroot.rc"
cCVSDirList="/cvs /cvs/* /repo/*.cvs /data/cvs/* /data/*.cvs /home/cvs/* /home/*.cvs"

export gErr=0
if [ ! -f $HOME/.cvsroot.rc -a ! -f /usr/local/etc/cvsroot.rc ]; then
    echo Error: Could not fined $HOME/.cvsroot or /usr/local/etc/cvsroot.rc
    gErr=1
fi
if [ $gErr -ne 0 -o ".$1" = '.-h' ]; then
    fUsage
fi

if [ -x /bin/nawk ]; then
    export awk=nawk
else
    export awk=awk
fi

tFile1=/tmp/cvsroot.1.$$
tFile2=/tmp/cvsroot.2.$$
cat $cRCFileList 2>/dev/null | $awk '
        NF == 0 { next }
        $1 == "#" { next }
        { print $0 }
        $1 ~ /:/ {
                sub(/.*:/,"",$0)
                print $0
        }
' 2>/dev/null >$tFile1

for i in $cCVSDirList $(cat $tFile1 2>/dev/null); do
    if [ "${i#:}" != "$i" ]; then
        echo ${i%/} >>$tFile2
        continue
    fi
    if [ ! -d $i/CVSROOT ]; then
        continue
    fi
    echo ${i%/} >>$tFile2
done
sort -fu $tFile2 >$tFile1

for i in $(cat CVS/Root ../CVS/Root */CVS/Root /CVS/Root 2>/dev/null); do
    if [ "${i#:}" != "$i" ]; then
        echo ${i%/} >>$tFile1
        continue
    fi
    if [ ! -d $i/CVSROOT ]; then
        continue
    fi
    echo ${i%/} >>$tFile1
done
echo $CVSROOT >>$tFile1

sort -fu $tFile1 >$tFile2

cat <<ENDHERE
Current Settings:
        CVSROOT=$CVSROOT
        CVS_RSH=$CVS_RSH
        CVSUser=$CVSUser
        CVSUMASK=$CVSUMASK
        RSYNC_OPT=$RSYNC_OPT
        RSYNC_RSH=$RSYNC_RSH
ENDHERE

PS3="Select a CVSROOT (by number) "
select tSelect in EXIT $(sort -fu $tFile2); do
    case $tSelect in
        EXIT) break ;;
    esac
    break
done
echo ""

if [ $tSelect != "EXIT" ]; then
    # unset CVSROOT CVS_RSH RSYNC_RSH RSYNC_OPT
    unset CVSROOT
    export CVSROOT=$tSelect

    export CVSUMASK=${CVSUMASK:-0007}
    export CVSUser=${CVSUser:-$LOGNAME}
    export CVS_RSH=${CVS_RSH:-ssh}
    export RSYNC_OPT=${RSYNC_OPT:-"-aCHz"}
    export RSYNC_RSH=${RSYNC_RSH:-ssh}

    echo CVSROOT=$CVSROOT
    echo CVSUMASK=$CVSUMASK
    echo CVSUser=$CVSUser
    echo CVS_RSH=$CVS_RSH
    echo RSYNC_OPT=$RSYNC_OPT
    echo RSYNC_RSH=$RSYNC_RSH
fi

'rm' -f $tFile1 $tFile2 2>/dev/null
