<div>
    <hr/>
</div>

# NAME org2html.sh

Comvert FILE.org to FILE.html

# SYNOPSIS

    org2html.sh [-s N] InFile.org [OutFile.html]
    org2html.sh -i InFile.org [-o OutFile.html] [-s N] 
    org2html.sh [-h] [-H pStyle]

# DESCRIPTION

FILE.org will be converted to FILE.html. It has some fixes to the
"pandoc" conversion.

If the outputfile (FILE.html) is missing, then the InFile.org base
name will be used for the html file.

The -s option can be used to put hr tags in the output.

Before org2html.sh is run, all files in $Tmp are removed, unless
env. var. gpDebug is set and not 0.

See the SEE ALSO section for the required programs.

## Replacements

    '+ ' - will be changed to <li>
    '- ' - will be regular paragraphs
           Also blank lines separate paragraphs
    '**** ' - will be replaced with <h4> (similarly for 5 and 6 *)
    '{.*}' - will be replaced with <cite>.*</cite>
    '[TBD.*] - will be replaced with <span class="tbd">[TBD.*]</span>
    '[TK.*] - will be replaced with <span class="tbd">[TK.*]</span>

# OPTIONS

- **-i FILE.org**

    Input file. Required.

- **-o FILE.html**

    Output file. Default, if not specfied the extension will be removed
    from the input file and ".html" will be appended.

- **-s N**

    For N = 1 to 3, a hr tag will be put before heading levels N or lower.
    Default: 0

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

If no options, file order matters.

    org2html test.org test.html

Use the -i and -o options

    org2html -o test.html -i test.org

Output file will default to test.html

    org2html -i test.org

# ENVIRONMENT

    Tmp - if not set, set it to: /tmp/$USER/org2html.sh"}
    gpDebug - if set not equal to 0, all files in $Tmp will be removed

# SEE ALSO

    pandoc
    perl
    pod2html - perl pkg
    pod2man - perl pkg
    pod2markdown - libpod-markdown-perl pkg
    pod2pdf
    pod2text - perl pkg
    pod2usage - perl pkg
    sed
    tidy

# HISTORY

GPLv2 (c) Copyright
