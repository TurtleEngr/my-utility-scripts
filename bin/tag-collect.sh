#!/bin/bash
# $Source: /repo/per-bruce.cvs/bin/tag-collect.sh,v $
# $Revision: 1.16 $ $Date: 2023/05/21 01:10:35 $ GMT

# ========================================
# Include common bash functions at $cBin/bash-com.inc But first we
# need to set cBin

export gpFileList gpTag gpSize

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
fUsage() {
    # Quick help, run this:
    # tag-collect.sh -h | less

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

        tag-collect.sh -t pTag [-s pSize] [-h] [-H pStyle] [-T pTest]
                       pFiles... >OutputFile

=head1 DESCRIPTION

pTags will be looked for in the list of pFiles. When found the tag line
and all lines after it will be listed, until another tag is found or
EOF.

Duplicate text in the tag sections will be removed from the output.

See the EXAMPLE section for the example of tags in files.

=head1 OPTIONS

=over 4

=item B<-t pTag>

Look for {pTag} in the list of Files.

More than one -t option can be used to select any number of
tags. There is an implied "or" for multiple -t tags. If you want an
"and", then you will need to repeat tag-collect.sh on the OutputFile
for the tags you also want for the items.

=item B<-s pSize>

Maximum number of lines after a tag. Default: 1000

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

=item B<-T pTest>

Run the unit test functions in this script.

"-T all" will run all of the functions that begin with "test".
Otherwise "pTest" should match the test function names separated with
spaces (between quotes).

"-T com" will run all the tests for bash-com.inc

For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html
L<Source|https://github.com/kward/shunit2>

See shunit2, shunit2.1

Also for more help, use the "-H int" option.

=back

=for comment =head1 RETURN VALUE
=for comment [What the program or function returns if successful.]

=head1 ERRORS

Fatal Errors:

* Missing -t option.

* A pFile does not exist

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

    $ tag-collect-sh -t tag1 file[12].txt
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

=for comment =head1 ENVIRONMENT
=for comment =head1 FILES

=head1 SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

=head1 NOTES

=head2 How to use this script effectively?

* Define a common tag that will be on all items.

* Put more than one tag on the different item parts in a text file.

* Since a new tag will end a tag block, be sure to have some tag after
the last tag, or the last tag will take all text until the end of the
file.

* Ideally the tags should be on a line of their own, no other text.

* Note: Anything between {} on a line, will be concidered a tag, so
don't use {} in the "item" text.

=head3 To sift through the tags

* Start with the the most general categories. Include all files, but
select with only one tag, and put those items into separate files.

* For each of the top category files, use other sub tags to create the
sub-category files.

* There will likely be duplicate items, so to remove them, use the
common tag to select the items, putting the list of category and
sub-category files in the desired order on the command line. Duplicate
items will removed, and only the first item found will be in the final
output.

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

$Revision: 1.16 $ $Date: 2023/05/21 01:10:35 $ GMT

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
    gpLog=0
    gpVerbose=1
    gpDebug=0

    # Put your globals here
    gpFileList=""
    gpTag=""
    gpSize=1000

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
fValidate() {
    local tFile
    local tNewList=""

    for tFile in $gpFileList; do
        if [ ! -f $tFile ]; then
            fLog2 -p warn -m "File not found: $tFile" -l $LINENO
            continue
        fi
        if ! grep -q '{.*}' $tFile; then
            fLog2 -p warn -m "No tags found in: $tFile" -l $LINENO
            continue
        fi
        tNewList="$tNewList $tFile"
    done
    if [ -z "$tNewList" ]; then
        fError2 -m "No files are left to process" -l $LINENO
    fi
    gpFileList="$tNewList"

    if [ -z "$gpTag" ]; then
        fError2 -m "Missing -t option" -l $LINENO
    fi

    echo "$gpSize" | grep -q '^[0-9][0-9]*$'
    if [ $? -ne 0 ]; then
        fError2 -m "Invalid pSize: $gpSize" -l $LINENO
    fi
    if [ $gpSize -le 1 ]; then
        fError2 -m "Invalid pSize: $gpSize" -l $LINENO
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
fGetChunk() {
    local pTag=$1
    local tInTag=""
    local tCount=0
    local tFile

    grep -A $gpSize "{$pTag}" | while read -r; do
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

    'ls' ${cTmpF}-*.tmp >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        fLog2 -m "No files were generated for tag: $pTag" -p warn -l $LINENO
        echo
        return
    fi

    for tFile in ${cTmpF}-*.tmp; do
        tHash=$(sed 's/{.*}//g' $tFile | md5sum)
        grep -q ${tHash% *} $Tmp/unique.tmp >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            rm $tFile
            continue
        fi
        echo ${tHash% *} >>$Tmp/unique.tmp
    done

    'ls' ${cTmpF}-*.tmp >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        fLog2 -m "No files were generated for tag: $pTag" -p warn -l $LINENO
        echo
        return
    fi

    cat ${cTmpF}-*.tmp 2>/dev/null
    rm -f ${cTmpF}-*.tmp >/dev/null 2>&1

    return
} # fGetChunk

# -------------------
fGetTaggedText() {
    local tTag

    rm $Tmp/unique.tmp >/dev/null 2>&1
    for tTag in $gpTag; do
        cat $gpFileList | fGetChunk $tTag
    done
} # fGetTaggedText

# ========================================
# Tests

# --------------------------------
testUsage() {
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
    assertContains "$LINENO tu-cmd-call" "$tResult" "Usage:"
    assertContains "$LINENO tu-cmd-call" "$tResult" "tag-collect.sh"

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

    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 testScriptFunctions

This is just a starting point for creating script functionality tests.

=internal-cut
EOF
} # testScriptFunctions

# --------------------------------
testValidate() {
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
    echo "{test}" >$Tmp/tag-collect-test.tmp
    tResult=$(./tag-collect.sh -t tagxx $Tmp/tag-collect-test.tmp 2>&1)
    assertContains "$LINENO tv-cmd-tags-ok $tResult" "$tResult" "No files were generated"
    rm $Tmp/tag-collect-test.tmp

    return 0
} # testValidate

testGetTag() {
    local tResult

    # Setup
    cat <<EOF >$Tmp/tag-file1.txt
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
    gpFileList=$Tmp/tag-file1.txt
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
    tResult=$(./tag-collect.sh tag1 $Tmp/tag-file1.txt 2>&1)
    assertNotContains "$LINENO tgt-cmd-found-1" "$tResult" "Testing 123"
    assertNotContains "$LINENO tgt-cmd-not-1" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-cmd-not-1" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-cmd-not-1 crit" "$tResult" "crit"

    tResult=$(./tag-collect.sh -t tag1 $Tmp/tag-file1.txt 2>&1)
    assertContains "$LINENO tgt-cmd-found-2" "$tResult" "Testing 123"
    assertNotContains "$LINENO tgt-cmd-not-2" "$tResult" "NOT"
    assertNotContains "$LINENO tgt-cmd-not-2" "$tResult" "Testing 456"
    assertNotContains "$LINENO tgt-cmd-not-2 crit" "$tResult" "crit"

    tResult=$(./tag-collect.sh -t tag3 -t tag2 $Tmp/tag-file1.txt 2>&1)
    assertContains "$LINENO tgt-cmd-found-3" "$tResult" "Testing 456"
    assertContains "$LINENO tgt-cmd-found-4" "$tResult" "Testing 789"

    return 0
} # testGetTag

# -------------------
# This should be the last defined function
fRunTests() {
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
cVer='$Revision: 1.16 $'
fSetGlobals

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fError2 -m "Missing options." -l $LINENO
fi
while getopts :t:s:hH:T: tArg; do
    case $tArg in
        # Script arguments
        t) # Don't add dups
            if [ "${gpTag}" = "${gpTag## *$OPTARG}" ]; then
                gpTag="$gpTag $OPTARG"
            fi
            ;;
        s) gpSize=$OPTARG ;;
        # Common arguments
        h) fUsage long ;;
        H) fUsage "$OPTARG" ;;
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

# -------------------
# Write section

# -------------------
# Output section

fGetTaggedText

# -------------------
# CleanUp Section
fCleanUp

return 0
