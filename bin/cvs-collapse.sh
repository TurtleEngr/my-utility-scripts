#!/bin/bash
# $Source: /repo/local.cvs/per/bruce/bin/cvs-collapse.sh,v $
# $Revision: 1.7 $ $Date: 2022/10/04 19:58:49 $ GMT

export gpNoUpdate
export gpContinue
export gpCvs

# ========================================
# Script Functions

# --------------------------------
fUsage()
{
    # Quick help, run this:
    # SCRIPTNAME -h | less

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

=head1 NAME cvs-collapse.sh

Save diskspace. Remove files that have been versioned.

=head1 SYNOPSIS

    cvs-collapse.sh -c [-n] [-u] [-h] [-H pStyle] [-l] [-v] [-x] [-T pTest]

=head1 DESCRIPTION

This only works for DIRs that are versioned with CVS.  And only the
files that are versioned will be removed.  Files the are not versioned
will be listed. Use "cvs update" to get the files back.

COLLAPSED-README.txt file will be put in the directory where this
command is run. It will have a datestamp and list the files removed.

=head1 OPTIONS

=over 4

=item B<-c>

This option is signal to the script that you know how it is run and
what it will do.

=item B<-n>

If set, then nothing will be done. The planned deletes will be listed.
This is the same as -x

=item B<-u>

Don't run "cvs update". However "cvs ci" will still be run.

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

If set, then nothing will be done. The planned deletes will be listed.

See: fLog and fLog2 (Internal documentation)

=item B<-T pTest>

Run the unit test functions in this script.

"-T all" will run all of the functions that begin with "test".
Otherwise "pTest" should match the test function names separated with
spaces (between quotes).

"-T list" will list all of the test functions.

"-T com" will run all the tests for bash-com.inc

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html
L<Source|https://github.com/kward/shunit2>

See shunit2, shunit2.1

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

Default: /tmp/$USER/cvs-collapse/

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

HOME,USER, Tmp, gpLog, gpFacility, gpVerbose, gpDebug

=for comment =head1 FILES

=head1 SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

=head1 NOTES

Tests:

  all
  testUsage
  testValidate
  testUpdate
  testCheckIn

=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

To verify the script is internally OK, run: cvs-collapse.sh -T all

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

NAME

=head1 HISTORY

GPLv3 (c) Copyright 2021 by COMPANY

$Revision: 1.7 $ $Date: 2022/10/04 19:58:49 $ GMT 

=cut
EOF
    cat <<EOF >/dev/null
=internal-pod

=internal-head1 cvs-collapse.sh Internal Documentation

=internal-head3 fUsage pStyle

This function selects the type of help output. See -h and -H options.

=internal-head2 Script Global Variables

=internal-cut
EOF
} # fUsage

# --------------------------------
fCleanUp()
{
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

# --------------------------------
fSetGlobals()
{
    fComSetGlobals
    gpVerbose=1
    
    # Put your globals here
    gpNoUpdate=0
    gpContinue=0
    gpCvs=${gpCvs:-$(which cvs)}

    # Define the Required ($1) and the Optional ($2) progs, space separated
    fComCheckDeps "cvs sed grep" "cvs"
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

# --------------------------------
fProcessEntries()
{
    local tEntList
    local tEnt
    local tDir

    tEntList=$(find . -type f -name 'Entries*' | grep CVS | grep -v '~')
    if [ -z "$tEntList" ]; then
        return
    fi

    for tEnt in $tEntList; do
        fProcessDir $tEnt
    done
} # fProcessEntries

# --------------------------------
fProcessDir()
{
    local pEnt=$1
    local tDir=${pEnt%/CVS/Entries}
    local tFileList
    local tFile

    tFileList=$(
        cat $pEnt |
        grep -v '^D' |
        awk '{
            sub(/^\//, "");
            gsub(/\/.*/, "");
            print $1
        }'
    )
    if [ -z "$tFileList" ]; then
        return
    fi

    for tFile in $tFileList; do
        fProcessFile $tDir/$tFile
    done
} # fProcessFiles

# --------------------------------
fProcessFile()
{
    local pFile=$1

    if [ ! -f $pFile ]; then
        echo $pDir/$pFile >>COLLAPSED-README.txt
        return
    fi
    fLog2 -p notice -m "rm $pFile" -l $LINENO
    if [ $gpDebug -ne 0 ]; then
        return
    fi

    echo $pDir/$pFile >>COLLAPSED-README.txt
    rm $pFile
} # fProcessFile

# ========================================
# Tests

# -------------------
fMockCvsCi()
{
    # Do nothing for 'cvs ci', and return OK
    if [ "$1" = "ci" ]; then
        return 0
    fi
    cvs $*
    return $?
} # fMockCvs

# -------------------
oneTimeSetUp()
{
    # Create the initial set of test files, and save in tar file

    gpTest=''

    declare -gx cTestRoot=$Tmp/TestRoot
    declare -gx cTestWork=$Tmp/TestWork
    declare -gx cTestTop=testDirTop
    declare -gx CVSROOT=$cTestRoot
    declare -gx CVSUMASK=0007
    declare -gx CVS_RSH=''

    mkdir $cTestRoot >/dev/null 2>&1
    mkdir $cTestWork >/dev/null 2>&1
    mkdir $cTestWork/$cTestTop >/dev/null 2>&1
    $gpCvs -d $CVSROOT init >/dev/null 2>&1
    mkdir $cTestRoot/$cTestTop >/dev/null 2>&1

    cd $cTestWork >/dev/null 2>&1
    $gpCvs co $cTestTop >/dev/null 2>&1
    cd $cTestTop >/dev/null 2>&1
    mkdir testDir1 testDir2 >/dev/null 2>&1
    $gpCvs add testDir1 testDir2 >/dev/null 2>&1
    cd testDir1 >/dev/null 2>&1
    touch file1-1 file1-2 file1-3
    $gpCvs add file1-1 file1-2 >/dev/null 2>&1
    cd ../testDir2 >/dev/null 2>&1
    touch file2-1 file-2-2 file2-3
    $gpCvs add file-2-2 file2-3 >/dev/null 2>&1
    cd $cTestWork/$cTestTop >/dev/null 2>&1
    $gpCvs ci -m Added >/dev/null 2>&1

    cd $Tmp
    tar -czf test-files.tgz TestRoot TestWork

    return 0
} # oneTimeSetUp

# -------------------
oneTimeTearDown()
{
#    rm $Tmp/test-files.tgz
    cd $cCurDir >/dev/null 2>&1
    return 0
} # oneTearDown

# -------------------
setUp()
{
    cd $Tmp
    tar -xzf test-files.tgz

    cd $cCurDir >/dev/null 2>&1
    return 0
} # setUp

# -------------------
tearDown()
{
    rm -rf $cTestRoot
    rm -rf $cTestWork

    cd $cCurDir >/dev/null 2>&1
    return 0
} # tearDown

# -------------------
testUsage()
{
    local tResult

    #-----
    tResult=$($cBin/$cName -H short 2>&1)
    assertContains "$LINENO tu-short" "$tResult" "NAME cvs-collapse"

    #-----
    tResult=$($cBin/$cName -H foo 2>&1)
    assertContains "$LINENO tu-foo" "$tResult" "NAME cvs-collapse"

    #-----
    tResult=$($cBin/$cName -H text 2>&1)
    assertContains "$LINENO tu-long" "$tResult" "DESCRIPTION"
    assertContains "$LINENO tu-long" "$tResult" "HISTORY"

    #-----
    tResult=$($cBin/$cName -H man 2>&1)
    assertContains "$LINENO tu-man" "$tResult" '.IX Header "DESCRIPTION"'
    assertContains "$LINENO tu_man" "$tResult" '.IX Header "HISTORY"'

    #-----
    tResult=$($cBin/$cName -H html 2>&1)
    assertContains "$LINENO tu-html" "$tResult" '<li><a href="#DESCRIPTION">DESCRIPTION</a></li>'
    assertContains "$LINENO tuhtml" "$tResult" '<h1 id="HISTORY">HISTORY</h1>'
    assertContains "$LINENO tu-html" "$tResult" "<title>$cName Usage</title>"

    #-----
    tResult=$($cBin/$cName -H md 2>&1)
    assertContains "$LINENO tu-md" "$tResult" '# DESCRIPTION'
    assertContains "$LINENO tu-md" "$tResult" '# HISTORY'

    #-----
    tResult=$($cBin/$cName -H int 2>&1)
    assertContains "$LINENO tu-internal" "$tResult" 'Template Use'
    assertContains "$LINENO tu-internal" "$tResult" 'fComSetGlobals'

    #-----
    tResult=$($cBin/$cName -H int-html 2>&1)
    assertContains "$LINENO tu-int-html" "$tResult" '<a href="#Template-Use">Template Use</a>'
    assertContains "$LINENO tu-int-html" "$tResult" '<h3 id="fComSetGlobals">fComSetGlobals</h3>'
    assertContains "$LINENO tu-int-html" "$tResult" 'Internal Doc</title>'
    assertContains "$LINENO tu-int-html" "$tResult" '<h3 id="testComUsage">testComUsage</h3>'

    #-----
    tResult=$($cBin/$cName -H int-md 2>&1)
    assertContains "$LINENO tu-int-md" "$tResult" '## Template Use'
    assertContains "$LINENO tu-int-md" "$tResult" '### fComSetGlobals'
    assertContains "$LINENO tu-int-md" "$tResult" '### testComUsage'

    #-----
    tResult=$($cBin/cvs-collapse.sh 2>&1)
    assertContains "$LINENO tu-call" "$tResult" "Usage:"
    assertContains "$LINENO tu-call" "$tResult" "cvs-collapse"

    #-----
    return 0
} # testUsage

# -------------------
testValidate()
{
    local tResult

    tResult=$($cBin/$cName 2>&1)
    assertTrue "$LINENO tv" "[ $? -ne 0 ]"
    assertContains "$LINENO tv" "$tResult" 'Missing options'
    assertContains "$LINENO tv" "$tResult" "Usage:"

    tResult=$($cBin/$cName -B 2>&1)
    assertTrue "$LINENO tv" "[ $? -ne 0 ]"
    assertContains "$LINENO tv" "$tResult" 'Unknown option:'

    tResult=$($cBin/$cName -H 2>&1)
    assertTrue "$LINENO tv" "[ $? -ne 0 ]"
    assertContains "$LINENO tv" "$tResult" 'Value required for option:'

    cd ~/tmp
    tResult=$($cBin/$cName -nx 2>&1)
    assertTrue "$LINENO tv" "[ $? -ne 0 ]"
    assertContains "$LINENO tv" "$tResult" 'You are not in a directory versioned with CVS'

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    tResult=$($cBin/$cName -nx 2>&1)
    assertContains "$LINENO tv" "$tResult" 'Missing the -c option'

    return 0
} # testValidate

# -------------------
testUpdateFail()
{
    local tResult

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    echo "Change file" >>testDir1/file1-1
    chmod a-rw testDir1/file1-1
    tResult=$($cBin/$cName -cx 2>&1)
    assertContains "$LINENO tuf: $tResult" "$tResult" 'Fix cvs update errors'

    return 0
} # testUpdate

# -------------------
testUpdateOk()
{
    local tResult

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    rm testDir1/file1-1
    tResult=$($cBin/$cName -cx 2>&1)
    assertContains "$LINENO tuo: $tResult" "$tResult" "cvs update: warning: \`testDir1/file1-1' was lost"

    echo "Change file" >>testDir1/file1-1
    tResult=$($cBin/$cName -cx 2>&1)
    assertContains "$LINENO tuo: $tResult" "$tResult" 'new revision: 1.2; previous revision: 1.1'

    return 0
} # testUpdateOk

# -------------------
testCiError()
{
    local tResult

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    echo "Change file" >>testDir1/file1-1
    chmod a-w $cTestRoot/$cTestTop/testDir1
    tResult=$($cBin/$cName -cx 2>&1)
    assertContains "$LINENO tce: $tResult" "$tResult" 'Fix cvs update errors'
    assertContains "$LINENO tu" "$tResult" 'Permission denied'
    chmod ug-w $cTestRoot/$cTestTop/testDir1
    chmod ug+w $cTestRoot/$cTestTop/testDir1

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    $gpCvs add testDir1/file1-3 >/dev/null 2>&1
    gpCvs=fMockCvsCi
    tResult=$($cBin/$cName -cnx 2>&1)
    assertContains "$LINENO tce: $tResult" "$tResult" 'cvs ci did not version all files'
    gpCvs=$(which cvs)

    return 0
} # testCiError

# -------------------
testNopOk()
{
    local tResult

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    tResult=$($cBin/$cName -cvx 2>&1)
    assertTrue "$LINENO tno:" "[ ! -f COLLAPSED-README.txt ]"
    assertContains "$LINENO tno" "$tResult" "cvs update: Updating testDir1"
    assertContains "$LINENO tno" "$tResult" "? testDir1/file1-3"
    assertContains "$LINENO tno" "$tResult" "cvs update: Updating testDir2"
    assertContains "$LINENO tno" "$tResult" "? testDir2/file2-1"
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining ."
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining testDir1"
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining testDir2"
    assertContains "$LINENO tno" "$tResult" "rm ./testDir1/file1-1"
    assertContains "$LINENO tno" "$tResult" "rm ./testDir1/file1-2"
    assertContains "$LINENO tno" "$tResult" "rm ./testDir2/file-2-2"
    assertContains "$LINENO tno" "$tResult" "rm ./testDir2/file2-3"
#    assertContains "$LINENO tno $tResult" "$tResult" "Show result"

    return 0
} # testNopOk

# -------------------
testOk()
{
    local tResult

    cd $cTestWork/$cTestTop >/dev/null 2>&1
    tResult=$($cBin/$cName -cv 2>&1)
    assertTrue "$LINENO tno" "[ -f COLLAPSED-README.txt ]"
    assertContains "$LINENO tno" "$tResult" "cvs update: Updating ."
    assertContains "$LINENO tno" "$tResult" "cvs update: Updating testDir1"
    assertContains "$LINENO tno" "$tResult" "? testDir1/file1-3"
    assertContains "$LINENO tno" "$tResult" "cvs update: Updating testDir2"
    assertContains "$LINENO tno" "$tResult" "? testDir2/file2-1"
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining ."
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining testDir1"
    assertContains "$LINENO tno" "$tResult" "cvs commit: Examining testDir2"
    assertTrue "$LINENO tno" "[ ! -f testDir1/file1-1 ]"
    assertTrue "$LINENO tno" "[ ! -f testDir1/file1-2 ]"
    assertTrue "$LINENO tno" "[ ! -f testDir2/file-2-2 ]"
    assertTrue "$LINENO tno" "[ ! -f testDir2/file2-3 ]"
    assertContains "$LINENO tno" "$tResult" "Files not removed:"
    assertContains "$LINENO tno" "$tResult" "COLLAPSED-README.txt"
    assertContains "$LINENO tno" "$tResult" "testDir1/file1-3"
    assertContains "$LINENO tno" "$tResult" "testDir2/file2-1"
#    assertContains "$LINENO tno: $(cat COLLAPSED-README.txt)" "$tResult" "xxxxxxxxxx"
#    assertContains "$LINENO tno: $tResult" "$tResult" "Show Result"

    return 0
} # testOk

# -------------------
# This should be the last defined function
fRunTests()
{
    if [ "$gpTest" = "list" ]; then
        grep 'test.*()' $cBin/$cName | grep -v grep | sed 's/()//g'
        grep 'test.*()' $cBin/bash-com.test | grep -v grep | sed 's/()//g'
        exit $?
    fi
    if [ "$gpTest" = "all" ]; then
        gpTest=''
        # shellcheck disable=SC1091
        . /usr/local/bin/shunit2.1
        exit $?
    fi
    if [ "$gpTest" = "com" ]; then
        gpTest=''
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
cVer='$Revision: 1.7 $'
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fError2 -m "Missing options." -l $LINENO
fi
while getopts :cnuhH:lT:vx tArg; do
    case $tArg in
           # Script arguments
        c) gpContinue=1;;
        u) gpNoUpdate=1;;
           # Common arguments
        h) fUsage long
           exit 1
        ;;
        H) fUsage "$OPTARG"
           exit 1
        ;;
        l) gpLog=1 ;;
        v) let ++gpVerbose ;;
        x|n) let ++gpDebug
           let ++gpVerbose
        ;;
        T) gpTest="$OPTARG" ;;
           # Problem arguments
        :) fError2 -m "Value required for option: -$OPTARG" -l $LINENO ;;
        \?) fError2 -m "Unknown option: $OPTARG" -l $LINENO ;;
    esac
done
shift $((OPTIND - 1))
if [ $# -ne 0 ]; then
    fError2 -m "Unknown option: $*" -l $LINENO
fi

# -------------------
if [ -n "$gpTest" ]; then
    fRunTests
fi

# -------------------
# Validate Args Section

if [ ! -f CVS/Entries ]; then
    fError2 -m "You are not in a directory versioned with CVS." -l $LINENO
fi
if [ $gpContinue -eq 0 ]; then
    fError2 -m "Missing the -c option." -l $LINENO
fi

# -------------------
# Verify connections section

# Is ssh-agent running?
# Can ssh connect to Root

# -------------------
# Update section

if [ $gpNoUpdate -eq 0 ]; then
    if ! $gpCvs update; then
        fError2 -m "Fix cvs update errors." -l $LINENO
        exit 1
    fi
fi

if ! $gpCvs ci -m Updated; then
    fError2 -m "Fix cvs ci errors." -l $LINENO
fi

if egrep -q '/0/dummy |/0/Initial' $(find * -name Entries); then
    fError2 -m "cvs ci did not version all files." -l $LINENO
fi

# -------------------
# Write section

if [ $gpDebug -eq 0 ]; then
    cat <<EOF >COLLAPSED-README.txt
$(date)
Ran: cvs-collapse.sh
These versioned files can be restored with "cvs update".
EOF
fi

# Remove all files found in Entries, that are not directories
fProcessEntries

# -------------------
# Output section

find * -type f -name '*~' -exec rm {} \;

if [ $gpDebug -eq 0 ]; then
    echo "Files not removed:"
    find * -type f | grep -v CVS
fi

# -------------------
# CleanUp Section

fCleanUp
