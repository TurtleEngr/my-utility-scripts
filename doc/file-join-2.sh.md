<div>
    <hr/>
</div>

# NAME $cName

    $cName will join files together, using the syntax used by
    file-split-2.sh

# SYNOPSIS

    $cName FILE... [-o OutFile] [-s 'Sep'] [-h] [-H pStyle] [-v] [-x]

# DESCRIPTION

One or more FILEs will be joined into OutFile.

## Syntax for FILEs

The input FILE names are "tagged" with: the Sep characters (starting
in column 1), a space, then "file-split:', a space, then the FILE
directory/file name. Then all the text in FILE will be copied to
OutFile.

See EXAMPLE section for sample files and commands.

# OPTIONS

- **-s 'Sep'**

    The split command prefix characters.

    Default: '--'

- **-h**

    Output this "long" usage help. See "-H long"

- **-H pStyle**

    pStyle is used to select the type of help and how it is formatted.

    Styles:

        short|usage - Output short usage help as text.
        long|text   - Output long usage help as text.
        man         - Output long usage help as a man page.
        html        - Output long usage help as html.
        md          - Output long usage help as markdown.

- **-o OutFile**

    Define the output file name.

    Default: file-join-out.txt

- **-v**

    Turn on verbose mode. If there are no errors, nothing will be
    output. The OutFile will be quietly created.

- **-x**

    Turn on debug and verbose mode. Currently nothing extra is output with
    \-x.

# EXAMPLES

## Example 1

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

## Example 2

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

## Example3

Using the file /tmp/file-split.list to join files that were split with
file-split-2.sh

Command using defaults:

    file-join-2.sh $(cat /tmp/file-split.list)

Output:

file-join-out.txt will be created with the list of file names in
/tmp/file-split.list. The file-split: lines will be prefixed with the
default '--'

# SEE ALSO

file-split-2.sh, file-split, file-join

# CAVEATS

The OutFile will be overwritten each time file-join-2.sh is run.

# HISTORY

GPLv2 (c) Copyright
