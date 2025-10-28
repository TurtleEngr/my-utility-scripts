#!/usr/bin/env bash
set -u

# ========================================
# Config

# Std
export cName=template-simple.sh
export gpLog=0
export gpDebug=${gpDebug:-0}
export Tmp=${Tmp:-"/tmp/$USER/$cName"}
export cBin

# Dirs and other

# ========================================
# Functions

# --------------------------------
fUsage() {
    local pStyle="${1:-usage}"
    local tProg=""
    
    case $pStyle in
        short | usage)
            tProg=pod2usage
            ;;
        long | text)
            tProg=pod2text
            ;;
        html)
            tProg="pod2html --title=$cName"
            ;;
        md)
            tProg=pod2markdown
            ;;
        man)
            tProg=pod2man
            ;;
        *)
            tProg=pod2text
            ;;
    esac

    # Default to pod2text if tProg does not exist
    if ! which ${tProg%% *} >/dev/null; then
        tProg=pod2text
    fi
    
    cat <<EOF >/tmp/$cName.pod
=pod

=for text ========================================

=for html <hr/>

=head1 NAME $cName

SHORT-DESCRIPTION

=head1 SYNOPSIS

    $cName [-o "Name=Value"] [-h] [-H pStyle] [-l] [-v] [-x] [-T pTest]

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

=back

=for comment =head2 Globals
=for comment =head1 RETURN VALUE
=for comment =head1 ERRORS
=for comment =head1 EXAMPLES
=for comment =head1 ENVIRONMENT
=for comment =head1 FILES
=for comment =head1 SEE ALSO
=for comment =head1 NOTES
=for comment =head1 CAVEATS
=for comment =head1 DIAGNOSTICS
=for comment =head1 BUGS
=for comment =head1 RESTRICTIONS
=for comment =head1 AUTHOR

=head1 HISTORY

GPLv2 (c) Copyright

=cut
EOF
    # shellcheck disable=SC2002
    cat /tmp/$cName.pod | $tProg | less
    exit 1
} # fUsage

# ========================================
# Main

cBin=${0%/*}
if [[ "$cBin" = "." ]]; then
    cBin=$PWD
fi
cd $cBin >/dev/null 2>&1
cBin=$PWD
cd - >/dev/null 2>&1

# -------------------
# Get Args Section
if [[ $# -eq 0 ]]; then
    fUsage usage
fi
# Or use this if the script expects stdin
#if [[ -t 0 ]]; then
#    fUsage usage
#fi

while getopts :cn:lhH: tArg; do
    case $tArg in
        # Script arguments
        c) gpHostName=$(hostname) ;;
        n) gpHostName="$OPTARG" ;;
        # Common arguments
        l)  gpLog=1 ;;
        h)
            fUsage long
            ;;
        H)
            fUsage $OPTARG
            ;;
        # Problem arguments
        :) echo "Error: Value required for option: -$OPTARG [$LINENO]"
           fUsage usage
        ;;
        \?) echo "Error: Unknown option: $OPTARG [$LINENO]"
            fUsage usage
        ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [[ $# -ne 0 ]]; then
    gpList="$*"
    # or
    ##echo "Error: Unknown option: $* [$LINENO]"
    ##fUsage usage
fi
while [[ $# -ne 0 ]]; do
    shift
done

# --------------------
if [[ $gpLog -ne 0 ]]; then
    if grep -q TLocal1 /etc/rsyslog.d/* >/dev/null 2>&1; then
        gpFacility=local1
        # All script output will go to file: /var/log/apt/$cName.log
        # For details see template.sh NOTES, Custom Script Logs
    else
        gpFacility=user
        # All script output will go to file: /var/log/user.log
    fi
    exec 1> >(logger -s -t $cName -p $gpFacility.info) 2>&1
fi

# --------------------
# Validate section

if [[ "$USER" = "root" ]]; then
    echo "Error: must not be root user $[LINENO]"
    fUsage usage
fi

# --------------------
# Functional section
