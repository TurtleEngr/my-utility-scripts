<div>
    <hr/>
</div>

# NAME $cName

Change the aspect ratio of input image. Add boarders as needed.

# SYNOPSIS

    $cName FILE.jpg... [-i] [-f] [-v] [-h] [-H pStyle]
        [-a pType] or [-A X:Y]
        [-x pMaxX] or [-y pMaxY]
        [-c pColor]
        [-p pPlace]

    pType = std, tv, wide,  cell, tall, narrow
    pPlace = center, left, right, top, bottom

# DESCRIPTION

Change the aspect ratio of the listed files.

# OPTIONS

- **FILE.jpg...**

    One or more input file names.

    Output files will have '-fit" added to the input file name.  For
    example FILE-fit.jpg

- **-i**

    Information about the list of files. Uses jhead.

- **-f**

    If not set, any output files will need be moved or removed.
    If this is set, the output files will be overwritten.

- **-a pType**
    - **std** - 16:9  (default)
    - **tv** - 4:3
    - **wide** - 3:2
    - **cell** - 9:16
    - **tall** - 3:4
    - **narrow** - 2:3
- **-A X:Y**
Custom aspect ratio. Only one of -a or -A can be defined.
- **-x pMaxX**

    Max X width. Given pMaxX and the aspect ratio, solve for Y.  Can only
    have -x or -y not both (last one difined, wins).

    Default: 1920

- **-y pMaxY**

    Max Y height.  Given pMaxY and the aspect ratio, solve for X.  Can
    only have -x or -y not both (last one difined, wins).

- **-c pColor**

    Border color. Default: black

    If using #RRGGBB code for the color, include it in quotes.

- **-p pPlace**
    - **center**
     (center)
    - **left**
     (west)
    - **right**
     (east)
    - **top**
     (north)
    - **bottom**
    (south)
- **-v**

    Verbose.

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

# SEE ALSO

convert, jhead, pdf2jpg

# HISTORY

GPLv2 (c) Copyright
