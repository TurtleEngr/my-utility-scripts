#!/usr/bin/env bash
set -u

# ========================================
# Config

export cName=${BASH_SOURCE##*/}
export gpVerbose=0
export gpDebug=0
export gpSep='--'

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

    $cName will split the content of one or more files into separate files.

=head1 SYNOPSIS

    $cName FILE... [-s 'Sep'] [-h] [-H pStyle] [-v] [-x]

=head1 DESCRIPTION

One or more FILEs will be split into separate files.

=head2 Syntax for FILEs

The output file names in FILE(s) are "tagged" with: the Sep characters
(starting in column 1), one or more spaces, then "file-split:', one or
more spaces, then the directory/file name. All the text following that
line will be put in file "directory/file"

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

=item B<-v>

Turn on verbose mode. If there are no errors, nothing will be
output. The files will be quietly created.

=item B<-x>

Turn on debug and verbose mode. Currently nothing extra is output with
-x.

=back

=for comment =head2 Globals
=for comment =head1 RETURN VALUE
=for comment =head1 ERRORS

=head1 EXAMPLES

=head2 Input Files

Example input file: file1.txt

    --  file-split: foo/bar/readme.html
    line1
    line2
    -- file-split: foo/readme.html
    line3
    line4

Example input file: file2.org

    ** file-split: foo/example/file2.txt
    line5
    line6
    ** file-split: foo/doc/file3.txt
    line7
    line8

=head2 Command

    file-split-2.sh -s '--' file1.txt
    file-split-2.sh -s '**' file2.org

=head2 Output Dirs/Files

    foo/bar/readme.html
        line1
        line2
    foo/readme.html
        line3
        line4
    foo/example/file2.txt
        line5
        line6
    foo/doc/file3.txt
        line7
        line8

=for comment =head1 ENVIRONMENT
=for comment =head1 FILES

=head1 SEE ALSO

file-join-2.sh, file-split, file-join

=for comment =head1 NOTES
=head1 CAVEATS

All text before the first "file-split:" line will be ignored. So if
you use file-join-2.sh that text will be missing.

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

while getopts :s:hHvx: tArg; do
    case $tArg in
        # Script arguments
        s) gpSep="$OPTARG" ;;
        # Common arguments
        h)
            fUsage long
            ;;
        H)
            fUsage $OPTARG
            ;;
        v) ((++gpVerbose)) ;;
        x)
            ((++gpDebug))
            ((++gpVerbose))
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

for i in $gpList; do
    if [[ ! -r $i ]]; then
        echo "Error: Could not find or read file: $i $((LINENO))"
        exit 1
    fi
done

# --------------------
# Functional section

for i in $gpList; do
    tOutFile=/dev/null
    cat $i | while read tLine; do
        read tPre tCmd tDirFile tExtra <<<$tLine
        if [[ "$tPre" = "$gpSep" && "$tCmd" = "file-split:" && -n $tDirFile ]]; then
            tOutFile=$tDirFile
            tDir=$(dirname $tDirFile)
            if [[ ! -d $tDir ]]; then
                mkdir -p $tDir
            fi
            rm $tOutFile 2>/dev/null
            if [[ $gpVerbose -ne 0 ]]; then
                echo "Creating: $tOutFile [$LINENO]"
            fi
            continue
        fi
        echo "$tLine" >>$tOutFile
    done
done
