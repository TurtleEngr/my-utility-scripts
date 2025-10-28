<div>
    <hr/>
</div>

# NAME $cName

SHORT-DESCRIPTION

# SYNOPSIS

    $cName [-h] - usage help
    $cName FILE... - Rename all FILES with exif data.
    $cName DIR - Rename all files with exif data in DIR.
    $cName . - Rename all files with exif data in current dir.

    Options:
    [-u] - UTC time
    [-p] - PST time
    [-d] - PDT time

# DESCRIPTION

From the exfi data in the file, rename the files to:

    YYYY-MM-DD/
        YYYY-MM-DD_HHMMSS_TZ.mp4

The files will be renamed and moved. So backup or "ln" the files
before running this.

# OPTIONS

- **-u**

    The HHMMSS will be UTC time. This is the default.

- **-p**

    The HHMMSS will be PST time.

- **-d**

    The HHMMSS will be PDT time.

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

# HISTORY

GPLv2 (c) Copyright
