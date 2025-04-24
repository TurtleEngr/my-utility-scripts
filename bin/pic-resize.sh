#!/usr/bin/env bash
#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/pic-resize.sh,v 1.5 2025/04/24 05:46:45 bruce Exp $
n
set -u
export cName=pic-resize.sh

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

    Resize jpg image aspect ratio

=head1 SYNOPSIS

    $cName [-r Ratio] [-s SrcDir] [-d DestDir] [-c Color] [-h] [-H Style]

=head1 DESCRIPTION

Resize all jpg images in SrcDir to have aspect set to Ratio. The new
image is put in DestDir (with the same name). If the image is already
had aspect equal to Ratio, a hard link is made from SrcDir to DestDir.

The image will be centered and the vertical or horizonal borders will
be added with the specified Color to make the image fit the specified
Ratio.

=head1 OPTIONS

=over 4

=item B<-r Ratio>

Ratio format is X:Y. Default: 16:9

=item B<-s SrcDir>

Source directory. Default: .

=item B<-d DestDir>

Destination directory. Default: SrcDir/resized

=item B<-c Color>

Border color. Default: black

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

gpRatio="16:9"
gpColor="black"
gpSrcDir=""
gpDestDir=""

while getopts :r:s:d:c:hH: tArg; do
    case $tArg in
        # Script arguments
        r) gpRatio="$OPTARG" ;;
        s) gpSrcDir="$OPTARG" ;;
        d) gpDestDir="$OPTARG" ;;
        c) gpColor="$OPTARG" ;;

        # Common arguments
        h)
            fUsage long
            exit 1
            ;;
        H)
            fUsage $OPTARG
            ;;
        # Problem arguments
        :) echo "Error: Value required for option: -$OPTARG"
           fUsage usage
           exit 1
        ;;
        \?) echo "Error: Unknown option: $OPTARG"
            fUsage usage
            exit 1
        ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [[ $# -ne 0 ]]; then
    echo "Error: Unknown option: $*"
    exit 1
fi

# --------------------
# Validate

if [[ -z "$gpSrcDir" ]]; then
    gpSrcDir="."
fi
if [[ ! -d $gpSrcDir ]]; then
    echo "Error: SrcDir $gpSrcDir missing. [$LINENO]"
    exit 1
fi
if [[ ! -r $gpSrcDir ]]; then
    echo "Error: SrcDir $gpSrcDir is not readable. [$LINENO]"
    exit 1
fi

if [[ "$gpSrcDir" = "$gpDestDir" ]]; then
    echo "Error: SrcDir and DestDir must be different. [$LINENO]"
    exit 1
fi

if [[ -z "$gpDestDir" ]]; then
    gpDestDir="$gpSrcDir/resized"
fi
if [[ ! -d "$gpDestDir" ]]; then
    mkdir -p $gpDestDir
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi
if [[ ! -d "$gpDestDir" ]]; then
    echo "Error: DestDir $gpDestDir missing. [$LINENO]"
    exit 1
fi

# --------------------
# Functional section

cd $gpSrcDir
for i in *.jpg; do
    echo
    echo Processing: $gpSrcDir/$i
    tRat=$(jhead $i | grep Resolution | awk '{print int($3/$5)}')
    if [ $tRat -ne 0 ]; then
        ln -vf $i ../$gpDestDir
        continue
    fi
    jhead $i | grep Resolution | awk '{print $0, $3/$5}'
    # x=$3; y=$5
    # x/y=1.35
    # x=1.35 * y
    tSize=$(jhead $i | grep Resolution | awk -v tR=$gpRatio '{tX=int(tR * $5); print tX "x" $5}')
    tCmd="convert $i -resize $tSize -background $gpColor -gravity center -extent $tSize ../$gpDestDir/$i"
    echo $tCmd
    $tCmd
done
