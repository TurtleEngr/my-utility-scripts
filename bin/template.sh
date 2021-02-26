#!/bin/bash
# Last used error code number: 6

# Prefix codes (show the "scope" of variables):
# gVar - global variable (may even be external to the script)
# pVar - parameter (script option or function parameter)
# gpVar - global parameter, i.e. may be defined external to the script
# cVar - global constant (set once)
# tVar - temporary variable (local to a function)
# fFun - function

# Commonally used global variables:
# gpDebug - toggle (-x)
# gpVerbose - toggle (-v)
# gpLog - log level
# gpTmp - personal tmp directory.  Usually set to: /tmp/$LOGNAME
# cTmpF - tmp file prefix.  Includes $gpTmp and $$ to make it unique
# gErr - error code (0 = no error)
# cVer - current version
# cName - script's name
# cBin - directory where the script is executing from
# cCurDir - current directory

# --------------------------------
function fCleanUp
{
	trap - 1 2 3 4 5 6 7 8 10 11 12 13 14 15
	# Called when script ends (see trap) to remove temporary files,
	# if not in debug mode.
	if [ $gDebug -eq 0 ]; then
		'rm' -f ${cTmpF}[1-9]*.tmp 2>/dev/null
	fi
#	print "$gName is done" | $gBin/log -sv
#	print "Out" | $gBin/log -odvs
	exit $1
}

# --------------------------------
function fUsage
{
	# Print usage help for this script.  Strip tags with tag2a if
	# it can be found.  tag2a.sh will not strip tags if the
	# gPrintTag env. var. is set to 1.
	if [ -x $gBin/tag2a ]; then
		tStrip=$gBin/tag2a
	else
		if [ $gDos -eq 0 ]; then
			whence tag2a >/dev/null 2>&1
		else
			which tag2a >/dev/null 2>&1
		fi
		if [ $? -eq 0 ]; then
			tStrip=tag2a
		else
			tStrip=cat
		fi
	fi
	$tStrip <<END | more -e
<rsect>$gName
	<idx main|$gName:usage|

<rsub>Usage
#	<syntax>
	$gName [-h] {-n%%HostName%%
		     -c} [-t %%Tag%%] &<%%InFile%% >%%OutFile%%
#	<\syntax>

<rsub>Parameters
#	<lablist>
	\-h\	Give this usage help

	\-n%%Name%%\	Explicit host name.
	\-c\	Use the current host name: $(hostname)
	\-t%%Tag%%\	Tag word that preceeds the host name. Default:
			$cTag
#	<\lablist>

<rsub>Description
	Stdin is read and lines that begin with the %%Tag%% word are
	outputed to stdout only if the next word matches the
	%%HostName%%.  All other lines are outputed.

	The purpose of this filter is to create different versions
	of a file from a common file.

<rsub>Language Syntax
	Lines that have the following pattern:
	<ex>
	%%Tag%% %%HostName%%[,%%HostName%%]* %%Line%%
	</ex>

	will be outputed as:
	<ex>
	%%Line%%
	</ex>
	if -n%%HostName%% (or the current hostname, if the -c option
	was used) matches any of the hostnames after the Tag.

<rsub>Version
	$gVer
END
	fCleanUp 1
	exit 1
}

# --------------------------------
function fError
{
	# Print the error message (fError options).  Then call
	# fCleanUp to exit.
	gErr=$1
	shift
	set -f
#	print "Error: $*" | $gBin/log -e
	set +f
	if [ $gNoExit -ne 0 ]; then
		gNoExit=0
		return
	fi
	cat <<END 1>&2
Usage: 	$gName [-h] {-nHostName | -c} [-tTag] <InFile >OutFile
 Type: "$gName -h" for more help.
END
	fCleanUp 1
	exit 1
}

# ------------------
function fLog
{
	# Input:
	#	$1 level (# emerg alert crit err warning notice info debug)
	#	$2 message
	tErr=""
	if [ $gErr -ne 0 ]; then
		tErr="[$gErr]"
	fi
	echo "$1: $2 $tErr" 1>&2
	if [ $pDebug -ne 0 ]; then
		return
	fi
	logger -i -t mirror.release1 -p local1.$1 "$2 $tErr"
} # fLog

# Main --------------------------------------------------------------
export	gBin gCurdir gErr gErrLog gDebug gLog gLogFile gName \
	gNoExit gVer gVerbose PWD

# -------------------
# Set current directory location in PWD and gCurDir, because with cron
# jobs PWD is not set.
if [ -z $PWD ]; then
	PWD=$(pwd)
fi
gCurDir=$PWD

# -------------------
# Set name of this script
# Note: this does not work if the script is executed with '.'
gName=${0##*/}

# -------------------
# Define the location of the script
if [ $0 = ${0%/*} ]; then
	gBin=$(whence $gName)
	gBin=${gBin%/*}
else
	gBin=${0%/*}
fi
cd $gBin
gBin=$PWD
cd $gCurDir

# -------------------
# Setup log variables
gDebug=${gDebug:-0}
gErr=0
gErrLog=""
gLog=1
gLogFile=""
gNoExit=0
gVerbose=${gVerbose:-0}

# -------------------
# Define the version number for this script
gVer='$Revision: 1.35 $'
gVer=${gVer#*' '}
gVer=${gVer%' '*}

# -------------------
# Setup a temporary directory for each user.
Tmp=${Tmp:-"/tmp/$LOGNAME"}
if [ ! -d $Tmp ]; then
	mkdir -p $Tmp 2>/dev/null
	if [ ! -d $Tmp ]; then
		fError "1" "Could not find directory $Tmp (\$Tmp)."
	fi
fi

gErrLog=$Tmp/$gName.err
rm $gErrLog 2>/dev/null

# -------------------
# Define temporary file names used by this script.  The variables for
# the file names can be any name, but the file name pattern should be:
# "${cTmpF}[0-9]*.tmp"
if [ $gDebug -eq 0 ]; then
	cTmpF=$Tmp/syst$$
else
	cTmpF=$Tmp/syst
	rm -f ${cTmpF}*.tmp 2>/dev/null
fi
cTmp1=${cTmpF}1.tmp
trap fCleanUp 1 2 3 4 5 6 7 8 10 11 12 13 14 15
export cTmpF cTmp1 cTmp2

# -------------------
# Configuration
export cTag=systag

# -------------------
# Get Options Section
pFileList=""
pTag=$cTag
pHostName=""
while getopts :hcn:t:x tArg; do
	case $tArg in
		h)	fUsage
			exit 1
		;;
		c)	pHostName=$(hostname);;
		n)	pHostName=$OPTARG;;
		t)	pTag=$OPTARG;;

		x)	gDebug=1;;
		+x)	gDebug=0;;
		:)	fError "2" "Value required for option: $OPTARG";;
		\?)	fError "3" "Unknown option: $OPTARG";;
	esac
done
let tOptInd=OPTIND-1
shift $tOptInd
if [ $# -ne 0 ]; then
	pFileList="$*"
fi

# -------------------
#print "In" | $gBin/log -idv
#print "Version: $gVer" | $gBin/log -sv

# Print dump of variables
if [ $gDebug -ne 0 ]; then
	for i in \
		PWD \
		gBin \
		gCurDir \
		gName \
		gVer \
		gLog \
		gLogFile \
		gErrLog \
		gDebug \
		gVerbose \
		gErr \
		pTag \
		pHostName \
		Tmp \
	; do
		eval print -R "$i=\$$i" | $gBin/log -d
	done
fi

# -------------------
# Validate Options Section

if [ -z $pHostName ]; then
	fError "5" "The -n or -c option is required."
fi

# -------------------
# Functional Section

cat <<END-END >$cTmp1
	\$1 == "$pTag" {
		if (\$2 ~ /$pHostName/) {
			\$1 = ""
			\$2 = ""
			sub(/^  /,"",\$0)
			print \$0
		 }
		 next
	}
	{ print \$0}
END-END
awk -f $cTmp1

# -------------------
# Cleanup Section
fCleanUp 0
