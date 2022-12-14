# NAME

outline2html.pl - Simple outline tagging

# SYNOPSIS

    outline2html.pl [-weight P|B|H] [-style P|N|R] [-trim] [-help] [Files] 

# DESCRIPTION

A simple text file is converted to a html file.

- Define the title and the H1 head with a line like this a the
beginning of the file (no \[\]).

        TITLE: [this is the title]

- Outline headings begin with leading a '\*'
- The first outline level will be formatted according to the
-weight and -style options
- The number of "TABs" define the outline level.
- After the first level, the levels will be ordered lists with
upper case letters, numbers, lower case letters, numbers, then repeat.
- Lines that don't begin with an '\*' are included as plain
paragraphs at the current level.
- Line breaks end a paragraph or item level.
- Blank lines are ignored.
- Lines beginning with a '#' are ignored.

# OPTIONS

- **-w\[eight\] P|B|H**

    For first level items, define the weight.
    P - plain; B - bold; H - H2

    Default: -weight B

- **-s\[tyle\] P|N|R**

    For first level items, define the outline style.
    P - plain, no numbers; N - Arabic numbers; R - Roman numbers

    Default: -style R

- **-t\[rim\]**

    If the -trim option is defined, then lines that don't begin with a '\*'
    will be trimmed from the output.

- **-h\[elp\]**

    This help.

# EXAMPLES

    outline2html.pl <outline.txt | \
        tidy -q -i -w 78 -asxhtml --tidy-mark no --vertical-space no >outline.html

    outline2html.pl -t outline.txt | \
        tidy -q -i -w 78 -asxhtml --tidy-mark no --vertical-space no >outline-long.html

$Revision: 1.3 $
