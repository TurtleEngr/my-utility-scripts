#!/bin/bash
# $Source: /repo/per-bruce.cvs/bin/template.sh,v $
# $Revision: 1.75 $ $Date: 2023/03/25 22:21:42 $ GMT

export gpHostName gpTag
set -u

# ========================================
# Script Functions

# --------------------------------
fUsage() {
    # Quick help, run this:
    # SCRIPTNAME -h

    local pStyle="$1"

    case $pStyle in
        short | usage | man | long | text | md)
            fComUsage -f $cBin/$cName -s $pStyle | more
            ;;
        html)
            fComUsage -f $cBin/$cName -s $pStyle -t "$cName Usage"
            ;;
        int)
            fComUsage -i -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s long | more
            ;;
        int-html)
            fComUsage -i -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s html -t "$cName Internal Doc"
            ;;
        int-md)
            fComUsage -i -f $cBin/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s md
            ;;
        *)
            fComUsage -f $cBin/$cName -s short | more
            ;;
    esac
    fCleanUp
    # Defect: this exit doesn't seem to work.
    exit 1

    # POD Syntax: https://perldoc.perl.org/perlpod
    # pod2man wants the sections defined in this order.
    # Empty sections can be commented out with "=for comment". For example:
    # =for comment =head1 ERRORS
    cat <<\EOF >/dev/null
=pod

=for text ========================================

=for html <hr/>

=head1 NAME SCRIPTNAME

SHORT-DESCRIPTION

=head1 SYNOPSIS

        SCRIPTNAME [-o "Name=Value"] [-h] [-H pStyle] [-l] [-v] [-x] [-T pTest]

=head1 DESCRIPTION

Describe the script.

=head1 OPTIONS

=over 4

=item B<-o Name=Value>

[This is a placeholder for user options.]

=item B<-h>

Output this "long" usage help. See "-H long"

=item B<-H pStyle>

pStyle is used to select the type of help and how it is formatted.

Styles:

    short|usage - Output short usage help as text.
    long|text   - Output long usage help as text.
    man         - Output long usage help as a man page.
    html        - Output long usage help as html.
    md          - Output long usage help as markdown.
    int         - Also output internal documentation as text.
    int-html    - Also output internal documentation as html.
    int-md      - Also output internal documentation as markdown.

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

=item B<-T "pTest">

Run the unit test functions in this script.

"B<-T all>" will run all of the functions that begin with "test".

"B<-T list>" will list all of the test functions.

"B<-T com>" will run all the tests for bash-com.inc

Otherwise, "B<pTest>" should match the test function names separated
with spaces (between quotes).

For more help, use the "-H int" option.

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html L<Source|https://github.com/kward/shunit2>

shunit2.1 has a minor change that defaults to the no-color option.

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

HOME, USER, Tmp, gpLog, gpFacility, gpVerbose, gpDebug

=for comment =head1 FILES

=head1 SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

=for comment =head1 NOTES

=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

To verify the script is internally OK, run: SCRIPTNAME -T all

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

NAME

=head1 HISTORY

GPLv3 (c) Copyright 2021 by COMPANY

$Revision: 1.75 $ $Date: 2023/03/25 22:21:42 $ GMT

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

# --------------------------------
fCleanUp() {
    fComCleanUp
    exit

    cat <<EOF >/dev/null
=internal-pod

=internal-head2 Script Functions

=internal-head3 fCleanUp

Calls fComCleanUp.

=internal-cut
EOF
} # fCleanUp

# -------------------
fSetGlobals() {
    fComSetGlobals

    # Put your globals here
    gpTag=${gpTag:-build}
    gpHostName=$HOSTNAME

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
fValidateHostName() {
    if [ -z $gpHostName ]; then
        fError2 -m "The -n or -c option is required." -l $LINENO
    fi
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fValidateHostName

Exit if missing.

=internal-cut
EOF
} # fValidateHostName

# ========================================
# Tests

# --------------------------------
oneTimeSetUp() {
    # When calling $cName, unset gpTest to prevent infinite loop
    gpTest=''

    return 0
} # oneTimeSetUp

# --------------------------------
oneTimeTearDown() {
    return 0
} # oneTearDown

# --------------------------------
setUp() {
    return 0
} # setUp

# --------------------------------
tearDown() {
    return 0
} # tearDown

# --------------------------------
testUsage() {
    local tResult

    #-----
    tResult=$(fUsage short 2>&1)
    assertContains "$LINENO short" "$tResult" "NAME SCRIPTNAME"

    #-----
    tResult=$(fUsage foo 2>&1)
    assertContains "$LINENO foo.1" "$tResult" "NAME SCRIPTNAME"

    #-----
    tResult=$(fUsage text 2>&1)
    assertContains "$LINENO long.1" "$tResult" "DESCRIPTION"
    assertContains "$LINENO long.2" "$tResult" "HISTORY"

    #-----
    tResult=$(fUsage man 2>&1)
    assertContains "$LINENO man.1" "$tResult" '.IX Header "DESCRIPTION"'
    assertContains "$LINENO man.2" "$tResult" '.IX Header "HISTORY"'

    #-----
    tResult=$(fUsage html 2>&1)
    assertContains "$LINENO html.1" "$tResult" '<li><a href="#DESCRIPTION">DESCRIPTION</a></li>'
    assertContains "$LINENO html.2" "$tResult" '<h1 id="HISTORY">HISTORY</h1>'
    assertContains "$LINENO html.3" "$tResult" "<title>$cName Usage</title>"

    #-----
    tResult=$(fUsage md 2>&1)
    assertContains "$LINENO md.1" "$tResult" '# DESCRIPTION'
    assertContains "$LINENO md.2" "$tResult" '# HISTORY'

    #-----
    tResult=$(fUsage int 2>&1)
    assertContains "$LINENO internal.1" "$tResult" 'Template Use'
    assertContains "$LINENO internal.2" "$tResult" 'fComSetGlobals'

    #-----
    tResult=$(fUsage int-html 2>&1)
    assertContains "$LINENO int-html.1" "$tResult" '<a href="#Template-Use">Template Use</a>'
    assertContains "$LINENO int-html.2" "$tResult" '<h3 id="fComSetGlobals">fComSetGlobals</h3>'
    assertContains "$LINENO int-html.3" "$tResult" 'Internal Doc</title>'
    assertContains "$LINENO int-html.4" "$tResult" '<h3 id="testComUsage">testComUsage</h3>'

    #-----
    tResult=$(fUsage int-md 2>&1)
    assertContains "$LINENO int-md.1" "$tResult" '## Template Use'
    assertContains "$LINENO int-md.2" "$tResult" '### fComSetGlobals'
    assertContains "$LINENO int-md.3" "$tResult" '### testComUsage'

    #-----
    tResult=$($cBin/$cName 2>&1)
    assertContains "$LINENO cmd-call" "$tResult" "Usage:"
    assertContains "$LINENO cmd-call" "$tResult" "$cName"

    #-----
    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 testUsage

Test fUsage. Verify the different output styles work. See also testComUsage
in bash-com.test.

=internal-cut
EOF
} # testUsage

# --------------------------------
testScriptFunctions() {
    local tResult

    tResult=$(fSetGlobals 2>&1)
    assertTrue "$LINENO tsf-fSetGlobals" "[ $? -eq 0 ]"

    gpHostName="foobar"
    tResult=$(fValidateHostName 2>&1)
    assertTrue "$LINENO tsf-fValidateHostName.1" "[ $? -eq 0 ]"

    gpHostName=""
    tResult=$(fValidateHostName 2>&1)
    assertContains "$LINENO tsf-fValidateHostName.2" "$tResult" "required."

    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 testScriptFunctions

This is just a starting point for creating script functionality tests.

=internal-cut
EOF
} # testScriptFunctions

# -------------------
# This should be the last defined function
fRunTests() {
    if [ "$gpTest" = "list" ]; then
        grep 'test.*()' $cBin/$cName | grep -v grep | sed 's/()//g'
        grep 'test.*()' $cBin/bash-com.test | grep -v grep | sed 's/()//g'
        exit $tErr
    fi
    SHUNIT_COLOR=auto
    # SHUNIT_COLOR=always
    # SHUNIT_COLOR=none
    if [ "$gpTest" = "all" ]; then
        gpTest=""
        # shellcheck disable=SC1091
        . /usr/local/bin/shunit2.1
        exit $?
    fi
    if [ "$gpTest" = "com" ]; then
        gpTest=""
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
# Define cBin, location of common scripts (pick one)
tBin=home
case $tBin in
    current)
        cBin=$PWD
        ;;
    home) cBin=~/bin ;;
    local) cBin=/usr/local/bin ;;
    system) cBin=/usr/bin ;;
    this)
        cBin=${0%/*}
        if [ "$cBin" = "." ]; then
            cBin=$PWD
        fi
        cd $cBin
        cBin=$PWD
        cd $cCurDir
        ;;
esac

. $cBin/bash-com.inc

# -------------------
# Configuration Section

# shellcheck disable=SC2016
cVer='$Revision: 1.75 $'
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fError2 -m "Missing options." -l $LINENO
fi
while getopts :cn:t:hH:lT:vx tArg; do
    case $tArg in
        # Script arguments
        c) gpHostName=$(hostname) ;;
        n) gpHostName="$OPTARG" ;;
        t) gpTag="$OPTARG" ;;
        # Common arguments
        h)
            fUsage long
            exit 1
            ;;
        H)
            fUsage "$OPTARG"
            exit 1
            ;;
        l) gpLog=1 ;;
        v) ((++gpVerbose)) ;;
        x) ((++gpDebug)) ;;
        T) gpTest="$OPTARG" ;;
        # Problem arguments
        :) fError -m "Value required for option: -$OPTARG" -l $LINENO ;;
        \?) fError -m "Unknown option: $OPTARG" -l $LINENO ;;
    esac
done
((--OPTIND))
shift $OPTIND
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
