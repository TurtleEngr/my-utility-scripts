#!/bin/bash
# $Source: /repo/local.cvs/per/bruce/bin/cvs-collapse.sh,v $
# $Revision: 1.11 $ $Date: 2023/01/06 18:05:13 $ GMT

set -u
export cgCacheDir
export gpNoUpdate
export gpContinue
export gpRmCache
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

    cvs-collapse.sh -c [-u] [-C] [-h] [-H pStyle] [-l] [-v] [-n] [-x] [-T pTest]

=head1 DESCRIPTION

This only works for DIRs that are versioned with CVS.  And only the
files that are versioned will be removed.  Files the are not versioned
will be listed. Use "cvs update" to get the files back.

COLLAPSED-README.txt file will be put in the directory where this
command is run. It will have a datestamp and list the files removed.

If cvs-collapse.sh is run again in the same directory, then any files
removed, will be appended to COLLAPSED-README.txt.

=head1 OPTIONS

=over 4

=item B<-c>

This option is signal to the script that you know how it is run and
what it will do.

=item B<-u>

Don't run "cvs update". However "cvs ci" will still be run.

=item B<-C>

Remove all files in any "cachefiles/" dir found in current dir on down.

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

=item B<-n>

See -x

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

=for comment =head1 RETURN VALUE
=for comment =head1 ERRORS
=for comment =head1 EXAMPLES

=head1 ENVIRONMENT

See Globals section for details.

HOME,USER, Tmp, gpLog, gpFacility, gpVerbose, gpDebug

=for comment =head1 FILES

=head1 SEE ALSO

    shunit2.1,  bash-com.inc, bash-com.test

=head1 NOTES

Tests:

    all - run all tests
    list - list all tests
    testUsage
    testValidate
    testUpdateFail
    testUpdateOk
    testCiError
    testNopOk
    testOk
    testRmCacheOk
    testRmCacheNop

=for comment =head1 CAVEATS
=for comment =head1 DIAGNOSTICS
=for comment =head1 BUGS
=for comment =head1 RESTRICTIONS

=head1 AUTHOR

TurtleEngr

=head1 HISTORY

GPLv3 (c) Copyright 2022

$Revision: 1.11 $ $Date: 2023/01/06 18:05:13 $ GMT

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
    cgCacheDir="cachefiles"
    gpNoUpdate=0
    gpContinue=0
    gpRmCache=0
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
fProcessFile()
{
    local pFile=$1

    if [ ! -f $pFile ]; then
        fLog2 -p notice -m "Already rm $pFile" -l $LINENO
        if [ $gpDebug -eq 0 ]; then
            echo "rm $pFile" >>COLLAPSED-README.txt
        fi
        return
    fi

    fLog2 -p notice -m "rm $pFile" -l $LINENO
    if [ $gpDebug -ne 0 ]; then
        return
    fi

    echo "rm $pFile" >>COLLAPSED-README.txt
    rm $pFile

    return
} # fProcessFile

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

    return
} # fProcessFiles

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

    return
} # fProcessEntries

# --------------------------------
fProcessCache()
{
    local tDirList=''
    local tDir=''

    if [ $gpRmCache -eq 0 ]; then
        return
    fi

    cd $cCurDir &>/dev/null
    tDirList=$(find . -type d -name $cgCacheDir)
    if [ -z "$tDirList" ]; then
        return
    fi

    fLog2 -p notice -m "Removing files in $tDirList" -l $LINENO
    if [ $gpDebug -eq 0 ]; then
        echo "# Removed files in $tDirList" >>COLLAPSED-README.txt
    fi
    for tDir in $tDirList; do
        if [ $gpDebug -ne 0 ]; then
            fLog2 -p notice -m "Removing files: $(find $tDir -type f)" -l $LINENO
            continue
        fi
        find $tDir -type f -exec rm {} \;
    done

    return
} # fProcessCache

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

    mkdir $cTestRoot &>/dev/null
    mkdir $cTestWork &>/dev/null
    mkdir $cTestWork/$cTestTop &>/dev/null
    $gpCvs -d $CVSROOT init &>/dev/null
    mkdir $cTestRoot/$cTestTop &>/dev/null

    cd $cTestWork &>/dev/null
    $gpCvs co $cTestTop &>/dev/null
    cd $cTestTop &>/dev/null
    mkdir testDir1 testDir2 &>/dev/null
    $gpCvs add testDir1 testDir2 &>/dev/null
    cd testDir1 &>/dev/null
    touch file1-1 file1-2 file1-3
    $gpCvs add file1-1 file1-2 &>/dev/null
    cd ../testDir2 &>/dev/null
    touch file2-1 file-2-2 file2-3
    $gpCvs add file-2-2 file2-3 &>/dev/null

    mkdir -p cachefiles/1662402751352/audiothumbs
    mkdir -p cachefiles/1662402751352/preview
    mkdir -p cachefiles/1662402751352/videothumbs
    mkdir -p cachefiles/titles
    mkdir -p cachefiles/audiothumbs
    mkdir -p cachefiles/preview
    mkdir -p cachefiles/proxy
    touch cachefiles/proxy/bar1.mkv
    touch cachefiles/proxy/bar2.mkv
    mkdir -p cachefiles/videothumbs
    touch cachefiles/videothumbs/foo1.jpg
    touch cachefiles/videothumbs/foo2.jpg

    cd $cTestWork/$cTestTop &>/dev/null
    $gpCvs ci -m Added &>/dev/null

    cd $Tmp
    tar -czf test-files.tgz TestRoot TestWork

    return 0
} # oneTimeSetUp

# -------------------
oneTimeTearDown()
{
    #    rm $Tmp/test-files.tgz
    cd $cCurDir &>/dev/null
    return 0
} # oneTearDown

# -------------------
setUp()
{
    cd $Tmp
    tar -xzf test-files.tgz

    cd $cCurDir &>/dev/null
    return 0
} # setUp

# -------------------
tearDown()
{
    rm -rf $cTestRoot
    rm -rf $cTestWork

    cd $cCurDir &>/dev/null
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

    cd $cTestWork/$cTestTop &>/dev/null
    tResult=$($cBin/$cName -nx 2>&1)
    assertContains "$LINENO tv" "$tResult" 'Missing the -c option'

    return 0
} # testValidate

# -------------------
testUpdateFail()
{
    local tResult

    cd $cTestWork/$cTestTop &>/dev/null
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

    cd $cTestWork/$cTestTop &>/dev/null
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

    cd $cTestWork/$cTestTop &>/dev/null
    echo "Change file" >>testDir1/file1-1
    chmod a-w $cTestRoot/$cTestTop/testDir1
    tResult=$($cBin/$cName -cx 2>&1)
    assertContains "$LINENO tce: $tResult" "$tResult" 'Fix cvs update errors'
    assertContains "$LINENO tu" "$tResult" 'Permission denied'
    chmod ug-w $cTestRoot/$cTestTop/testDir1
    chmod ug+w $cTestRoot/$cTestTop/testDir1

    cd $cTestWork/$cTestTop &>/dev/null
    $gpCvs add testDir1/file1-3 &>/dev/null
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

    cd $cTestWork/$cTestTop &>/dev/null
    tResult=$($cBin/$cName -cvx 2>&1)
    assertTrue "$LINENO" "[ ! -f COLLAPSED-README.txt ]"
    assertContains "$LINENO" "$tResult" "cvs update: Updating testDir1"
    assertContains "$LINENO" "$tResult" "? testDir1/file1-3"
    assertContains "$LINENO" "$tResult" "cvs update: Updating testDir2"
    assertContains "$LINENO" "$tResult" "? testDir2/file2-1"
    assertContains "$LINENO" "$tResult" "cvs commit: Examining ."
    assertContains "$LINENO" "$tResult" "cvs commit: Examining testDir1"
    assertContains "$LINENO" "$tResult" "cvs commit: Examining testDir2"
    assertContains "$LINENO" "$tResult" "rm ./testDir1/file1-1"
    assertContains "$LINENO" "$tResult" "rm ./testDir1/file1-2"
    assertContains "$LINENO" "$tResult" "rm ./testDir2/file-2-2"
    assertContains "$LINENO" "$tResult" "rm ./testDir2/file2-3"
    ##assertContains "$LINENO $tResult" "$tResult" "Show result"

    return 0
} # testNopOk

# -------------------
testOk()
{
    local tResult

    cd $cTestWork/$cTestTop &>/dev/null
    tResult=$($cBin/$cName -cv 2>&1)
    assertTrue "$LINENO" "[ -f COLLAPSED-README.txt ]"
    assertContains "$LINENO" "$tResult" "cvs update: Updating ."
    assertContains "$LINENO" "$tResult" "cvs update: Updating testDir1"
    assertContains "$LINENO" "$tResult" "? testDir1/file1-3"
    assertContains "$LINENO" "$tResult" "cvs update: Updating testDir2"
    assertContains "$LINENO" "$tResult" "? testDir2/file2-1"
    assertContains "$LINENO" "$tResult" "cvs commit: Examining ."
    assertContains "$LINENO" "$tResult" "cvs commit: Examining testDir1"
    assertContains "$LINENO" "$tResult" "cvs commit: Examining testDir2"

    assertTrue "$LINENO" "[ ! -f testDir1/file1-1 ]"
    assertTrue "$LINENO" "[ ! -f testDir1/file1-2 ]"
    assertTrue "$LINENO" "[ -f testDir1/file1-3 ]"
    assertTrue "$LINENO" "[ -f testDir2/file2-1 ]"
    assertTrue "$LINENO" "[ ! -f testDir2/file-2-2 ]"
    assertTrue "$LINENO" "[ ! -f testDir2/file2-3 ]"

    assertContains "$LINENO" "$tResult" "Files not removed:"
    assertContains "$LINENO" "$tResult" "COLLAPSED-README.txt"
    assertContains "$LINENO" "$tResult" "testDir1/file1-3"
    assertContains "$LINENO" "$tResult" "testDir2/file2-1"

    ##assertContains "$LINENO $(cat COLLAPSED-README.txt)" "$tResult" "xxxxxxx"
    ##assertContains "$LINENO $(find $PWD)" "$tResult" "xxxxxxxxxx"
    ##assertContains "$LINENO: $tResult" "$tResult" "Show Result"

    return 0
} # testOk

# -------------------
testRmCacheOk()
{
    local tResult

    cd $cTestWork/$cTestTop &>/dev/null
    tResult=$($cBin/$cName -cCv 2>&1)
    assertContains "$LINENO $tResult" "$tResult" "Removing files in ./testDir2/cachefiles"
    assertTrue "$LINENO" "[ -f COLLAPSED-README.txt ]"
    assertTrue "$LINENO" "[ ! -f testDir2/cachefiles/videothumbs/foo2.jpg ]"
    assertTrue "$LINENO" "[ ! -f testDir2/cachefiles/videothumbs/foo1.jpg ]"
    assertTrue "$LINENO" "[ ! -f testDir2/cachefiles/proxy/bar1.mkv ]"
    assertTrue "$LINENO" "[ ! -f testDir2/cachefiles/proxy/bar2.mkv ]"

    return 0
} # testRmCache

# -------------------
testRmCacheNop()
{
    local tResult

    cd $cTestWork/$cTestTop &>/dev/null
    tResult=$($cBin/$cName -cCvx 2>&1)
    assertContains "$LINENO $tResult" "$tResult" "Removing files in ./testDir2/cachefiles"
    assertTrue "$LINENO" "[ ! -f COLLAPSED-README.txt ]"
    assertTrue "$LINENO" "[ -f testDir2/cachefiles/videothumbs/foo2.jpg ]"
    assertTrue "$LINENO" "[ -f testDir2/cachefiles/videothumbs/foo1.jpg ]"
    assertTrue "$LINENO" "[ -f testDir2/cachefiles/proxy/bar1.mkv ]"
    assertTrue "$LINENO" "[ -f testDir2/cachefiles/proxy/bar2.mkv ]"

    return 0
} # testRmCacheNop

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
        cd $cBin &>/dev/null
        cBin=$PWD
        cd $cCurDir &>/dev/null
        ;;
esac

cName=cvs-collapse.sh
. $cBin/bash-com.inc

# -------------------
# Configuration Section

# shellcheck disable=SC2016
cVer='$Revision: 1.11 $'
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fError2 -m "Missing options." -l $LINENO
fi
while getopts :cCnuhH:lT:vx tArg; do
    case $tArg in
        # Script arguments
        c) gpContinue=1 ;;
        C) gpRmCache=1 ;;
        u) gpNoUpdate=1 ;;
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
        v) let ++gpVerbose ;;
        x | n)
            ((++gpDebug))
            ((++gpVerbose))
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

if grep -Eq '/0/dummy |/0/Initial' $(find * -name Entries); then
    fError2 -m "cvs ci did not version all files." -l $LINENO
fi

# -------------------
# Write section

if [ $gpDebug -eq 0 ]; then
    cat <<EOF >>COLLAPSED-README.txt
# ====================
# $(date)
# Ran: cvs-collapse.sh in $PWD
# These versioned files can be restored with "cvs update".
EOF
fi

# Remove all files found in Entries, that are not directories
fProcessCache
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
