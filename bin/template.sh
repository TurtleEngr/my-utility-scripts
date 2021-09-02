#!/bin/bash
# $Source: /repo/local.cvs/per/bruce/bin/template.sh,v $
# $Revision: 1.45 $ $Date: 2021/09/02 08:15:46 $ GMT

# ========================================
# Include common bash functions at $cBin/bash-com.inc But first we
# need to set cBin

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

. $cBin/bash-com.inc

# ========================================
fUsage()
{
	# Quick help, run this:
	# SCRIPTNAME -h | less

	local pStyle="$1"

	case $pStyle in
		short|usage|man|long|text|md)
			fComUsage -f $cBin/$cName -s $pStyle
		;;
		html)
			fComUsage -f $cBin/$cName -s $pStyle -t "$cName Usage"
		;;
		int)
			fComUsage -a -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s long
		;;
		int-html)
			fComUsage -a -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s html -t "$cName Internal Doc"
		;;
		int-md)
			fComUsage -a -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s md
		;;
		*)
			fComUsage -f $cBin/$cName -s short
		;;
	esac
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

	short|usage - Output short usage help as text.
	long|text   - Output long usage help as text.
	man 	    - Output long usage help as a man page.
	html 	    - Output long usage help as html.
	md 	    - Output long usage help as markdown.
	int 	    - Also output internal documentation as text.
	int-html    - Also output internal documentation as html.
	int-md 	    - Also output internal documentation as markdown.

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

See: fLog and fLog2 (Internal documentation)

=item B<-T Test>

Run the unit test functions in this script.

If Test is "all", then all of the functions that begin with "test"
will be run. Otherwise "Test" should match the test function names
separated with commas.

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html
L<Source|https://github.com/kward/shunit2>

See shunit2, shunit2.1, and global: gpUnitDebug

Also for more help, use the "-H int" option.

=back

=head2 Globals

These are globals that may affect how the script runs. Just about all
of these globals that begin with "gp" can be set and exported before
the script is run. That way you can set your own defaults, by putting
them in your ~/.bashrc or ~/.bash_profile files.

The the "common" CLI flags will override the initial variable settings.

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

 local0 through local7 - local system facilities
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

These are some suggested uses for the localN facilities:

 local0 - system or application configuration
 local1 - application processes
 local2 - web site errors
 local3 - web site access
 local4 - backend processes
 local5 - publishing
 local6 - available
 local7 - available

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

$Revision: 1.45 $ $Date: 2021/09/02 08:15:46 $ GMT 

=cut
EOF
    	cat <<EOF >/dev/null
=internal-pod

=internal-head1 SCRIPTNAME Internal Documentation

=internal-head3 fUsage pStyle

This function selects the type of help output. See -h and -H options.

=internal-head2 Script Global Variables

=internal-cut
EOF
} # fUsage

# ========================================
# Tests

# --------------------------------
fUDebug()
{
	# See also fUDebug
	if [ ${gpUnitDebug:-0} -ne 0 ]; then
		echo "fUDebug: $*"
	fi
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head2 Unit Test Functions

=internal-cut
EOF
} # fUDebug

# --------------------------------
testUsage()
{
	local tResult
	
	gpUnitDebug=0

	#-----
	tResult=$(fUsage short 2>&1)
	fUDebug "tResult=$tResult"
	assertContains "tu-short" "$tResult" "Usage:"
	
	#-----
	tResult=$(fUsage foo 2>&1)
	fUDebug "tResult=$tResult"
	assertContains "tu-foo.1" "$tResult" "Usage:"
	assertContains "tu-foo.2 change SCRIPTNAME" "$tResult" "$cName"

	#-----
	tResult=$(fUsage text 2>&1)
	assertContains "tu-long.1" "$tResult" "DESCRIPTION"
	assertContains "tu-long.2" "$tResult" "HISTORY"

	#-----
	tResult=$(fUsage man 2>&1)
	assertContains "tu-man.1" "$tResult" '.IX Header "DESCRIPTION"'
	assertContains "tu-man.2" "$tResult" '.IX Header "HISTORY"'

	#-----
	tResult=$(fUsage html 2>&1)
	assertContains "tu-html.1" "$tResult" '<li><a href="#DESCRIPTION">DESCRIPTION</a></li>'
	assertContains "tu-html.2" "$tResult" '<h1 id="HISTORY">HISTORY</h1>'
	assertContains "tu-html.3" "$tResult" "<title>$cName Usage</title>"

	#-----
	tResult=$(fUsage md 2>&1)
	assertContains "tu-md.1" "$tResult" '# DESCRIPTION'
	assertContains "tu-md.2" "$tResult" '# HISTORY'

	#-----
	tResult=$(fUsage int 2>&1)
	fUDebug "tResult=$tResult"
	assertContains "tu-internal.1" "$tResult" 'Template Use'
	assertContains "tu-internal.2" "$tResult" 'fComSetGlobals'

	#-----
	tResult=$(fUsage int-html 2>&1)
	fUDebug "tResult=$tResult"
	assertContains "tu-int-html.1" "$tResult" '<a href="#Template-Use">Template Use</a>'
	assertContains "tu-int-html.2" "$tResult" '<h3 id="fComSetGlobals">fComSetGlobals</h3>'
	assertContains "tu-int-html.3" "$tResult" 'Internal Doc</title>'
	assertContains "tu-int-html.4" "$tResult" '<h3 id="testComUsage">testComUsage</h3>'

	#-----
	tResult=$(fUsage int-md 2>&1)
	assertContains "tu-int-md.1" "$tResult" '## Template Use'
	assertContains "tu-int-md.2" "$tResult" '### fComSetGlobals'
	assertContains "tu-int-md.3" "$tResult" '### testComUsage'

	#-----
	gpUnitDebug=0
	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testUsage

Test fUsage. Verify the different output styles work. See also testComUsage
in bash-com.test.

=internal-cut
EOF
} # testUsage

# --------------------------------
testScriptFunctions()
{
	local tResult

	tResult=$(fSetGlobals 2>&1)
	assertTrue "tsf-fSetGlobals" "[ $? -eq 0 ]"

	gpHostName="foobar"
	tResult=$(fValidateHostName 2>&1)
	assertTrue "tsf-fValidateHostName.1" "[ $? -eq 0 ]"

	gpHostName=""
	tResult=$(fValidateHostName 2>&1)
	assertContains "tsf-fValidateHostName.2" "$tResult" "required."

	return
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 testScriptFunctions

This is just a starting point for creating script functionality tests.

=internal-cut
EOF
}

# ========================================
# Script Functions

# --------------------------------
fCleanUp()
{
	fComCleanUp
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head2 Script Functions

=internal-head3 fCleanUp

Calls fComCleanUp.

=internal-cut
EOF
}

# -------------------
fSetGlobals()
{
	fComSetGlobals
	
	# Put your globals here
	gpTag=${gpTag:-build}

	# Define the Required and the Optional progs, space separated
	fComCheckDeps "cat" "cat"
	return

    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fSetGlobals

Calls fComSetGlobals to set globals used by bash-com.inc.

Set initial values for all of the other globals use by this
script. The ones that begin with "gp" can usually be overridden by
setting them before the script is run.

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
	SHUNIT_COLOR=${SHUNIT_COLOR:-light}
	# or SHUNIT_COLOR=none
	gpUnitDebug=${gpUnitDebug:-0}
	if [ "$gpTest" = "all" ]; then
		# shellcheck disable=SC1091
		. /usr/local/bin/shunit2.1
		exit $?
	fi
	if [ "$gpTest" = "com" ]; then
		$cBin/bash-com.test
		exit $?
	fi
	# shellcheck disable=SC1091
	. /usr/local/bin/shunit2.1 -- $gpTest
	exit $?
	
    	cat <<EOF >/dev/null
=internal-pod

=internal-head3 fRunTests

Run unit tests for this script.

=internal-cut
EOF
} # fRunTests

# ========================================
# Main

# -------------------
# Configuration Section

# bash-com.inc globals
export PWD Tmp cBin cCurDir cName cPID cTmp1 cTmp2 cTmpF cVer
export gErr gpDebug gpFacility gpLog gpVerbose

# Test globals
export gpTest gpUnitDebug SHUNIT_COLOR

# Script globals
export gpFileList=""
export gpHostName=""

fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
	fError2 -m "Missing options." -l $LINENO
	fUsage short
fi
while getopts :cn:t:hH:lT:vx tArg; do
	case $tArg in
		# Script arguments
		c)	gpHostName=$(hostname);;
		n)	gpHostName="$OPTARG";;
		t)	gpTag="$OPTARG";;
		# Common arguments
		h)	fUsage long;;
		H)	fUsage "$OPTARG";;
		l)	gpLog=1;;
		v)	let gpVerbose=gpVerbose+1;;
		x)	let gpDebug=gpDebug+1;;
		T)	gpTest="$OPTARG";;
		# Problem arguments
		:)	fError "Value required for option: -$OPTARG" $LINENO;;
		\?)	fError "Unknown option: $OPTARG" $LINENO;;
	esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
	# File names are usually the only arguments not matched.
	# If nothing is expected, then change this to fError...
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
# CleanUp Section
fCleanUp
