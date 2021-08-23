#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/template.sh,v 1.36 2021/08/23 04:57:03 bruce Exp $

# Prefix codes (show the "scope" of variables):
# gVar - global variable (may even be external to the script)
# pVar - parameter (script option or function parameter)
# gpVar - global parameter, i.e. may be defined external to the script
# cVar - global constant (set once)
# tVar - temporary variable (local to a function)
# fFun - function

# Commonly used global variables:
# gpDebug - -x
# gpVerbose - -v
# Tmp - personal tmp directory.  Usually set to: /tmp/$USER
# cTmpF - tmp file prefix.  Includes $$ to make it unique
# gErr - error code (0 = no error)
# cVer - current version
# cName - script's name
# cBin - directory where the script is executing from
# cCurDir - current directory

# ========================================
# Tests

fUDebug()
{
	if [ ${gpUnitDebug:-0} -ne 0 ]; then
		echo "$*"
	fi
}

testInitialConfig()
{
	assertEquals "tic-1" "$PWD" "$cCurDir"

	# ADJUST
	assertEquals "tic-2" "template.sh" "$cName"
	#assertEquals "tic-2" "SCRIPTNAME" "$cName"

	# ADJUST
	assertEquals "tic-3" "/home/$USER/public_html/template" "$cBin"
	#assertEquals "tic-3" "/usr/bin" "$cBin"
	#assertEquals "tic-3" "/usr/local/bin" "$cBin"

	assertEquals "tic-4" "0" "$gpDebug"
	assertEquals "tic-5" "0" "$gpVerbose"
	assertEquals "tic-6" "0" "$gpLog"
	assertEquals "tic-7" "user" "$gpFacility"
	assertEquals "tic-8" "0" "$gErr"
	assertNull "tic-9" "$(echo $cVer | tr -d '.[:digit:]')"
	assertEquals "tic-10" "/tmp/$USER/$cName" "$Tmp"
	assertEquals "tic-11" "$Tmp/file-$cPID" "$cTmpF"
	assertEquals "tic-12" "${cTmpF}-1.tmp" "$cTmp1"

	# ADJUST
	assertEquals "tic-13" "/tmp/$USER/$cName" "$Tmp"
}

testLog()
{
	local tMsg
	local tLevel
	local tLine
	local tErr
	local tExtra
	local tResult

	# ADJUST
	export tSyslog=/var/log/user.log

	#fLog level msg [line] [err]
	# pLevel - emerg alert crit err warning notice info debug

	# Check format
	gpLog=0
	gpVerbose=0
	local tMsg="Testing 123"
	local tLevel="err"
	local tLine="458"
	local tErr="42"
	local tExtra="extra text"
	tResult=$(fLog $tLevel "$tMsg" $tLine $tErr $tExtra 2>&1)
gpUnitDebug=1
	fUDebug "$tResult"
gpUnitDebug=0
	assertContains "tl-1.1" "$tResult" "$cName"
	assertContains "tl-1.2" "$tResult" '['$cPID']'
	assertContains "tl-1.3" "$tResult" "$tLevel:"
	assertContains "tl-1.4" "$tResult" "$tMsg"
	assertContains "tl-1.5" "$tResult" '['$tLine']'
	assertContains "tl-1.6" "$tResult" '('$tErr')'
	assertContains "tl-1.7" "$tResult" " - $tExtra"

	# Check levels
	gpLog=0
	gpVerbose=0
	local tMsg="Testing 123"
	for tLevel in emerg alert crit err warning; do
		tResult=$(fLog $tLevel "$tMsg" 2>&1)
		fUDebug $tResult
		assertContains "tl-2.$tLevel" "$tResult" "$tLevel:"
	done
	for tLevel in notice info debug; do
		tResult=$(fLog $tLevel "$tMsg" 2>&1)
		assertNull "tl-3.$tLevel" "$tResult"
	done

	gpLog=0
	gpVerbose=1
	for tLevel in notice info; do
		tResult=$(fLog $tLevel "$tMsg" 2>&1)
		assertContains "tl-4.$tLevel" "$tResult" "$tLevel:"
	done

	# Check debug
	gpLog=0
	gpVerbose=0
	gpDebug=2
	tMsg="Debug msg"

	tResult=$(fLog debug "$tMsg" 2>&1)
	fUDebug $tResult
	assertContains "tl-5.1" "$tResult" "$tMsg"

	tResult=$(fLog debug-1 "$tMsg" 2>&1)
	fUDebug $tResult
	assertContains "tl-5.2" "$tResult" "$tMsg"

	tResult=$(fLog debug-2 "$tMsg" 2>&1)
	fUDebug $tResult
	assertContains "tl-5.3" "$tResult" "$tMsg"

	tResult=$(fLog debug-3 "$tMsg" 2>&1)
	fUDebug $tResult
	assertNull "tl-5.4" "$tResult"

	# Check syslog
	gpLog=1
	gpVerbose=0
	local tMsg="Testing 123"
	for tLevel in emerg alert crit err warning; do
		tResult=$(fLog $tLevel "$tMsg" 2>&1)
		fUDebug $tResult
		assertContains "tl-6.1" "$tResult" "$tLevel:"
		tResult=$(tail -n1 $tSyslog)
		fUDebug $tResult
		assertContains "tl-6.2" "$tResult" "$tLevel:"
		assertContains "tl-6.3" "$tResult" "$tMsg"
	done
}

testErrorLog()
{
	local tMsg
	local tLevel
	local tLine
	local tErr
	local tResult

	gpLog=0
	gpVerbose=0
	local tMsg="Testing 123"
	local tLine="458"
	local tErr="42"
	tResult=$(fError "$tMsg" $tLine $tErr 2>&1)
	fUDebug $tResult

	assertContains "tel-1.1" "$tResult" "$cName"
	assertContains "tel-1.2" "$tResult" '['$cPID']'
	assertContains "tel-1.3" "$tResult" "crit:"
	assertContains "tel-1.4" "$tResult" "$tMsg"
	assertContains "tel-1.5" "$tResult" '['$tLine']'
	assertContains "tel-1.6" "$tResult" '('$tErr')'
	assertContains "tel-1.7" "$tResult" "Usage:"
}

testCleanUp()
{
	gpDebug=0
	local tResult
	
	assertEquals "tcu-1" "/tmp/$USER/$cName" "$Tmp"
	assertTrue "tcu-2" "[ -d $Tmp ]"
	
	assertEquals "tcu-3" "$Tmp/file-$cPID" "$cTmpF"
	
	assertEquals "tcu-4" "${cTmpF}-1.tmp" "$cTmp1"
	touch $cTmp1
	assertTrue "tcu-5" "[ -f $cTmp1 ]"

	tResult=$(fCleanUp 2>&1)
	assertFalse "tcu-6" "[ -f $cTmp1 ]"
}

# ========================================
# Functions

# --------------------------------
fCleanUp()
{
	trap - 1 2 3 4 5 6 7 8 10 11 12 13 14 15
	# Called when script ends (see trap) to remove temporary files,
	# if not in debug mode.
	if [ $gpDebug -eq 0 ]; then
		'rm' -f ${cTmpF}*.tmp 2>/dev/null
	fi
	fLog notice "Done" $LINENO 9900
	exit $gErr
} # fCleanUp

# --------------------------------
fUsage()
{
	if [ $# -ne 0 ]; then
		pod2text $0
	else
		pod2usage $0
	fi
	gErr=1
	fCleanUp
	exit 1
	cat <<EOF >/dev/null
=pod

=head1 NAME

SCRIPTNAME - DESCRIPTION

=head1 SYNOPSIS

	SCRIPTNAME [-o Value] [-h] [-l] [-v] [-x] [-t Test]

=head1 DESCRIPTION

Describe the script.

=head1 OPTIONS

=over 4

=item B<-h>

This help.

=item B<-l>

Send log messages to syslog.

=item B<-v>

Verbose output.  Sent to stderr.

=item B<-x>

Debug mode.  But do not log to syslog. Multiple x options turns
on more debug output. See Global gpDebug.

=item B<-t Test>

Run the unit test functions in this script.

If Test is "all", then all of the functions that begin with "test"
will be run. Otherwise "Test" should match the test function names
separated with commas (with all names in a quote).

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html Source: https://github.com/kward/shunit2

See shunit2, shunit2.1, Global: gpUnitDebug

=back

=head2 Globals

Globals that may affect how way the script runs. Just about all of
these globals can be set and exported before the script is run (just
in case you cannot easily set them with CLI flags).

=item B<Tmp>

This is the top directory where tmp file will be put.

Default: /tmp/$USER/SCRIPTNAME/

if gpDebug is 0, temp files will usually include the PID.

=item B<gpLog>

If set to 0, log messages will only be sent to stderr.

If set to 1, log messages will be sent to stderr and syslog.

See -l, fLog and fErr for details

Default: 0

=item B<gpFacility>

Log messages sent to syslog will be sent to the "facility" specified
by by gpFacility.

"user" log messages will be sent to /var/log/user.log, or
/var/log/syslog, or /var/log/messages.log

See: fLog

Default: user

=item B<gpVerbose>

If set to 0, only log message at "warning" level and above will be output.

If set to 1, all non-debug messages will be output.

See -v, fLog

Default: 0

=item B<gpDebug>

If set to 0, all "debug" and "debug-N" level messages will be skipped.

If not 0, all "debug" level messages will be output.

Or if "debug-N" level is used, then if gpDebug is <= N, then the
log message will be output, otherwise it is skipped.

See -x

=item B<gpUnitDebug>

If set to non-zero, then the fUDebug function calls will output
the messages when in test functions.

See -t, fUDebug

=back

=head1 RETURN VALUE

[What the program or function returns if successful.]

=head1 ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following log message format:

 Program: PID NNNN: Message [LINE](ErrNo)

=head1 EXAMPLES

=head1 ENVIRONMENT

 $HOME
 $USER
 $Tmp

=head1 FILES

=head1 SEE ALSO

=head1 NOTES

=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

[All possible messages the program can print out--and what they mean.]

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

NAME

=head1 HISTORY

(c) Copyright 2009 by COMPANY

$Revision: 1.36 $ GMT 

=cut
EOF
	fCleanUp 1
	exit 1
} # fUsage

# --------------------------------
fError()
{
	# Usage:
	#     fError pMsg [pLine [pErr]]
	# Print the error message.  Then call fCleanUp, and exit

	local pMsg="$1"
	local pLine=$2
	local pErr=$3

	fLog crit "$pMsg" $pLine $pErr
	fUsage
} # fError

# ------------------
fLog()
{
	# Usage:
	#     fLog Level "Msg" [LineNo] [Err] [extra...]
	#     pLevel - emerg alert crit err warning notice info debug
	#
	# Examples:
	#     fLog notice "Just testing" $LINENO 8 "added to msg"
	#     fLog debug-3 "Only if $gpDebug>=3" $LINENO
	#
	# Globals
	#     gpLog=0 - output to stderr only
	#     gpLog=1 - output to syslog and stderr
	#     gpFacility - only used with syslog.
	#     		 user, local[0-7], auth, authpriv, cron, daemon,
        #		 ftp, kern, lpr, mail, news, sslog, uucp
	#     gpVerbose=0 - ignore all levels below warning
	#     gpVerbose=1 - output notice and info
	#     gpDebug=0 - debug msgs are not output
	#     gpDebug=N - debug msgs are output, or if debug-N > N, then skip

	local pLevel="alert"
	local pMsg="Missing message"
	local pLine=""
	local pErr=""
	local tLevel
	local tLine=""
	local tErr=""
	local tDebugLevel

	# Get args
	case $# in
		1)
			pLevel=$1
		;;
		2)
			pLevel=$1
			pMsg=$2
		;;
		3)
			pLevel=$1
			pMsg=$2
			pLine=$3
		;;
		4)
			pLevel=$1
			pMsg=$2
			pLine=$3
			pErr=$4
		;;
		*)
			pLevel=$1
			pMsg=$2
			pLine=$3
			pErr=$4
			shift 4
			pMsg="$pMsg - $*"
		;;
	esac
	tLevel=$pLevel

	# Set any missing globals
	gpLog=${gpLog:-0}
	gpFacility=${gpFacility:-user}
	gpVerbose=${gpVerbose:-0}
	gpDebug=${gpDebug:-0}

	# Check debug
	if [ $gpDebug -eq 0 ] && [ "${pLevel%-*}" = "debug" ]; then
		return
	fi
	if [ $gpDebug -ne 0 ] && [ "${pLevel%-[0-9]*}" != "$pLevel" ]; then
		tDebugLevel=${pLevel#*-}
		fUDebug echo tDebugLevel=x${tDebugLevel}x
		if [ $tDebugLevel -gt $gpDebug ]; then
			return
		fi
		tLevel=debug
	fi

	# Check verbose
	if [ $gpVerbose -eq 0 ] &&
	     ( [ "$pLevel" = "notice" ] || [ "$pLevel" = "info" ] ); then
		return
	fi

	# LineNo formatting
	tLine=""
	if [ -n "$pLine" ]; then
		tLine="[$pLine]"
	fi

	# Err formatting
	tErr=""
	if [ -n "$pErr" ]; then
		tErr="($pErr)"
	fi

	# Output
	if [ $gpLog -eq 0 ]; then
		echo "${cName}[$$] $pLevel: $pMsg $tLine$tErr" 1>&2
	else
		logger -s -i -t $cName -p $gpFacility.$tLevel "$pLevel: $pMsg $tLine$tErr"
	fi
} # fLog

# ========================================
# Main

# -------------------
# Set name of this script
export cName=${0##*/}

# -------------------
# Set current directory location in PWD and cCurDir, because with cron
# jobs PWD is not set.
if [ -z "$PWD" ]; then
	export PWD=$(pwd)
fi
export cCurDir=$PWD

# -------------------
# Define the location of the script
export cBin=${0%/*}
if [ "$cBin" = "." ]; then
        cBin=$PWD
fi
cd $cBin
cBin=$PWD
cd $cCurDir

# -------------------
# Setup log variables
export gpDebug=${gpDebug:-0}
export gpVerbose=${gpVerbose:-0}
export gpLog=${gpLog:-0}
export gpFacility=${gpFacility:=user}
export gpTest="";
export gErr=0

# -------------------
# Define the version number for this script
export cVer='$Revision: 1.36 $'
cVer=${cVer#*' '}
cVer=${cVer%' '*}

# -------------------
# Setup a temporary directory for each user/script.
export Tmp=${Tmp:-"/tmp/$USER/$cName"}
if [ ! -d $Tmp ]; then
	mkdir -p $Tmp 2>/dev/null
	if [ ! -d $Tmp ]; then
		fError "Could not find directory $Tmp (\$Tmp)." $LINENO
	fi
fi

# -------------------
# Define temporary file names used by this script.  The variables for
# the file names can be any name, but the file name pattern should be:
# "${cTmpF}-*.tmp"
export cPID=$$
export cTmpF=$Tmp/file-$cPID
if [ $gpDebug -ne 0 ]; then
	cTmpF=$Tmp/file
	rm -f ${cTmpF}*.tmp 2>/dev/null
fi
export cTmp1=${cTmpF}-1.tmp
export cTmp2=${cTmpF}-2.tmp
trap fCleanUp 1 2 3 4 5 6 7 8 10 11 12 13 14 15

# -------------------
# Configuration

# -------------------
# Get Options Section
if [ $# -eq 0 ]; then
	fError "Missing options." $LINENO
fi
export gpFileList=""
export gpHostName=""
while getopts :cn:hlt:vx tArg; do
	case $tArg in
		c)	gpHostName=$(hostname);;
		n)	gpHostName=$OPTARG;;

		h)	fUsage long;;
		l)	gpLog=1;;
		v)	gpVerbose=1;;
		x)	let gpDebug=gpDebug+1;;
		t)	gpTest=$OPTARG;;
		:)	fError "Value required for option: $OPTARG" $LINENO;;
		\?)	fError "Unknown option: $OPTARG" $LINENO;;
	esac
done
let tOptInd=OPTIND-1
shift $tOptInd
if [ $# -ne 0 ]; then
	gpFileList="$*"
fi

# -------------------
if [ -n "$gpTest" ]; then
	export SHUNIT_COLOR=light
	export gpUnitDebug=${gpUnitDebug:-0}
	if [ "$gpTest" = "all" ]; then
		. /usr/local/bin/shunit2.1
		exit $?
	fi
	. /usr/local/bin/shunit2.1 -- $gpTest
	exit $?
fi

# -------------------
# Print dump of variables
if [ $gpDebug -gt 1 ]; then
	for i in \
		PWD \
		cBin \
		cCurDir \
		cName \
		cVer \
		gpDebug \
		gpVerbose \
		gErr \
		gpHostName \
		Tmp \
	; do
		tMsg=$(eval echo -R "$i=\$$i")
		fLog debug "$tMsg" $LINENO
	done
fi

# -------------------
# Validate Options Section

if [ -z $gpHostName ]; then
	fError "The -n or -c option is required." $LINENO
fi

# -------------------
# Functional Section

cat <<EOF >$cTmp1
	\$1 == "$gpTag" {
		if (\$2 ~ /$gpHostName/) {
			\$1 = ""
			\$2 = ""
			sub(/^  /,"",\$0)
			echo \$0
		 }
		 next
	}
	{ echo \$0}
EOF
timeout 5 awk -f $cTmp1

for i in $(seq 2 40); do
	if [ -e "File$i" ]; then
		echo "Found File$i"
	fi
done

# -------------------
# Cleanup Section
fCleanUp
