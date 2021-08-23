#!/bin/bash
# Select a cvs root to connect to.

function fUsage() {
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
	$tRCFileList

Local CVS directories that will be checked for CVSROOT:
	$tCVSDirList

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
	:ext:\$CVSUser@redwood.sfo.sychron.net:/data/cvs/redwood.cvs
	:ext:\$CVSUser@redwood.sfo.sychron.net:/data/cvs/tool.cvs

Defects
	The script only works well with bash or ksh.
EOF
	exit 1
}

# ==============================
export gErr=0
if [ ! -f $HOME/.cvsroot.rc -a ! -f /usr/local/etc/cvsroot.rc ]; then
	echo Error: Could not fined $HOME/.cvsroot or /usr/local/etc/cvsroot.rc
	gErr=1
fi
if [ $gErr -ne 0 -o ".$1" = '.-h' ]; then
	fUsage
fi

tRCFileList="$HOME/.cvsroot.rc /usr/local/etc/cvsroot.rc /etc/cvsroot.rc cvsroot.rc"
tCVSDirList="/cvs /cvs/* /repo/*.cvs /data/cvs/* /data/*.cvs /home/cvs/* /home/*.cvs"
export CVSUser=${CVSUser:-$LOGNAME}
if [ -x /bin/nawk ]; then
	export awk=nawk
else
	export awk=awk
fi

tFile1=/tmp/cvsroot.1.$$
tFile2=/tmp/cvsroot.2.$$
cat $tRCFileList 2>/dev/null | $awk '
	NF == 0 { next }
	$1 == "#" { next }
	{ print $0 }
	$1 ~ /:/ {
		sub(/.*:/,"",$0)
		print $0
	}
' 2>/dev/null >$tFile1

for i in $tCVSDirList $(cat $tFile1 2>/dev/null); do
	if [ "${i#:}" != "$i" ]; then
		echo ${i%/} >>$tFile2
		continue
	fi
	if [ ! -d $i/CVSROOT ]; then
		continue
	fi
	echo ${i%/} >>$tFile2
done
cat $tFile2 >$tFile1

for i in CVS/Root ../CVS/Root */CVS/Root /CVS; do
	for j in $(cat $i 2>/dev/null); do
		echo ${j%/} >>$tFile1
	done
done
echo $CVSROOT >>$tFile1

'rm' -f $tFile2
for i in $(sort -fu $tFile1); do
	echo ${i%/} >>$tFile2
done

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
		EXIT)	break;;
	esac
	break
done
echo ""

if [ $tSelect != "EXIT" ]; then
	unset CVSROOT CVS_RSH RSYNC_RSH RSYNC_OPT
	export CVSROOT=$tSelect
	echo CVSROOT=$CVSROOT
	export CVS_RSH=${CVS_RSH:-ssh}
	echo CVS_RSH=$CVS_RSH
	export CVSUMASK=${CVSUMASK:-0007}
	echo CVSUMASK=$CVSUMASK
	export RSYNC_RSH=${RSYNC_RSH:-ssh}
	echo RSYNC_RSH=$RSYNC_RSH
	export RSYNC_OPT=${RSYNC_OPT:-"-aCHz"}
	echo RSYNC_OPT=$RSYNC_OPT
fi

'rm' -f $tFile1 $tFile2 2>/dev/null
