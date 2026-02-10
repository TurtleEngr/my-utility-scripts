#!/usr/bin/env bash
set -u

# ========================================
# Config

# Std
export cName=${BASH_SOURCE##*/}

# Dirs and other
export cRun=/home/$USER/bin/$cName
export cSarDir=/var/log/sysstat
export cSarHost=moria
export cSarSummary=/tmp/sar.txt
export cSarLocal=~/Downloads
export cSarChart=https://sarchart.dotsuresh.com/

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

Get a graphable summary of the sysstat sar files from my webserver.

=head1 SYNOPSIS

    $cName [-g] [-s] [-h] [-H pStyle]

=head1 DESCRIPTION

Copy this script on the $cSarHost. Run this on your local system
with the -g option.

On the $cSarHost this script will be run with the -s option. That will
create the summary file: $cSarSummary Then that file will be
downloaded to $cSarLocal

In your browser go to: $cSarChart and upload $cSarLocal/sar.txt

=head1 OPTIONS

=over 4

=item B<-g>

Get the sar summary file $cSarSummary from $cSarHost

$cSarSummary is downloaded to $cSarLocal

=item B<-s>

This is run on $cSarHost to collect all the sar values in $cSarDir

The summary is put in $cSarSummary

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

# -------------------
# Get Args Section
if [[ $# -eq 0 ]]; then
    fUsage usage
fi

export gpGet=0
export gpSummary=0
while getopts :gshH: tArg; do
    case $tArg in
        # Script arguments
        g) gpGet=1 ;;
        s) gpSummary=1 ;;
        n) gpHostName="$OPTARG" ;;
        # Common arguments
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
    echo "Error: Unknown option: $* [$LINENO]"
    fUsage usage
fi

# --------------------
# Validate section

if [[ "$USER" = "root" ]]; then
    echo "Error: must not be root user $[LINENO]"
    fUsage usage
fi

# --------------------
# Functional section

if [[ $gpSummary -ne 0 ]]; then
    ls $cSarDir/sa?? | xargs -i sar -A -f {} > $cSarSummary
    exit 0
fi

if [[ $gpGet -eq 0 ]]; then
    exit 1
fi

ssh $cSarHost "$cRun -s"
scp $cSarHost:$cSarSummary $cSarLocal/
echo "In your browser go to: $cSarChart"
echo "and upload $cSarLocal/sar.txt"
