<div>
    <hr/>
</div>

# NAME $cName

    $cName will split the content of one or more files into separate files.

# SYNOPSIS

    $cName FILE... [-s 'Sep'] [-h] [-H pStyle] [-v] [-x]

# DESCRIPTION

One or more FILEs will be split into separate files.

## Syntax for FILEs

The output file names in FILE(s) are "tagged" with: the Sep characters
(starting in column 1), one or more spaces, then "file-split:', one or
more spaces, then the directory/file name. All the text following that
line will be put in file "directory/file"

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

- **-v**

    Turn on verbose mode. If there are no errors, nothing will be
    output. The files will be quietly created.

- **-x**

    Turn on debug and verbose mode. Currently nothing extra is output with
    \-x.

# EXAMPLES

## Input Files

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

## Command

    file-split-2.sh -s '--' file1.txt
    file-split-2.sh -s '**' file2.org

## Output Dirs/Files

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

# SEE ALSO

file-join-2.sh, file-split, file-join

All text before the first "file-split:" line will be ignored. So if
you use file-join-2.sh that text will be missing.

# HISTORY

GPLv2 (c) Copyright
