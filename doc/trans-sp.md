<div>
    <hr/>
</div>

# NAME $cName

Rename files to have "safe" and consistent names.

# SYNOPSIS

    $cName [-c] [-a] [-f FILENAME...] [-L] [-h] [-H pStyle]

# DESCRIPTION

Translate all file/dir names with special characters to use '\_'
Valid file/dir names \[\_-.a-zA-Z0-9\].

At least one option, -c, -a, or -f is required.

The renamed files (old,new) are listed in: trans-sp\_LOG.csv

# OPTIONS

- **-a**

    Translate all files and dirs in current dir on down.

- **-c**

    Only translate all files in current dir.

- **-f FILENAME...**

    Translate only the listed files.

- **-L**

    Translate uppercase in names to lowercase.

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

# FILES

trans-sp\_LOG.csv

# HISTORY

GPLv2 (c) Copyright
