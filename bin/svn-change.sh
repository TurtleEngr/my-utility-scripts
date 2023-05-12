#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/svn-change.sh,v 1.5 2023/03/25 22:21:42 bruce Exp $

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
# gpTmp - personal tmp directory.  Usually set to: /tmp/$LOGNAME
# cTmpF - tmp file prefix.  Includes $gpTmp and $$ to make it unique
# gErr - error code (0 = no error)
# cVer - current version
# cName - script's name
# cBin - directory where the script is executing from
# cCurDir - current directory

# --------------------------------
function fUsage()
{
    # Print usage help for this script, using pod2text.
    pod2text $0
    exit 1
    cat <<EOF >/dev/null
=pod

=head1 NAME

svn-change.sh - list file have have been added or modified since a specific version

=head1 SYNOPSIS

        svn-change.sh -n version [-h[elp]] [-v[erbose]] [-d[ebug] level]

=head1 DESCRIPTION


=head1 OPTIONS

=over 4

=item B<-n version>

SVN version number

=item B<-v>

Verbose output.  Sent to stderr.

=back

=head1 RETURN VALUE

[What the program or function returns if successful.]

=head1 ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following: (FILE:LINE) [PROGRAM:LINE]

=head1 EXAMPLES

=head1 ENVIRONMENT

$HOME

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

Bruce Rafnel

=head1 HISTORY

Bruce R.

$Revision: 1.5 $ GMT

=cut
EOF
}

# --------------------------------
function fError()
{
    # Input:
    #   $1 - Error number (usually $LINENO)
    #   $2 - Error message
    #   $gNoExit - if =1, then don't exit, and clear the flag

    # Print the error message (fError options).  Then call
    # fCleanUp to exit (if $gNoExit=0)
    gErr=$1
    shift
    set -f
    echo "Error: $* [$gErr]" 1>&2
    set +f
    if [ $gNoExit -ne 0 ]; then
        gNoExit=0
        return
    fi
    cat <<EOF 1>&2
Usage:  $gName -n version [-h[elp]] [-v[erbose]] [-d[ebug] level]  Type: "$gName -h" for more help.
EOF
    exit 1
}

# ------------------
function fLog()
{
    # Input:
    #   $1 level (# emerg alert crit err warning notice info debug)
    #   $2 message
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
export gBin gCurdir gErr gDebug gName \
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
gNoExit=0
gVerbose=${gVerbose:-0}

# -------------------
# Define the version number for this script
gVer='$Revision: 1.5 $'
gVer=${gVer#*' '}
gVer=${gVer%' '*}

# -------------------
# Setup a temporary directory for each user.
Tmp=${Tmp:-"/tmp/$LOGNAME"}
if [ ! -d $Tmp ]; then
    mkdir -p $Tmp 2>/dev/null
    if [ ! -d $Tmp ]; then
        fError $LINENO "Could not find directory $Tmp (\$Tmp)."
    fi
fi

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
export cTmpF cTmp1 cTmp2

# -------------------
# Configuration

# -------------------
# Get Options Section
pFileList=''
pVersion=''
while getopts :hcn:t:x tArg; do
    case $tArg in
        h)
            fUsage
            exit 1
            ;;
        n) pVersion=$OPTARG ;;

        x) gDebug=1 ;;
        +x) gDebug=0 ;;
        :) fError $LINENO "Value required for option: $OPTARG" ;;
        \?) fError $LINENO "Unknown option: $OPTARG" ;;
    esac
done
let tOptInd=OPTIND-1
shift $tOptInd
if [ $# -ne 0 ]; then
    pFileList="$*"
fi

# -------------------
#print "In" | $gBin/log -idv
#echo "Version: $gVer" | $gBin/log -sv

# Print dump of variables
if [ $gDebug -ne 0 ]; then
    for i in \
        PWD \
        gBin \
        gCurDir \
        gName \
        gVer \
        gDebug \
        gVerbose \
        gErr \
        pTag \
        pHostName \
        Tmp; do
        eval echo -R "$i=\$$i" | $gBin/log -d
    done
fi

# -------------------
# Validate Options Section

if [ -z $pVersion ]; then
    fError $LINENO "The -n option is required."
fi

if [ ! -d .svn ]; then
    fError $LINENO "You are not in a svn directory."
fi

# -------------------
# Functional Section

svn diff -r $pVersion:HEAD | grep '^Index: ' | sed 's/^Index: //' | sort -u
