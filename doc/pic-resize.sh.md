<div>
    <hr/>
</div>

# NAME $cName

    Resize jpg image aspect ratio

# SYNOPSIS

    $cName [-r Ratio] [-s SrcDir] [-d DestDir] [-c Color] [-h] [-H Style]

# DESCRIPTION

Resize all jpg images in SrcDir to have aspect set to Ratio. The new
image is put in DestDir (with the same name). If the image is already
had aspect equal to Ratio, a hard link is made from SrcDir to DestDir.

The image will be centered and the vertical or horizonal borders will
be added with the specified Color to make the image fit the specified
Ratio.

# OPTIONS

- **-r Ratio**

    Ratio format is X:Y. Default: 16:9

- **-s SrcDir**

    Source directory. Default: .

- **-d DestDir**

    Destination directory. Default: SrcDir/resized

- **-c Color**

    Border color. Default: black

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
