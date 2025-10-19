#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/vid-rename.sh,v 1.8 2025/10/19 22:53:31 bruce Exp $
set -u

# ========================================
# Config
export cName=vid-rename.sh
export gpTZ=UTC

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

    $cName [-h] - usage help
    $cName FILE... - Rename all FILES with exif data.
    $cName DIR - Rename all files with exif data in DIR.
    $cName . - Rename all files with exif data in current dir.

    Options:
    [-u] - UTC time
    [-p] - PST time
    [-d] - PDT time

=head1 DESCRIPTION

From the exfi data in the file, rename the files to:

    YYYY-MM-DD/
        YYYY-MM-DD_HHMMSS_TZ.mp4

The files will be renamed and moved. So backup or "ln" the files
before running this.

=head1 OPTIONS

=over 4

=item B<-u>

The HHMMSS will be UTC time. This is the default.

=item B<-p>

The HHMMSS will be PST time.

=item B<-d>

The HHMMSS will be PDT time.

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

while getopts :dpuhH: tArg; do
    case $tArg in
        # Script arguments
        d) gpTZ=PDT ;;
        p) gpTZ=PST ;;
        u) gpTZ=UTC ;;
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
    gpList="$*"
fi
while [[ $# -ne 0 ]]; do
    shift
done

# --------------------
# Validate section

if [[ -z "$gpList" ]]; then
    echo "Error: Missing file or dir names [$LINENO]"
    fUsage usage
fi

for i in $gpList; do
    if [[ ! -e $i ]]; then
        echo "Error: $i does not exist [$LINENO]"
        fUsage usage
    fi
done

# --------------------
# Functional section

case $gpTZ in
    UTC) exiftool '-FileName<CreateDate' -d %Y-%m-%d/%Y-%m-%d_%H%M%S_UTC.mp4 $gpList ;;
    PDT) exiftool '-FileName<${CreateDate;DateFmt("%Y-%m-%d/%Y-%m-%d_%H%M%S_PDT.mp4");$_=ConvertTime($_,"-07:00")}' -api QuickTimeUTC $gpList ;;
    PST) exiftool '-FileName<${CreateDate;DateFmt("%Y-%m-%d/%Y-%m-%d_%H%M%S_PST.mp4");$_=ConvertTime($_,"-08:00")}' -api QuickTimeUTC $gpList ;;
esac

exit $?
