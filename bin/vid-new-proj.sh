#!/usr/bin/env bash
set -u

# Config

# Std
export cName=vid-new-proj.sh
export gpNew=""

# Default dirs
# -t
export gpTopDir=~/ver/video-proj
# -e
export gpExtRepo=/mnt/usb-video/video-proj
# -r
export gpRefCvsRoot=$gpExtRepo/template

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

Create a new video project.

=head1 SYNOPSIS

    $cName -n ProjName [-t TopDir] [-e ExternalDir] [-r CVSRootDir]
           [-h] [-H pStyle]
    Defaults:
    -t TopDir = $gpTopDir
    -e ExternalDir = $gpExtRepo
    -r CVSRootDir = $gpRefCvsRoot

=head1 DESCRIPTION

Create a new project (-n ProjName) in -t TopDir. The files will be
archive at -e ExternalDir. Reference dir -r CVSRootDir will be used to
creating the new project.

=head1 OPTIONS

=over 4

=item B<-n ProjName>

Name of the new project. Required option.

=item B<-t TopDir>

Top directory for the project.  Default: $gpTopDir

=item B<-e ExternalDir>

Top external directory for the cvs and raw files.  Default: $gpExtRepo

=item B<-r CVSRootDir>

Reference CVSRoot directory that will be copied to create the new
project.  Default: $gpRefCvsRoot

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

vid-restore-proj.sh

=head1 NOTES

-e ExternalDir is usually a mounted drive.

=for comment =head1 CAVEATS
=for comment =head1 DIAGNOSTICS
=for comment =head1 BUGS
=for comment =head1 RESTRICTIONS
=for comment =head1 AUTHOR

=head1 HISTORY

\$Revision: 1.8 $  \$Date: 2026/04/10 18:42:41 $ GMT

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

while getopts :n:t:e:r:hH: tArg; do
    case $tArg in
        # Script arguments
        e) gpExtRepo="$OPTARG" ;;
        n) gpNew="$OPTARG" ;;
        r) gpRefCvsRoot="$OPTARG" ;;
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

# --------------------
# Validate section

if [[ "$USER" = "root" ]]; then
    echo "Error: must not be root user [$LINENO]"
    fUsage usage
fi

if [[ -z "$gpNew" ]]; then
    echo "Error: -n ProjName is required [$LINENO]"
fi

if [[ ! -d $gpTopDir ]]; then
    echo "Error: Missing dir: $gpTopDir (-t) [$LINENO]"
    fUsage usage
fi
if [[ -d $gpTopDir/$gpNew ]]; then
    echo "Error: Dir already exists: $gpTopDir/$gpNew [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpExtRepo ]]; then
    echo "Error: Dir missing -e $gpExtRepo (not mounted?) [$LINENO]"
    fUsage usage
fi

if [[ -d $gpExtRepo/$gpNew.cvs ]]; then
    echo "Error: Already exists: $gpExtRepo/$gpNew.cvs [$LINENO]"
    fUsage usage
fi

if [[ -d $gpExtRepo/$gpNew.raw ]]; then
    echo "Error: Already exists: $gpExtRepo/$gpNew.raw [$LINENO]"
    fUsage usage
fi

if [[ ! -d $gpRefCvsRoot.cvs ]]; then
    echo "Error: Dir missing: $gpRefCvsRoot.cvs [$LINENO]"
    fUsage usage
fi
if [[ ! -d $gpRefCvsRoot.raw ]]; then
    echo "Error: Dir missing: $gpRefCvsRoot.raw [$LINENO]"
    fUsage usage
fi

# --------------------
# Functional section

cp -a $gpRefCvsRoot.cvs $gpExtRepo/$gpNew.cvs
cp -a $gpRefCvsRoot.raw $gpExtRepo/$gpNew.raw
find $gpExtRepo/$gpNew.* -type d -exec chmod a+rx {} \;
find $gpExtRepo/$gpNew.* -type f -exec chmod a+r {} \;

mkdir -p $gpTopDir/$gpNew
cd $gpTopDir/$gpNew
export CVSROOT=$gpExtRepo/$gpNew.cvs
cvs co CVSROOT
cvs co edit

cd edit
sed -i "s/NAME/$gpNew/g" Makefile
sed -i "s/NAME/$gpNew/g" description.org
echo >logtime.csv
ln -sf $gpExtRepo/$gpNew.raw raw
mksymlink -sf
mv -f .symlink.$HOSTNAME .symlink
cvs add .symlink

echo "Save cachefiles/ to raw/"
echo "FYI disk space on $gpExtRepo"
df -h $gpExtRepo
echo "FYI disk space for $gpTopDir/$gpNew"
df -h $gpTopDir/$gpNew
