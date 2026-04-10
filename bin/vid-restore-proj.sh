#!/usr/bin/env bash
set -u

# Config

# Std
export cName=vid-restore-proj.sh
export gpProjName=""
export gErr=0

# Default dirs
# -t
export gpTopDir=~/ver/video-proj
# -e
export gpExtRepo=/mnt/usb-video/video-proj
export gCvsRoot=""

# CVS
export CVSUMASK=0007
export CVSUser=$USER
export CVS_RSH=ssh
export RSYNC_OPT=-aCHz
export RSYNC_RSH=ssh

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

Restore an existing video project.

=head1 SYNOPSIS

    $cName -n ProjName [-t TopDir] [-e ExternalDir]
           [-h] [-H pStyle]
    Defaults:
    -t TopDir = $gpTopDir
    -e ExternalDir = $gpExtRepo

=head1 DESCRIPTION

Restore an existing project (-n ProjName) from -e
ExternalDir/ProjName.cvs If .symlink file exists, the raw symlink will
be defined.

=head1 OPTIONS

=over 4

=item B<-n ProjName>

Name of an existing project. Required option.

=item B<-t TopDir>

Top directory for the project.  Default: $gpTopDir

=item B<-e ExternalDir>

Top external directory for the cvs and raw files.  Default: $gpExtRepo

The external project cvs dir will be: $gpExtRepo/ProjName.cvs

The external project raw dir will be: $gpExtRepo/ProjName.raw

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

=head1 SEE ALSO

vid-new-proj.sh

=head1 NOTES

-e ExternalDir is usually a mounted drive.

=for comment =head1 CAVEATS
=for comment =head1 DIAGNOSTICS
=for comment =head1 BUGS
=for comment =head1 RESTRICTIONS
=for comment =head1 AUTHOR

=head1 HISTORY

\$Revision: 1.3 $  \$Date: 2026/04/10 18:58:59 $ GMT

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

while getopts :n:t:e:hH: tArg; do
    case $tArg in
        # Script arguments
        e) gpExtRepo="$OPTARG" ;;
        n) gpProjName="$OPTARG" ;;
        t) gpTopDir="$OPTARG" ;;
        # Common arguments
        h)
            fUsage long
            ;;
        H)
            fUsage $OPTARG
            ;;
        # Problem arguments
        :)
            echo "Error: Value required for option: -$OPTARG [$LINENO]"
            fUsage usage
            ;;
        \?)
            echo "Error: Unknown option: $OPTARG [$LINENO]"
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

gCvsRoot=$gpExtRepo/$gpProjName.cvs

# --------------------
# Validate section

if [[ "$USER" = "root" ]]; then
    echo "Error: must not be root user [$LINENO]"
    fUsage usage
fi

if [[ -z "$gpProjName" ]]; then
    echo "Error: -n ProjName is required [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpTopDir ]]; then
    echo "Error: Missing dir: $gpTopDir (-t) [$LINENO]"
    fUsage usage
fi
if [[ -d $gpTopDir/$gpProjName ]]; then
    echo "Error: Dir already exists. Use cvs update in: $gpTopDir/$gpProjName [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpExtRepo ]]; then
    echo "Error: Dir missing -e $gpExtRepo (not mounted?) [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpExtRepo/$gpProjName.cvs ]]; then
    echo "Error: Missing: $gpExtRepo/$gpProjName.cvs [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpExtRepo/$gpProjName.raw ]]; then
    echo "Error: Missing: $gpExtRepo/$gpProjName.raw [$LINENO]"
    fUsage usage
fi

# --------------------
# Functional section

mkdir -p $gpTopDir/$gpProjName
cd $gpTopDir/$gpProjName
CVSROOT=$gCvsRoot
for i in $gCvsRoot/*; do
    tDir=${i#$gCvsRoot/}
    if ! cvs co $tDir; then
        echo "Error: checking out: $gCvsRoot/$i [$LINENO]"
        gErr=1
    fi
    if [ ! -d $i ]; then
        echo "Error: Problem checking out: $gCvsRoot/$i [$LINENO]"
        gErr=1
    fi
done

if [ ! -d edit ]; then
    echo "Warning: Missing edit dir. Manual setup required now. [$LINENO]"
    exit 1
fi

cd edit
if ! mksymlink -r; then
    echo "Warning: Missing .symlink file, so raw dir is probably not setup. [$LINENO]"
    exit 1
fi
if [ ! -L raw ]; then
    echo "Warning: raw dir is probably not setup. [$LINENO]"
fi
exit $gErr
