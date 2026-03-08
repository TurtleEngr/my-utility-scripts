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

## Input Files

Example input file: foo/bar/readme.html

    line1
    line2

Example input file: foo/readme.html

    line3
    line4

Example input file: foo/example/file2.txt

    line5
    line6

Example input file: foo/doc/file3.txt

    line7
    line8

## Command

    file-join-2.sh -s '--' -o file2.txt foo/bar/readme.html foo/readme.html
    file-join-2.sh -s '**' -o file2.org foo/example/file2.txt foo/doc/file3.txt

## Output file2.txt

    -- file-split: foo/bar/readme.html
        line1
        line2
    -- file-split: foo/readme.html
        line3
        line4

## Output file22.org

    ** file-split: foo/example/file2.txt
        line5
        line6
    ** file-split: foo/doc/file3.txt
        line7
        line8

# SEE ALSO

file-split-2.sh, file-split, file-join

# HISTORY

GPLv2 (c) Copyright
