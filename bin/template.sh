#!/bin/bash
# $Source: /repo/local.cvs/per/bruce/bin/template.sh,v $
# $Revision: 1.43 $ $Date: 2021/08/25 09:59:48 $ GMT

# ========================================
# Tests

fUDebug()
{
	if [ ${gpUnitDebug:-0} -ne 0 ]; then
		echo "fUDebug: $*"
	fi
	return

	# This should be the first =internal-pod
    	cat <<EOF >/dev/null
=internal-pod

=internal-head1 SCRIPTNAME Internal Documentation

=internal-head2 Template Use

* Copy template.sh to your script file.

* Globally replace SCRIPTNAME to the name of your script file.

* Update the getopts in the Get Args Section

* Loop: document args (with POD), add tests, add validate function

* Loop: add function tests, add functions

=internal-head3 Block Organization

 * Configuration - exit if errors
 * Get Args - exit if errors
 * Verify external progs - exit if errors
 * Run tests - if gpTest is set
 * Validate Args - exit if errors
 * Verify connections work - exit if errors
 * Read-only functional work - exit if errors
 * Write functional work - now you are committed! Try to keep going if errors
 * Output results and/or launch next process

To avoid a lot of rework or and manual rollbacks, put-off I<writes> that
cannot undone. Do as much as possible to make sure the script will be able
to complete write operations.

For example, B<do not do this:> collect information, transform it,
write it to a DB, then start the next process on another
server. Whoops, that server cannot be accessed! Gee, why didn't you
verify all the connections you will need, before committing to the
DB?!  Even if you did check the connection could fail after the check,
so maybe write to a tmp DB, then when all is OK, update the master DB
with the tmp DB changes.

Where ever possible make your scripts "re-entrant". Connections can
fail at anytime and scripts can be killed at anytime; How it any
important work continued or work reverted?

=internal-head3 Variable Naming Convention

Prefix codes are used to show the "scope" of variables):

 gVar - global variable (may even be external to the script)
 pVar - a function parameter I<local>
 gpVar - global parameter, i.e. may be defined external to the script
 cVar - global constant (set once)
 tVar - temporary variable (usually I<local> to a function)
 fFun - function

All UPPERCASE variables are I<only> used when they are required by other
programs or scripts.

=internal-head3 Global Variables

For more help, see the Globals section in fUsage.

 gpLog - -l
 gpVerbose - -v, -vv
 gpDebug - -x, -xx, ...
 gpTest - -t
 Tmp - personal tmp directory.  Usually set to: /tmp/$USER
 cTmpF - tmp file prefix.  Includes $$ to make it unique
 cTmp1 - a temp file with a pattern that fCleanUp will remove
 gErr - error code (0 = no error)
 cName - script's name taken from $0
 cCurDir - current directory
 cBin - directory where the script is executing from
 cVer - current version

=internal-head3 Documentation Format

POD is use to format the script's documentation. Sure MarkDown could
have been used, but it didn't exist 20 years ago. POD text can be
output as text, man, html, pdf, texi, just usage, and even MarkDown

Help for POD can be found at:
L<perlpod - the Plain Old Documentation format|https://perldoc.perl.org/perlpod>

The documentation is embedded in the script so that it is more likely
to be updated. Separate doc files seem to I<always> drift from the
code. Feel free to delete any documentation, if the code is clear
enough.  BUT I<clean up your code> so that the code I<really> is
clear.

The internal documentation uses POD commands that begin with "=internal-".
See fInternalDoc() for how this is used.

Also TDD (Test Driven Development) should make refactoring easy,
because the tests are also embedded in the script.

=internal-head2 Unit Test Functions

=internal-cut
EOF
} # fUDebug

oneTimeSetUp()
{
	# Save global values
	export tDefault_Tmp=$Tmp
	export tDefault_cBin=$cBin
	export tDefault_cCurDir=$cCurDir
	export tDefault_cName=$cName
	export tDefault_cPID=$cPID
	export tDefault_cTmp1=$cTmp1
	export tDefault_cTmpF=$cTmpF
	export tDefault_cVer=$cVer
	export tDefault_gErr=0
	export tDefault_gpDebug=0
	export tDefault_gpFacility=user
	export tDefault_gpLog=0
	export tDefault_gpVerbose=0
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 oneTimeSetuUp

Currently this records all of the script's expected initial global
variable settings, defined in fSetGlobals. If different, adjust the
tests as needed.

=internal-cut
EOF
} # oneTimeSetUp

setUp()
{
	# Restore global values
	Tmp=$tDefault_Tmp
	cBin=$tDefault_cBin
	cCurDir=$tDefault_cCurDir
	cName=$tDefault_cName
	cPID=$tDefault_cPID
	cTmp1=$tDefault_cTmp1
	cTmpF=$tDefault_cTmpF
	cVer=$tDefault_cVer
	gErr=$tDefault_gErr
	gpDebug=$tDefault_gpDebug
	gpFacility=$tDefault_gpFacility
	gpLog=$tDefault_gpLog
	gpVerbose=$tDefault_gpVerbose
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 oneTimeSetuUp

Before each test runs, this restores all of the script's initial
global variable settings,

=internal-cut
EOF
} # setUp

testInitialConfig()
{
	local tProg

	assertEquals "tic-1" "$PWD" "$cCurDir"
	assertTrue "tic-2" "[ -d $cCurDir ]"

	# ADJUST
	assertEquals "tic-3" "template.sh" "$cName"
	#assertEquals "tic-4" "SCRIPTNAME" "$cName"

	# ADJUST
	#assertEquals "tic-5" "/usr/bin" "$cBin"
	#assertEquals "tic-5" "/usr/local/bin" "$cBin"

	assertNotNull "tic-6" "$cBin"
	assertTrue "tic-7" "[ -d $cBin ]"
	assertTrue "tic-8" "[ -f $cBin/$cName ]"
	assertTrue "tic-9" "[ -x $cBin/$cName ]"

	assertEquals "tic-10" "0" "$gpDebug"
	assertEquals "tic-11" "0" "$gpVerbose"
	assertEquals "tic-12" "0" "$gpLog"
	assertEquals "tic-13" "user" "$gpFacility"
	assertEquals "tic-14" "0" "$gErr"
	assertNull "tic-15" "$(echo $cVer | tr -d '.[:digit:]')"
	assertEquals "tic-16" "/tmp/$USER/$cName" "$Tmp"
	assertEquals "tic-17" "$Tmp/file-$cPID" "$cTmpF"
	assertEquals "tic-18" "${cTmpF}-1.tmp" "$cTmp1"

	# ADJUST
	assertEquals "tic-19" "/tmp/$USER/$cName" "$Tmp"

	for tProg in logger pod2text pod2usage pod2html pod2man pod2markdown tidy awk tr; do
		which $tProg &>/dev/null
		assertTrue "tic-20 missing: $tProg" "[ $? -eq 0 ]"
	done
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testInitialConfig

Verify all of the global variables are correctly defined.

=internal-cut
EOF
} # testInitialConfig

testLog()
{
	local tMsg
	local tLevel
	local tLine
	local tErr
	local tExtra
	local tResult
	local tLog
	local tTestMsg

	# ADJUST?
	export tSyslog=/var/log/user.log
	#export tSyslog=/var/log/messages.log
	#export tSyslog=/var/log/syslog

	# Check format, for a number of settings
	gpLog=0
	gpVerbose=0
	gpDebug=0
	tMsg="Testing 123"
	tLine="458"
	tErr="42"
	tExtra="extra text"

	gpUnitDebug=0
	for gpLog in 0 1; do
	  for gpVerbose in 0 1 2; do
	    for gpDebug in 0 1 2; do
	      for tLevel in alert crit err warning notice info debug debug-1 debug-3; do
	        for tLog in "fLog" "fLog2"; do
	          tTestMsg="l-$gpLog.v-$gpVerbose.d-$gpDebug.$tLevel.$tLog"
	          if [ "$tLog" = "fLog" ]; then
		    fUDebug " "
		    fUDebug "Call: fLog $tLevel \"$tMsg\" $tLine $tErr $tExtra"
		    tResult=$(fLog $tLevel "$tMsg" $tLine $tErr $tExtra 2>&1)
	          fi
	          if [ "$tLog" = "fLog2" ]; then
		    fUDebug " "
		    fUDebug "Call: fLog2 -p $tLevel -m \"$tMsg\" -l $tLine -e $tErr $tExtra"
		    tResult=$(fLog2 -p $tLevel -m "$tMsg" -l $tLine -e $tErr $tExtra 2>&1)
	      	  fi
		  fUDebug "tResult=$tResult"

		  if [ $gpVerbose -eq 0 ] && echo $tLevel | grep -Eq 'notice|info'; then
	              assertNull "tl1-$tTestMsg not notice,info" "$tResult"
		      continue
		  fi
		  if [ $gpVerbose -eq 1 ] && echo $tLevel | grep -Eq 'info'; then
	              assertNull "tl1-$tTestMsg not info" "$tResult"
		      continue
		  fi		  
		  if [ $gpDebug -eq 0 ] && [ "${tLevel%%-*}" = "debug" ]; then
	              assertNull "tl2-$tTestMsg not debug" "$tResult"
		      continue
		  fi
		  if [ $gpDebug -lt 2 ] && [ "$tLevel" = "debug-2" ]; then
	              assertNull "tl3-$tTestMsg not debug-2" "$tResult"
		      continue
		  fi
		  if [ $gpDebug -lt 3 ] && [ "$tLevel" = "debug-3" ]; then
	              assertNull "tl4-$tTestMsg not debug-3" "$tResult"
		      continue
		  fi
	      	  assertContains "tl5-$tTestMsg.name" "$tResult" "$cName"
	      	  assertContains "tl6-$tTestMsg.level" "$tResult" "$tLevel:"
	      	  assertContains "tl7-$tTestMsg.msg" "$tResult" "$tMsg"
	      	  assertContains "tl8-$tTestMsg.line" "$tResult" '['$tLine']'
	      	  assertContains "tl9-$tTestMsg.$tLevel.err" "$tResult" '('$tErr')'
	      	  assertContains "tl10-$tTestMsg.extra" "$tResult" " - $tExtra"
	        done
	      done
	    done
	  done
	done
	gpUnitDebug=0

	# Check syslog
	gpUnitDebug=0
	gpLog=1
	gpVerbose=0
	tMsg="Testing 123"
	#for tLevel in emerg alert crit err warning; do
	for tLevel in alert crit err warning; do
	    for tLog in "fLog" "fLog2"; do
	    	tTestMsg="$tLevel.$tLog"
		fUDebug " "
	        if [ "$tLog" = "fLog" ]; then
		    fUDebug "Call: $tLog $tLevel $tMsg"
		    tResult=$($tLog $tLevel "$tMsg" 2>&1)
		fi
	        if [ "$tLog" = "fLog2" ]; then
		    fUDebug "Call: $tLog -p $tLevel -m \"$tMsg\""
		    tResult=$($tLog -p $tLevel -m "$tMsg" 2>&1)
		fi
		fUDebug "tResult=$tResult"
		assertContains "tl11-$tTestMsg" "$tResult" "$tLevel:"
		tResult=$(tail -n1 $tSyslog)
		fUDebug "syslog tResult=$tResult"
		assertContains "tl12-$tTestMsg" "$tResult" "$tLevel:"
		assertContains "tl13-$tTestMsg" "$tResult" "$tMsg"
	    done
	done
	gpUnitDebug=0
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testLog

Test fLog and fLog2.

=internal-cut
EOF
} # testLog

testErrorLog()
{
	local tMsg
	local tLevel
	local tLine
	local tErr
	local tResult
	local tLog
	local tTestMsg

	gpUnitDebug=0
	gpLog=0
	gpVerbose=0
	local tMsg="Testing 123"
	local tLine="458"
	for gpLog in 0 1; do
	    for tLog in "fError" "fError2"; do
	    	tTestMsg="l-$gpLog.$tLog"
		fUDebug " "
	        if [ "$tLog" = "fError" ]; then
		    fUDebug "Call: $tLog \"$tMsg\" $tLine"
		    tResult=$($tLog "$tMsg" $tLine 2>&1)
		fi
	        if [ "$tLog" = "fError2" ]; then
		    fUDebug "Call: $tLog -m \"$tMsg\" -l $tLine"
		    tResult=$($tLog -m "$tMsg" -l $tLine 2>&1)
		fi
		fUDebug "tResult=$tResult"
		assertContains "tel-$tTestMsg.name" "$tResult" "$cName"
		assertContains "tel-$tTestMsg.crit" "$tResult" "crit:"
		assertContains "tel-$tTestMsg.msg" "$tResult" "$tMsg"
		assertContains "tel-$tTestMsg.line" "$tResult" '['$tLine']'
		# shellcheck disable=SC2026
		assertContains "tel-$tTestMsg.err" "$tResult" '('1')'
		assertContains "tel-$tTestMsg.usage" "$tResult" "Usage:"
	    done
	done
	gpUnitDebug=0
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testErrorLog

Test fError and fError2.

=internal-cut
EOF
} # testErrorLog

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
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testCleanUp

Test fCleanUp. Verify the tmp files are removed.

=internal-cut
EOF
} # testCleanUp

testUsage()
{
	local tResult
gpUnitDebug=1
	fUDebug "NA"
gpUnitDebug=0
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testUsage

Test fUsage. Verify the different output styles work.

=internal-cut
EOF
} # testUsage

# ========================================
# Functions

# --------------------------------
fCleanUp()
{
	# shellcheck disable=SC2172
	trap - 1 2 3 4 5 6 7 8 10 11 12 13 14 15
	if [ $gpDebug -eq 0 ]; then
		'rm' -f ${cTmpF}*.tmp 2>/dev/null
	fi
	fLog notice "Done" $LINENO 9900
	exit $gErr
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head2 Common Script Functions

=internal-head3 fCleanUp

Called when script ends (see trap) to remove temporary files.
Except if gpDebug != 0, then tmp files are not removed.

=internal-cut
EOF
} # fCleanUp

# --------------------------------
fInternalDoc()
{
	local pScript=$1
	
	awk '
		/^=internal-pod/,/^=internal-cut/ {
			sub(/^=internal-/,"=");
			print $0;
		}
	' < $pScript
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fInternalDoc

This function collects all of the "pod-internal" documentation.

=internal-cut
EOF
} # fInternalDoc

# --------------------------------
fUsage()
{
	local pStyle="$1"
	
	local tScript=$cBin/$cName
	local tTidy='tidy -m -q -i -w 78 -asxhtml --break-before-br yes --indent-attributes yes --indent-spaces 2 --tidy-mark no --vertical-space no'

	if [ -z "$pStyle" ]; then
		pStyle=short
	fi

	case $pStyle in
		short)	pod2usage $tScript;;
		long)	pod2text $tScript;;
		man)	pod2man $tScript;;
		html)	pod2html $tScript --title="SCRIPTNAME" | $tTidy;;
		md)	pod2markdown <$tScript;;
		internal)	fInternalDoc $tScript | pod2text;;
		internal-html)	fInternalDoc $tScript | pod2html --title="SCRIPTNAME Internal Documentation" | $tTidy;;
		internal-md)	fInternalDoc $tScript | pod2markdown;;
		*)	pod2usage $tScript;;
	esac
	gErr=1
	fCleanUp
	exit 1

	cat <<\EOF >/dev/null
=pod

=head1 NAME

SCRIPTNAME - DESCRIPTION

=head1 SYNOPSIS

	SCRIPTNAME [-o "Name=Value"] [-h] [-H Style] [-l] [-v] [-x] [-T Test]

=head1 DESCRIPTION

Describe the script.

=head1 OPTIONS

=over 4

=item B<-o Name=Value>

[This is a placeholder for user options.]

=item B<-h>

Output this "long" usage help. See "-H long"

=item B<-H Style>

Style is used to select the type of help and how it is formatted.

Styles:

=over 8

=item B<short>

Output short usage help as text.

=item B<long>

Output long usage help as text.

=item B<man>

Output long usage help as a man page.

=item B<html>

Output long usage help as html.

=item B<md>

Output long usage help as markdown.

=item B<internal>

Output internal documentation as text.

=item B<internal-html>

Output internal documentation as html.

=item B<internal-md>

Output internal documentation as markdown.

=back

=item B<-l>

Send log messages to syslog. Default is to just send output to stderr.

=item B<-v>

Verbose output. Default is is only output (or log) messages with
level "warning" and higher.

-v - output "notice" and higher.

-vv - output "info" and higher.

=item B<-x>

Set the gpDebug level. Add 1 for each -x.
Or you can set gpDebug before running the script.

See: fLog and fLog2

=item B<-T Test>

Run the unit test functions in this script.

If Test is "all", then all of the functions that begin with "test"
will be run. Otherwise "Test" should match the test function names
separated with commas (with all names in a quote).

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html
L<Source|https://github.com/kward/shunit2>

See shunit2, shunit2.1, Global: gpUnitDebug

Also for more help, use the "-H internal" option.

=back

=head2 Globals

Globals that may affect how way the script runs. Just about all of
these globals can be set and exported before the script is run (just
in case you cannot easily set them with CLI flags).

=over 4

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

Allowed facility names:

 local0 through local7 - for local use (these are some suggested uses)
    local0 - system or application configuration
    local1 - application processes
    local2 - web site errors
    local3 - web site access
    local4 - backend processes
    local5 - publishing
    local6 - available
    local7 - available
 user - misc scripts, generic user-level messages
 auth - security/authorization messages
 authpriv - security/authorization messages (private)
 cron - clock daemon (cron and at)
 daemon - system daemons without separate facility value
 ftp - ftp daemon
 kern - kernel  messages  (these  can't be generated from user processes)
 lpr - line printer subsystem
 mail - mail subsystem
 news - USENET news subsystem
 syslog - messages generated internally by syslogd(8)
 uucp - UUCP subsystem
       
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

See -T, fUDebug

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

See Globals section for details.

HOME,USER, Tmp, gpLog, gpFacility, gpVerbose, gpDebug, gpUnitDebug

=head1 FILES

=head1 SEE ALSO

shunit2

=head1 NOTES

=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

[All possible messages the program can print out--and what they mean.]

To verify the script is internally OK, run: SCRIPTNAME -T all

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

NAME

=head1 HISTORY

(c) Copyright 2021 by COMPANY

$Revision: 1.43 $ $Date: 2021/08/25 09:59:48 $ GMT 

=cut
EOF
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fUsage pStyle

This function selects the type of help output. See -h and -H options.

=internal-cut
EOF
} # fUsage

# ------------------
fFmtLog()
{
	local pLevel=$1
	local pMsg="$2"
	local pLine=$3
	local pErr=$4

	local tDebugLevel
	local tLevel
	local tLine
	local tErr

	# Set any missing globals
	gpLog=${gpLog:-0}
	gpFacility=${gpFacility:-user}
	gpVerbose=${gpVerbose:-0}
	gpDebug=${gpDebug:-0}

	tLevel=$pLevel

	# Check debug
	if [ $gpDebug -eq 0 ] && [ "${pLevel%-*}" = "debug" ]; then
		return
	fi
	if [ $gpDebug -ne 0 ] && [ "${pLevel%%-*}" != "$pLevel" ]; then
		tDebugLevel=${pLevel##*-}
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
	if [ $gpVerbose -eq 1 ] && [ "$pLevel" = "info" ]; then
		return
	fi

	# LineNo format
	tLine=""
	if [ -n "$pLine" ]; then
		tLine="[$pLine]"
	fi

	# Err format
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
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fFmtLog pLevel "pMsg" pLine pErr

This function formats and outputs a consistent log message output.
See: fLog, fLog2, fError, and fError2.

=internal-cut
EOF
} # fFmtLog

# ------------------
fLog()
{
	local pLevel="alert"
	local pMsg="Missing message"
	local pLine=""
	local pErr=""

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

	fFmtLog $pLevel "$pMsg" $pLine $pErr
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLog pLevel "pMsg" [$LINENO] [pErr] [extra text...]

pLevel - emerg alert crit err warning notice info debug debug-N

See Globals: gpLog, gpFacility, gpVerbose, gpDebug

=internal-head4 fLog Examples:

 fLog notice "Just testing" $LINENO 8 "added to msg"
 fLog debug "Output only if $gpDebug>0" $LINENO
 fLog debug-3 "Output only if $gpDebug>0 and $gpDebug<=3" $LINENO
 
=internal-cut
EOF
} # fLog

# --------------------------------
fError()
{
	# Usage:
	#     fError pMsg [pLine [pErr]]
	# Print the error message.  Then call fCleanUp, and exit

	local pMsg="$1"
	local pLine=$2
	local pErr=$3

	fLog crit "$pMsg" ${pLine:-.} ${pErr:-1}
	fUsage short
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fError "pMsg" [$LINENO] [pErr]

This will call: fLog crit "pMsg" pLine pErr

Then it will call "fUsage short", which will exit after fCleanUp.

=internal-cut
EOF
} # fError

# ------------------
fLog2()
{
	local pLevel="info"
	local pMsg=""
	local pLine=""
	local pErr=""
	
	local OPTARG
	local OPTIND
	local tArg

	while getopts m:p:l:e: tArg; do
		case $tArg in
			m)	pMsg="${OPTARG}";;
			l)	pLine="${OPTARG}";;
			p)	pLevel="${OPTARG}";;
			e)
				pErr="${OPTARG}"
				gErr="${OPTARG}"
			;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pMsg="$pMsg - $*"
	fi
	while [ $# -ne 0 ]; do
		shift
	done

	fFmtLog $pLevel "$pMsg" $pLine $pErr
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLog2 -m pMsg [-p pLevel] [-l $LINENO] [-e pErr] [extra...]

This is like fLog, but the arguments can be in any order.

See fLog. See also global gpFacility

=internal-cut
EOF
} # fLog2

# --------------------------------
fError2()
{
	local pMsg="Error"
	local pLine="."
	local pErr=1
	local OPTIND
	local OPTARG
	local tArg
	
	while getopts m:l:e: tArg; do
		case $tArg in
			m)	pMsg="${OPTARG}";;
			l)	pLine="${OPTARG}";;
			e)	pErr="${OPTARG}";;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pMsg="$pMsg $*"
	fi
	while [ $# -ne 0 ]; do
		shift
	done
	gErr=$pErr

	fLog2 -p crit -l $pLine -e $pErr -m "$pMsg"
	fUsage short
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fError2 -m pMsg [-l $LINENO] [-e pErr]

This will call: fLog2 -p crit -m "pMsg" -l pLine -e pErr

Then it will call "fUsage short", which will exit after fCleanUp.

=internal-cut
EOF
} # fError2

# --------------------------------
fCheckDeps()
{
	local pRequired="$1"
	local pOptional="$2"
    
	local tProg
	local tErr=0

	for tProg in $pOptional; do
		if ! which $tProg &>/dev/null; then
			echo "Optional: Missing $tProg"
			tErr=1
		fi
	done

	for tProg in $pRequired; do
		if ! which $tProg &>/dev/null; then
			echo "Required: Missing $tProg"
			tErr=2
		fi
	done

	if [ $tErr -eq 2 ]; then
		echo "Error: Missing one or more required programs."
		fCleanUp
	fi
	if [ $tErr -eq 1 ]; then
		fLog2 -p warning -m "Missing some some optional programs." -l $LINENO
	fi
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fCheckDeps "pRequired List" "pOptional List"

Check for required and optional programs or scripts used by this script.
If any required programs are missing, exit the script.

=internal-cut
EOF
} # fCheckDeps

# -------------------
fSetComGlobals()
{
	# -------------------
	# Set name of this script
	cName=${0##*/}

	# -------------------
	# Set current directory location in PWD and cCurDir, because with cron
	# jobs PWD is not set.
	if [ -z "$PWD" ]; then
		PWD=$(pwd)
	fi
	cCurDir=$PWD

	# -------------------
	# Define the location of the script
	cBin=${0%/*}
	if [ "$cBin" = "." ]; then
	        cBin=$PWD
	fi
	cd $cBin
	cBin=$PWD
	cd $cCurDir

	# -------------------
	# Setup log variables
	gpDebug=${gpDebug:-0}
	gpVerbose=${gpVerbose:-0}
	gpLog=${gpLog:-0}
	gpFacility=${gpFacility:=user}
	gErr=0

	# -------------------
	# Define the version number for this script
	# shellcheck disable=SC2016
	cVer='$Revision: 1.43 $'
	cVer=${cVer#*' '}
	cVer=${cVer%' '*}

	# -------------------
	# Setup a temporary directory for each user/script.
	Tmp=${Tmp:-"/tmp/$USER/$cName"}
	if [ ! -d $Tmp ]; then
		mkdir -p $Tmp 2>/dev/null
		if [ ! -d $Tmp ]; then
			fError "Could not find directory $Tmp (\$Tmp)." $LINENO
		fi
	fi

	# -------------------
	# Define temporary file names used by this script.  The
	# variables for the file names can be any name, but the file
	# name pattern should be:
	# "${cTmpF}-*.tmp"
	cPID=$$
	cTmpF=$Tmp/file-$cPID
	if [ $gpDebug -ne 0 ]; then
		cTmpF=$Tmp/file
		rm -f ${cTmpF}*.tmp 2>/dev/null
	fi
	cTmp1=${cTmpF}-1.tmp
	cTmp2=${cTmpF}-2.tmp
	# shellcheck disable=SC2172
	trap fCleanUp 1 2 3 4 5 6 7 8 10 11 12 13 14 15

	# -------------------
	gpTest=${gpTest:-""};
	gpUnitDebug=${gpUnitDebug:-0}
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fSetComGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

=internal-cut
EOF
} # fSetComGlobals

# -------------------
fSetGlobals()
{
	# Put your globals here
	gpTag=${gpTag:-build}
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head2 Script Functions

=internal-head3 fSetGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

=internal-cut
EOF
} # fSetGlobals

# -------------------
fValidateHostName()
{
	if [ -z $gpHostName ]; then
		fError "The -n or -c option is required." $LINENO
	fi
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fValidateHostName

Exit if missing.

=internal-cut
EOF
} # fValidateHostName

# -------------------
# This should be the last defined function
fRunTests()
{
	# export SHUNIT_COLOR=none
	export SHUNIT_COLOR=light
	export gpUnitDebug=${gpUnitDebug:-0}
	if [ "$gpTest" = "all" ]; then
		# shellcheck disable=SC1091
		. /usr/local/bin/shunit2.1
		exit $?
	fi
	# shellcheck disable=SC1091
	. /usr/local/bin/shunit2.1 -- $gpTest
	exit $?
} # fRunTests

# ========================================
# Main

# -------------------
# Configuration Section

export PWD
export Tmp
export cBin
export cCurDir
export cName
export cPID
export cTmp1
export cTmp2
export cTmpF
export cVer
export gErr
export gpDebug
export gpFacility
export gpLog
export gpVerbose

# Test globals
export gpTest
export gpUnitDebug
export SHUNIT_COLOR

# Functional globals
export gpFileList=""

fSetComGlobals
fCheckDeps "logger pod2text pod2usage" "pod2html pod2man pod2markdown tidy shunit2.1 awk tr"
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
	fError2 -m "Missing options." -l $LINENO
	fUsage short
fi
gpFileList=""
export gpHostName=""
while getopts :cn:t:hH:lT:vx tArg; do
	case $tArg in
		c)	gpHostName=$(hostname);;
		n)	gpHostName="$OPTARG";;
		t)	gpTag="$OPTARG";;

		h)	fUsage long;;
		H)	fUsage "$OPTARG";;
		l)	gpLog=1;;
		v)	let gpVerbose=gpVerbose+1;;
		x)	let gpDebug=gpDebug+1;;
		T)	gpTest="$OPTARG";;
		:)	fError "Value required for option: $OPTARG" $LINENO;;
		\?)	fError "Unknown option: $OPTARG" $LINENO;;
	esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
	gpFileList="$*"
fi
while [ $# -ne 0 ]; do
	shift
done

# -------------------
if [ -n "$gpTest" ]; then
    	fRunTests
fi

# -------------------
# Validate Args Section

fValidateHostName

# -------------------
# Verify connections section

# -------------------
# Read-only section

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
timeout 5 awk -f $cTmp1 >$cTmp2

tList=""
for i in $(seq 2 40); do
	if [ -e "File$i" ]; then
		fLog2 -m "Found File$i"
		tList="$tList File$i"
	fi
done >>$cTmp2

# -------------------
# Write section

##fProcess $tList

# -------------------
# Output section
cat $cTmp2

# -------------------
# Cleanup Section
fCleanUp
