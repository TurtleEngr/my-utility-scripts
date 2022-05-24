#!/bin/bash
# $Source: /repo/local.cvs/per/bruce/bin/tag-collect.sh,v $
# $Revision: 1.4 $ $Date: 2022/05/24 21:59:18 $ GMT

# ========================================
# Include common bash functions at $cBin/bash-com.inc But first we
# need to set cBin

export  gpFileList

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

# ========================================
# Script Functions

# --------------------------------
fUsage()
{
    # Quick help, run this:
    # tag-collect.sh -h | less

    local pStyle="$1"

    case $pStyle in
        short | usage | man | long | text | md)
            fComUsage -f $cCurDir/$cName -s $pStyle
            ;;
        html)
            fComUsage -f $cCurDir/$cName -s $pStyle -t "$cName Usage"
            ;;
        int)
            fComUsage -i -f $cCurDir/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s long
            ;;
        int-html)
            fComUsage -i -f $cCurDir/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s html -t "$cName Internal Doc"
            ;;
        int-md)
            fComUsage -i -f $cCurDir/$cName -f $cBin/bash-com.inc -f $cBin/bash-com.test -s md
            ;;
        *)
            fComUsage -f $cCurDir/$cName -s short
            ;;
    esac
    exit 1

    # POD Syntax: https://perldoc.perl.org/perlpod
    # pod2man wants the sections defined in this order.
    # Empty sections can be commented out with "=for comment". For example:
    # =for comment =head1 ERRORS
    cat <<\EOF >/dev/null
=pod

=for text ========================================

=for html <hr/>

=head1 NAME tag-collect.sh

Output file contents based on the desired "tags"

=head1 SYNOPSIS

	tag-collect.sh -t pTag ... [-h] [-H pStyle] [-l] [-v] [-x] [-T pTest] pFiles...

=head1 DESCRIPTION

pTags will be looked for in the list of pFiles. When found the tag line
and all lines after it will be listed, until another tag is found or
EOF.

Duplicate text in the tag sections will be removed from the output.

See the EXAMPLE section for the example use of tags in files.

=head1 OPTIONS

=over 4

=item B<-t tag>

Look for {pTag} in the list of Files.

More than one -t option can be used to select any number of tags.

=item B<-h>

Output this "long" usage help. See "-H long"

=item B<-H pStyle>

pStyle is used to select the type of help and how it is formatted.

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

Currently there are no log messages.

Verbose output. Default is is only output (or log) messages with
level "warning" and higher.

-v - output "notice" and higher.

-vv - output "info" and higher.

=item B<-x>

Currently there are no debug messages.

Set the gpDebug level. Add 1 for each -x.
Or you can set gpDebug before running the script.

See: fLog and fLog2 (Internal documentation)

=item B<-T pTest>

Run the unit test functions in this script.

"-T all" will run all of the functions that begin with "test".
Otherwise "pTest" should match the test function names separated with
commas. "-T com" will run all the tests for bash-com.inc

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

=for comment [What the program or function returns if successful.]

=head1 ERRORS

Fatal Errors:

    Missing -t option.
    A pFile does not exist

=for comment Warning:

=for comment Many error messages may describe where the error is located, with the
=for comment following log message format:

=for comment  Program: PID NNNN: Message [LINE](ErrNo)

=head1 EXAMPLES

=head2 Example File: file1.txt

    This text is ignored.
    {tag1}
    Testing 123
    {tag2}
    Testing 456
       
=head2 Example File: file2.txt

    This text is ignored.
    {tag5}
    Test-5
    {tag3} {tag1}
    Testing 789
    {tag1}
    Testing 123
    {tag3}
    Testing 123
    {tag4}
    Testing 1010
    {tagend}
    extra text
    
=head2 Example command runs

    $  tag-collect-sh -t tag1 file[12].txt

    {tag1}
    Testing 123
    {tag3} {tag1}
    Testing 789

    $ tag-collect-sh -t tag1 -t tag3  file[12].txt

    {tag1}
    Testing 123
    {tag3} {tag1}
    Testing 789

Notice how the only one {tag1} text section is output, even though it
is in different files. Duplicate section text is not output (the tags
are ignored when looking for duplicates). Also the {tag3} {tag1} could
have been output twice, but only one copy is output.

=head1 ENVIRONMENT

See Globals section for details.

gpLog, gpFacility, gpVerbose, gpDebug

=for comment =head1 FILES

=head1 SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

=for comment =head1 NOTES

=for comment =head1 CAVEATS

=for comment [Things to take special care with; sometimes called WARNINGS.]

=for comment =head1 DIAGNOSTICS

=for comment To verify the script is internally OK, run: tag-collect.sh -T all

=for comment =head1 BUGS

=for comment [Things that are broken or just don't work quite right.]

=for comment =head1 RESTRICTIONS

=for comment [Bugs you don't plan to fix :-)]

=for comment =head1 AUTHOR

=for comment NAME

=head1 HISTORY

GPLv3 (c) Copyright 2022

$Revision: 1.4 $ $Date: 2022/05/24 21:59:18 $ GMT 

=cut
EOF
    cat <<EOF >/dev/null
=internal-pod

=internal-head1 tag-collect.sh Internal Documentation

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

# -------------------
fSetGlobals()
{
    fComSetGlobals

    # Put your globals here
    gpFileList=""
    gpTag=""

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
fValidate()
{
    local tFile

    for tFile in $gpFileList; do
        if [ ! -f $tFile ]; then
    	    fError2 -m "File not found: $tFile" -l $LINENO
	fi
    done
    
    if [ -z "$gpTag" ]; then
        fError2 -m "Missing -t option" -l $LINENO
    fi

    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fValidate

Exit if missing.

=internal-cut
EOF
} # fValidate

# -------------------
fGetChunk()
{
    local pTag=$1
    local tInTag=""
    local tCount=0
    local tFile

    while read -r; do
        echo "$REPLY" | grep -q "{"
	if [[ $? -ne 0 && -n "$tInTag" ]]; then
	    echo "$REPLY" >>${cTmpF}-$tCount.tmp
	    continue
	else
	    tInTag=""
	fi
        echo "$REPLY" | grep -q "{$pTag}"
	if [ $? -eq 0 ]; then
	    tInTag=yes
	    let ++tCount
	fi
	if [ -n "$tInTag" ]; then
	    echo "$REPLY" >>${cTmpF}-$tCount.tmp
	fi
    done
    
    for tFile in ${cTmpF}-*.tmp; do
        tHash=$(sed 's/{.*}//g' $tFile | md5sum)
	grep -q ${tHash% *} $Tmp/unique.tmp >/dev/null 2>&1
	if [ $? -eq 0 ]; then
	    rm $tFile
	    continue
	fi
	echo ${tHash% *} >>$Tmp/unique.tmp
    done

    cat ${cTmpF}-*.tmp 2>/dev/null
    rm -f ${cTmpF}-*.tmp >/dev/null 2>&1
} # fGetChunk

# -------------------
fGetTaggedText()
{
    local tTag

    rm $Tmp/unique.tmp >/dev/null 2>&1
    for tTag in $gpTag; do
        cat $gpFileList | fGetChunk $tTag
    done
} # fGetTaggedText

# ========================================
# Tests

# --------------------------------
testUsage()
{
    local tResult

    #-----
    tResult=$(fUsage short 2>&1)
    assertContains "$LINENO tu-short" "$tResult" "NAME tag-collect.sh"

    #-----
    tResult=$(fUsage foo 2>&1)
    assertContains "$LINENO tu-foo.1" "$tResult" "NAME tag-collect.sh"

    #-----
    tResult=$(fUsage text 2>&1)
    assertContains "$LINENO tu-long.1" "$tResult" "DESCRIPTION"
    assertContains "$LINENO tu-long.2" "$tResult" "HISTORY"

    #-----
    tResult=$(fUsage man 2>&1)
    assertContains "$LINENO tu-man.1" "$tResult" '.IX Header "DESCRIPTION"'
    assertContains "$LINENO tu-man.2" "$tResult" '.IX Header "HISTORY"'

    #-----
    tResult=$(fUsage html 2>&1)
    assertContains "$LINENO tu-html.1" "$tResult" '<li><a href="#DESCRIPTION">DESCRIPTION</a></li>'
    assertContains "$LINENO tu-html.2" "$tResult" '<h1 id="HISTORY">HISTORY</h1>'
    assertContains "$LINENO tu-html.3" "$tResult" "<title>$cName Usage</title>"

    #-----
    tResult=$(fUsage md 2>&1)
    assertContains "$LINENO tu-md.1" "$tResult" '# DESCRIPTION'
    assertContains "$LINENO tu-md.2" "$tResult" '# HISTORY'

    #-----
    tResult=$(fUsage int 2>&1)
    assertContains "$LINENO tu-internal.1" "$tResult" 'Template Use'
    assertContains "$LINENO tu-internal.2" "$tResult" 'fComSetGlobals'

    #-----
    tResult=$(fUsage int-html 2>&1)
    assertContains "$LINENO tu-int-html.1" "$tResult" '<a href="#Template-Use">Template Use</a>'
    assertContains "$LINENO tu-int-html.2" "$tResult" '<h3 id="fComSetGlobals">fComSetGlobals</h3>'
    assertContains "$LINENO tu-int-html.3" "$tResult" 'Internal Doc</title>'
    assertContains "$LINENO tu-int-html.4" "$tResult" '<h3 id="testComUsage">testComUsage</h3>'

    #-----
    tResult=$(fUsage int-md 2>&1)
    assertContains "$LINENO tu-int-md.1" "$tResult" '## Template Use'
    assertContains "$LINENO tu-int-md.2" "$tResult" '### fComSetGlobals'
    assertContains "$LINENO tu-int-md.3" "$tResult" '### testComUsage'

    #-----
    tResult=$(./tag-collect.sh 2>&1)
    assertContains "$LINENO tu-cmd-call" "$tResult" "NAME tag-collect.sh"

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
testScriptFunctions()
{
    local tResult

    tResult=$(fSetGlobals 2>&1)
    assertTrue "$LINENO tsf-fSetGlobals" "[ $? -eq 0 ]"

    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 testScriptFunctions

This is just a starting point for creating script functionality tests.

=internal-cut
EOF
} # testScriptFunctions

# --------------------------------
testValidate()
{
    local tResult
    
    #-----
    gpFileList="foobar"
    tResult=$(fValidate 2>&1)
    assertContains "$LINENO tv-validate-fail $tResult" "$tResult" "File not found"
    
    #-----
    gpTest=""
    tResult=$(./tag-collect.sh foobar 2>&1)
    assertContains "$LINENO tv-cmd-no-file" "$tResult" "File not found"

    #-----
    gpFileList="bash-com.inc"
    gpTag="NA"
    tResult=$(fValidate 2>&1)
    assertNull "$LINENO tv-validate-ok $tResult" "$tResult"

    #-----
    tResult=$(./tag-collect.sh bash-com.inc 2>&1)
    assertNotNull "$LINENO tv-cmd-ok" "$tResult"

    #-----
    gpTag=""
    tResult=$(fValidate 2>&1)
    assertContains "$LINENO tv-no-tags" "$tResult" "Missing -t option"

    #-----
    echo "test" >~/tmp/tag-collect-test.tmp
    tResult=$(./tag-collect.sh -t tagxx ~/tmp/tag-collect-test.tmp 2>&1)
    assertNull "$LINENO tv-cmd-tags-ok $tResult" "$tResult"
    rm ~/tmp/tag-collect-test.tmp
    
    return 0
} # testValidate

testGetTag()
{
    local tResult

    # Setup
    gpTestDir=~/tmp/test-tag-collect
    mkdir -p $gpTestDir
    cat <<EOF >$gpTestDir/tag-file1.txt
tag1
NOT
{tag1}
Testing 123
{tag2}
Testing 456
{tag3} {tag4} {tag1}
Testing 789
{tag3}
Testing 123
EOF

    gpTag="tagxy"
    gpFileList=$gpTestDir/tag-file1.txt
    tResult=$(fGetTaggedText 2>&1)
    assertNotContains "$LINENO tgt-nothing" "$tResult" "Testing 123"

    gpTag="tag1"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-1" "$tResult" "Testing 123"
    assertNotContains "$LINENO tgt-not-1" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-not-2" "$tResult" "Testing 456"

    gpTag="tag2"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-2" "$tResult" "Testing 456"
    assertNotContains "$LINENO tgt-not-3" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-not-4 $tResult" "$tResult" "Testing 123"

    gpTag="tag3"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-3" "$tResult" "Testing 789"
    assertNotContains "$LINENO tgt-not-3" "$tResult" "NOT"
    assertContains "$LINENO tgt-found-5" "$tResult" "Testing 123"

    gpTag="tag1"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-4" "$tResult" "Testing 123"
    assertContains "$LINENO tgt-found-5" "$tResult" "Testing 789"

    gpTag="tag3 tag2"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-6" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-found-7" "$tResult" "Testing 789"

    gpTag="tag3 tag2 tag2 tag3"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-6" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-found-7" "$tResult" "Testing 789"
    assertEquals "$LINENO tgt-only-one-1" "$(echo $tResult | grep -c 'Testing 456')" "1"
    assertEquals "$LINENO tgt-only-one-2" "$(echo $tResult | grep -c 'Testing 789')" "1"

    gpTag="tag3 tag1"
    tResult=$(fGetTaggedText 2>&1)
    assertContains "$LINENO tgt-found-7" "$tResult" "Testing 123"
    assertContains "$LINENO tgt-found-8" "$tResult" "Testing 789"
    assertEquals "$LINENO tgt-only-one-3" "$(echo $tResult | grep -c 'Testing 123')" "1"
    assertEquals "$LINENO tgt-only-one-3" "$(echo $tResult | grep -c 'Testing 789')" "1"

    gpTag=" "
    gpFileList=""
    gpTest=""
    tResult=$(./tag-collect.sh  tag1 $gpTestDir/tag-file1.txt 2>&1)
    assertNotContains "$LINENO tgt-cmd-found-1" "$tResult" "Testing 123"
    assertNotContains "$LINENO tgt-cmd-not-1" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-cmd-not-1" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-cmd-not-1 crit" "$tResult" "crit"

    tResult=$(./tag-collect.sh  -t tag1 $gpTestDir/tag-file1.txt 2>&1)
    assertContains "$LINENO tgt-cmd-found-2" "$tResult" "Testing 123"
    assertNotContains "$LINENO tgt-cmd-not-2" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-cmd-not-2" "$tResult" "Testing 456"
    assertNotContains "$LINENO tgt-cmd-not-2 crit" "$tResult" "crit"

    tResult=$(./tag-collect.sh  -t tag3 -t tag2 $gpTestDir/tag-file1.txt 2>&1)
    assertContains "$LINENO tgt-cmd-found-3" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-cmd-found-4" "$tResult" "Testing 789"

    return 0
} # testGetTag

# -------------------
# This should be the last defined function
fRunTests()
{
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
# Configuration Section

# shellcheck disable=SC2016
cVer='$Revision: 1.4 $'
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fError2 -m "Missing options." -l $LINENO
fi
while getopts :t:hH:lT:vx tArg; do
    case $tArg in
        # Script arguments
        t)  # Don't add dups
	    if [ "${gpTag}" = "${gpTag## *$OPTARG}" ]; then
	        gpTag="$gpTag $OPTARG"
	    fi
	;;
        # Common arguments
        h) fUsage long ;;
        H) fUsage "$OPTARG" ;;
        l) gpLog=1 ;;
        v) let ++gpVerbose ;;
        x) let ++gpDebug ;;
        T) gpTest="$OPTARG" ;;
        # Problem arguments
        :) fError "Value required for option: -$OPTARG" $LINENO ;;
        \?) fError "Unknown option: $OPTARG" $LINENO ;;
    esac
done
shift $((OPTIND - 1))
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

fValidate

# -------------------
# Read-only section

##timeout 5 awk -f $cTmp1 >$cTmp2

# -------------------
# Write section

##fProcess $tList

# -------------------
# Output section

fGetTaggedText

# -------------------
# CleanUp Section
fCleanUp

return 0
