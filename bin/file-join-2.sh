#!/usr/bin/env bash
set -u

# ========================================
# Config

export cName=${BASH_SOURCE##*/}
export gpVerbose=0
export gpDebug=0
export gpSep='--'
export gpOutFile="file-join-out.txt"

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

    $cName will join files together, using the syntax used by
    file-split-2.sh

=head1 SYNOPSIS

    $cName FILE... [-o OutFile] [-s 'Sep'] [-h] [-H pStyle] [-v] [-x]

=head1 DESCRIPTION

One or more FILEs will be joined into OutFile.

=head2 Syntax for FILEs

The input FILE names are "tagged" with: the Sep characters (starting
in column 1), a space, then "file-split:', a space, then the FILE
directory/file name. Then all the text in FILE will be copied to
OutFile.

See EXAMPLE section for sample files and commands.

=head1 OPTIONS

=over 4

=item B<-s 'Sep'>

The split command prefix characters.

Default: '--'

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

=item B<-o OutFile>

Define the output file name.

Default: file-join-out.txt

=item B<-v>

Turn on verbose mode. If there are no errors, nothing will be
output. The OutFile will be quietly created.

=item B<-x>

Turn on debug and verbose mode. Currently nothing extra is output with
-x.

=back

=for comment =head2 Globals
=for comment =head1 RETURN VALUE
=for comment =head1 ERRORS

=head1 EXAMPLES

=head2 Example 1

Input file: foo/bar/readme.html

    line1
    line2

Input file: foo/readme.html

    line3
    line4

Command:

    file-join-2.sh -s '--' -o file2.txt foo/bar/readme.html foo/readme.html

Output file2.txt:

    -- file-split: foo/bar/readme.html
        line1
        line2
    -- file-split: foo/readme.html
        line3
        line4

=head2 Example 2

Input file: foo/example/file2.txt

    line5
    line6

Input file: foo/doc/file3.txt

    line7
    line8

Command:

    file-join-2.sh -s '**' -o file2.org foo/example/file2.txt foo/doc/file3.txt

Output file2.org

    ** file-split: foo/example/file2.txt
        line5
        line6
    ** file-split: foo/doc/file3.txt
        line7
        line8

=head2 Example3

Using the file /tmp/file-split.list to join files that were split with
file-split-2.sh

Command using defaults:

    file-join-2.sh $(cat /tmp/file-split.list)

Output:

file-join-out.txt will be created with the list of file names in
/tmp/file-split.list. The file-split: lines will be prefixed with the
default '--'

=for comment =head1 ENVIRONMENT
=for comment =head1 FILES

=head1 SEE ALSO

file-split-2.sh, file-split, file-join

=for comment =head1 NOTES

=head1 CAVEATS

The OutFile will be overwritten each time file-join-2.sh is run.

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

while getopts :o:s:hHvx: tArg; do
    case $tArg in
        # Script arguments
        o) gpOutFile="$OPTARG" ;;
        s) gpSep="$OPTARG" ;;
        # Common arguments
        h)
            fUsage long
            ;;
        H)
            fUsage $OPTARG
            ;;
        v) ((++gpVerbose)) ;;
        x) ((++gpDebug)) ;;
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

for i in $gpList; do
    if [[ ! -r $i ]]; then
        echo "Error: Could not find or read file: $i $((LINENO))"
        exit 1
    fi
done

# --------------------
# Functional section

rm $gpOutFile 2>/dev/null
touch $gpOutFile
if [[ ! -w $gpOutFile ]]; then
    echo "Error: Problem creating $gpOutFile $((LINENO))"
    exit 1
fi

if [[ $gpVerbose -ne 0 ]]; then
    echo "Creating: $gpOutFile $((LINENO))"
fi
for i in $gpList; do
    if [[ $gpVerbose -ne 0 ]]; then
        echo "Adding file: $i $((LINENO))"
    fi
    echo "$gpSep file-split: $i" >>$gpOutFile
    cat $i >>$gpOutFile
done
