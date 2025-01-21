#!/bin/bash
# $Source: /repo/per-bruce.cvs/bin/bash-com.inc,v $
# $Revision: 1.20 $ $Date: 2025/01/21 02:10:44 $ GMT

export PWD Tmp cBin cCurDir cName cPID cTmp1 cTmp2 cTmpF cVer
export gErr gpDebug gpFacility gpLog gpVerbose gpTest SHUNIT_COLOR

# --------------------------------
fBashComInternalDoc() {
    return
    # This should be the first =internal-pod
    cat <<\EOF >/dev/null
=internal-pod

=internal-for text ========================================

=internal-for html <hr/>

=internal-head1 bash-com.inc Internal Documentation

=internal-head2 Template Use

=internal-head3 Configuration

 * Copy template.sh to your script file.
 * Your script, bash-com.inc, and bash-com.test need to be in the same directory.
 * Globally replace SCRIPTNAME with the name of your script file.
 * Update the getopts in the "Get Args Section". Add your script's options.
 * Loop: document (with POD), add tests, add validate functions
 * Loop: add unit test function, add functions, test

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

To avoid a lot of rework and manual rollbacks, put-off I<writes> that
cannot undone. Do as much as possible to make sure the script will be able
to complete write operations.

For example, B<do not do this:> collect information, transform it,
write it to a DB, then start the next process on another server.
Whoops, that server cannot be accessed, so the DB update is not valid!
Gee, why didn't you verify all the connections you will need, before
committing to the DB?!  Even if you did check, the connection could
have failed after the check, so maybe write to a tmp DB, then when all
is OK, then update the master DB with the tmp DB changes.

Where ever possible make your scripts "re-entrant". Connections can
fail at anytime and scripts can be killed at anytime; How can any
important work be continued or work rolled-back? Planing for
"failures" is NOT planning to fail; it is what a professional engineer
does to design in quality.

=internal-head3 Variable Naming Convention

Prefix codes are used to show the B<"scope"> of variables:

 gVar - global variable (may even be external to the script)
 pVar - a function parameter I<local>
 gpVar - global parameter, i.e. may be defined external to the script
 cVar - global constant (set once)
 tVar - temporary variable (usually I<local> to a function)
 fFun - function

All UPPERCASE variables are I<only> used when they are required by other
programs or scripts.

If you have exported variables that are shared across scritps, then
this convention can be extended by using prefixes that are related to
where the variables are set.

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
 cVer - current version. For example, if using CVS:
        # shellcheck disable=SC2016
        cVer='$Revision: 1.20 $'

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
See fComInternalDoc() for how this is used.

Also TDD (Test Driven Development) should make refactoring easy,
because the tests are often embedded in the script. See template.sh
for how.

=internal-head2 Common Script Functions

=internal-cut
EOF
} # fBashComInternalDoc

# ========================================
# Common Functions

# -------------------
fComSetGlobals() {
    # -------------------
    # Set name of this script
    local tName=${0##*/}
    cName=${cName:-$tName}

    # -------------------
    # Set current directory location in PWD and cCurDir, because with cron
    # jobs PWD is not set.
    if [[ -z "$PWD" ]]; then
        PWD=$(pwd)
    fi
    cCurDir=${cCurDir:-$PWD}

    # -------------------
    # Define the location of the com script if not already set
    if [[ -z "$cBin" ]]; then
        cBin=${0%/*}
        if [[ "$cBin" = "." ]]; then
            cBin=$PWD
        fi
        cd $cBin
        cBin=$PWD
        cd $cCurDir
    fi

    # -------------------
    # Setup log variables
    # -x
    gpDebug=${gpDebug:-0}
    # -v
    gpVerbose=${gpVerbose:-0}
    # -l
    gpLog=${gpLog:-0}
    gpFacility=${gpFacility:-user}
    gErr=0

    # -------------------
    # If your script defines a version with the Revision keyword, clean it
    # shellcheck disable=SC2016
    #cVer='$Revision: 1.20 $'

    if [[ "$cVer" != "${cVer#*' '}" ]]; then
        cVer=${cVer#*' '}
        cVer=${cVer%' '*}
    fi

    # -------------------
    # Setup a temporary directory for each user/script.
    Tmp=${Tmp:-"/tmp/$USER/$cName"}
    if [[ ! -d $Tmp ]]; then
        mkdir -p $Tmp 2>/dev/null
        if [[ ! -d $Tmp ]]; then
            fError2 -m "Could not find directory $Tmp (\$Tmp)." -l $LINENO
        fi
    fi

    # -------------------
    # Define temporary file names used by this script.  The
    # variables for the file names can be any name, but the file
    # name pattern should be:
    # "${cTmpF}-*.tmp"
    cPID=$$
    cTmpF=$Tmp/file-$cPID
    if [[ $gpDebug -ne 0 ]]; then
        cTmpF=$Tmp/file
        rm -f ${cTmpF}*.tmp 2>/dev/null
    fi
    # shellcheck disable=SC2034
    cTmp1=${cTmpF}-1.tmp
    # shellcheck disable=SC2034
    cTmp2=${cTmpF}-2.tmp
    # shellcheck disable=SC2172
    trap fCleanUp 1 2 3 4 5 6 7 8 10 11 12 13 14 15

    # -------------------
    gpTest=${gpTest:-""}
    return 0

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fComSetGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

=internal-cut
EOF
} # fComSetGlobals

# --------------------------------
fComCleanUp() {
    # shellcheck disable=SC2172
    trap - 1 2 3 4 5 6 7 8 10 11 12 13 14 15
    if [[ $gpDebug -eq 0 ]]; then
        'rm' -f ${cTmpF}*.tmp 2>/dev/null
    fi
    ##fLog notice "Done" $LINENO 9900
    exit $gErr

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fCleanUp

Called when script ends (see trap) to remove temporary files.
Except if gpDebug != 0, then tmp files are not removed.

=internal-cut
EOF
} # fComCleanUp

# --------------------------------
fComCheckDeps() {
    local pRequired="$1"
    local pOptional="$2"

    local tProg
    local tErr=0
    local tComReq='logger pod2text pod2usage'
    local tComOpt='pod2html pod2man pod2markdown tidy shunit2.1 gawk sed tr fmt'

    for tProg in $pOptional $tComOpt; do
        if ! which $tProg &>/dev/null; then
            echo "Optional: Missing $tProg"
            tErr=1
        fi
    done

    for tProg in $pRequired $tComReq; do
        if ! which $tProg &>/dev/null; then
            echo "Required: Missing $tProg"
            tErr=2
        fi
    done

    if [[ $tErr -eq 2 ]]; then
        fError2 -m "Missing one or more required programs." -l $LINENO
    fi
    if [[ $tErr -eq 1 ]]; then
        fLog2 -p warning -m "Missing some some optional programs." -l $LINENO
    fi
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fComCheckDeps "pRequired List" "pOptional List"

Check for required and optional programs or scripts used by this script.
If any required programs are missing, exit the script.

=internal-cut
EOF
} # fComCheckDeps

# --------------------------------
fComInternalDoc() {
    local pAll="$1"

    if [[ ".$pAll" = ".-a" ]]; then
        awk '
                        /^=internal-pod/,/^=internal-cut/ {
                                sub(/^=internal-/,"=");
                        }
                        {
                                print $0;
                        }
                '
    else
        awk '
                        /^=internal-pod/,/^=internal-cut/ {
                                sub(/^=internal-/,"=");
                                print $0;
                        }
                '
    fi
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fComInternalDoc [-a]

This function collects all of the "internal-pod" documentation from
stdin and it outputs to stdout.

If -a option is givein, then ALL pod documentation is output.

=internal-cut
EOF
} # fComInternalDoc

# --------------------------------
fComUsage() {
    local pFileList=""
    local pStyle="long"
    local pInt=0
    local pAll="-n"
    local pTitle="$cName Usage"

    local tProg=""
    local tFileList=""
    local tTidy='tidy -m -q -i -w 78 -asxhtml --break-before-br yes --indent-attributes yes --indent-spaces 2 --tidy-mark no --vertical-space no'

    local OPTIND=1
    local OPTARG
    local tArg

    while getopts :f:s:t:ia tArg; do
        case $tArg in
            f) pFileList="$pFileList $OPTARG" ;;
            s) pStyle="$OPTARG" ;;
            t) pTitle="$OPTARG" ;;
            i) pInt=1 ;;
            a)
                pInt=1
                pAll='-a'
                ;;
            :) fError2 -i -m "fComUsage: Value required for option: -$OPTARG" -l $LINENO ;;
            \?) fError2 -i "fComUsage: Unknown option: $OPTARG" -l $LINENO ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ $# -ne 0 ]]; then
        fError2 -i -m "fComUsage: Unknown option: $*" -l $LINENO
    fi
    while [[ $# -ne 0 ]]; do
        shift
    done

    case $pStyle in
        short | usage)
            tProg=pod2usage
            if [[ $pInt -ne 0 ]]; then
                # This fails, don't know why
                tProg='pod2text | head -n 24'
                tProg=pod2text
            fi
            ;;
        man)
            tProg=pod2man
            if [[ $pInt -ne 0 ]]; then
                tProg=pod2text
            fi
            ;;
        long | text)
            tProg=pod2text
            ;;
        html)
            tProg=pod2html
            ;;
        md)
            tProg=pod2markdown
            ;;
        *)
            tProg=pod2text
            ;;
    esac

    # Validate
    pFileList=$pFileList
    if [[ -z "$pFileList" ]]; then
        fError2 -i -m "fComUsage missing pFileList" -l $LINENO
    fi
    for tFile in $pFileList; do
        if [[ -r $tFile ]]; then
            tFileList="$tFileList $tFile"
        else
            fError2 -i -m "fComUsage cannot read: $tFile" -l $LINENO
        fi
    done
    tFileList=$tFileList
    if [[ -z "$tFileList" ]]; then
        fError2 -i -m "fComUsage missing a valid pFileList" -l $LINENO
    fi

    if [[ $pInt -eq 0 ]]; then
        if [[ "$pStyle" = "html" ]]; then
            # shellcheck disable=SC2002
            cat $pFileList | $tProg --title="$pTitle" | $tTidy
        else
            if [[ "$pStyle" = "short" ]]; then
                # shellcheck disable=SC2002
                cat $tFileList | pod2text | head -n 20
            else
                # shellcheck disable=SC2002
                cat $tFileList | $tProg
            fi
        fi
    else
        if [[ "$pStyle" = "html" ]]; then
            # shellcheck disable=SC2002
            cat $pFileList | fComInternalDoc $pAll | $tProg --title="$pTitle" | $tTidy
        else
            # shellcheck disable=SC2002
            cat $pFileList | fComInternalDoc $pAll | $tProg
        fi
    fi

    gErr=1
    fCleanUp
    exit 1

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fComUsage -f pFileList -s pStyle [-t pTitle] [-i] [-a]

=internal-over 4

=internal-item B<-f pFileList> - list of file names

=internal-item B<-s pStyle> - output style

 short|usage - usage only (does not work with -i or -a)
 man         - all, man format (does not work with -i or -a)
 long|text   - all text format
 html        - all, html format (see -t)
 md          - all, markdown format

=internal-item B<-t> - title for HTML style

=internal-item B<-i> - internal doc only (see fComInternalDoc)

=internal-item B<-a> - all docs: user and internal (see fComInternalDoc)

=internal-back

=internal-cut
EOF
} # fComUsage

# ------------------
fFmtLog() {
    local pLevel=$1
    local pMsg="$2"
    local pLine=$3
    local pErr=${4:-''}

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
    if [[ $gpDebug -eq 0 ]] && [[ "${pLevel%-*}" = "debug" ]]; then
        return
    fi
    if [[ $gpDebug -ne 0 ]] && [[ "${pLevel%%-*}" != "$pLevel" ]]; then
        tDebugLevel=${pLevel##*-}
        if [[ $tDebugLevel -gt $gpDebug ]]; then
            return
        fi
        tLevel=debug
    fi

    # Check verbose
    if [[ $gpVerbose -eq 0 && ("$pLevel" = "notice" || "$pLevel" = "info") ]]; then
        return
    fi
    if [[ $gpVerbose -eq 1 && "$pLevel" = "info" ]]; then
        return
    fi

    # LineNo format
    tLine=""
    if [[ -n "$pLine" ]]; then
        tLine="[$pLine]"
    fi

    # Err format
    tErr=""
    if [[ -n "$pErr" ]]; then
        tErr="($pErr)"
    fi

    # Output
    if [[ $gpLog -eq 0 ]]; then
        echo "${cName} $pLevel: $pMsg $tLine$tErr" 1>&2
    else
        logger -s -t $cName -p $gpFacility.$tLevel "$pLevel: $pMsg $tLine$tErr"
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
fLog() {
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

    fFmtLog $pLevel "$pMsg" $pLine "$pErr"
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLog pLevel "pMsg" [$LINENO] [pErr]

pLevel - emerg alert crit err warning notice info debug debug-N

See Globals: gpLog, gpFacility, gpVerbose, gpDebug

=internal-head4 fLog Examples:

 fLog warning "Missing awk" $LINENO 8
 fLog notice "Output only if -v" $LINENO 8
 fLog info "Output only if -vv" $LINENO 8
 fLog debug "Output only if $gpDebug > 0" $LINENO
 fLog debug-3 "Output only if $gpDebug > 0 and $gpDebug <= 3" $LINENO

=internal-cut
EOF
} # fLog

# --------------------------------
fError() {
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
fLog2() {
    local pLevel="info"
    local pMsg=""
    local pLine=""
    local pErr=""

    local OPTARG=1
    local OPTIND
    local tArg
    while getopts :m:p:l:e: tArg; do
        case $tArg in
            m) pMsg="${OPTARG}" ;;
            l) pLine="${OPTARG}" ;;
            p) pLevel="${OPTARG}" ;;
            e)
                pErr="${OPTARG}"
                gErr="${OPTARG}"
                ;;
            :) echo "Internal: Value required for option: -$OPTARG [$LINENO]" ;;
            \?) echo "Internal: Unknown option: $OPTARG [$LINENO]" ;;
        esac
    done
    shift $((OPTIND - 1))
    while [[ $# -ne 0 ]]; do
        shift
    done

    fFmtLog $pLevel "$pMsg" $pLine $pErr
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLog2 -m pMsg [-p pLevel] [-l $LINENO] [-e pErr]

This is like fLog, but the arguments can be in any order.

See fLog. See also global gpFacility

=internal-cut
EOF
} # fLog2

# --------------------------------
fError2() {
    local pMsg="Error"
    local pLine="."
    local pErr=1
    local pInt=0

    local OPTIND=1
    local OPTARG
    local tArg

    while getopts :m:l:e:i tArg; do
        case $tArg in
            m) pMsg="${OPTARG}" ;;
            l) pLine="${OPTARG}" ;;
            e) pErr="${OPTARG}" ;;
            i) pInt=1 ;;
            :) echo "Internal: Value required for option: -$OPTARG [$LINENO]" ;;
            \?) echo "Internal: Unknown option: $OPTARG [$LINENO]" ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ $# -ne 0 ]]; then
        pMsg="$pMsg $*"
    fi
    while [[ $# -ne 0 ]]; do
        shift
    done
    gErr=$pErr

    if [[ $pInt -eq 1 ]]; then
        pMsg="Internal: $pMsg"
    fi
    fLog2 -p crit -l $pLine -e $pErr -m "$pMsg"
    if [[ $pInt -eq 0 ]]; then
        fUsage usage
    fi
    exit 1
    return

    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fError2 -m pMsg [-l $LINENO] [-e pErr] [-i]

This will call: fLog2 -p crit -m "pMsg" -l pLine -e pErr

If no -i, then "fUsage short", will be called.

=internal-cut
EOF
} # fError2

# --------------------------------
fTimeoutFunction() {
    # Number of seconds
    declare -i pTimeout
    # Cmd including args
    local pCmd

    pTimeout=$1
    pCmd="$2"

    declare -x tChild
    (
        eval "$pCmd" &>/dev/null &
        tChild=$!
        trap -- "" SIGTERM
        (
            sleep $pTimeout
            kill $tChild 2>/dev/null
        ) &
        wait $tChild
    )
    return
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fTimeoutFunction pSec "pCmd [args...]"

Algorithm idea came from:

https://stackoverflow.com/questions/9954794/execute-a-shell-function-with-timeout

=internal-cut
EOF
} # fTimeoutFunction
