<div>
    <hr/>
</div>

# NAME $cName

Restore an existing video project.

# SYNOPSIS

    $cName -n ProjName [-t TopDir] [-e ExternalDir]
           [-h] [-H pStyle]
    Defaults:
    -t TopDir = $gpTopDir
    -e ExternalDir = $gpExtRepo

# DESCRIPTION

Restore an existing project (-n ProjName) from -e
ExternalDir/ProjName.cvs If .symlink file exists, the raw symlink will
be defined.

# OPTIONS

- **-n ProjName**

    Name of an existing project. Required option.

- **-t TopDir**

    Top directory for the project.  Default: $gpTopDir

- **-e ExternalDir**

    Top external directory for the cvs and raw files.  Default: $gpExtRepo

    The external project cvs dir will be: $gpExtRepo/ProjName.cvs

    The external project raw dir will be: $gpExtRepo/ProjName.raw

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

vid-new-proj.sh

# NOTES

\-e ExternalDir is usually a mounted drive.

# HISTORY

\\$Revision: 1.1 $  \\$Date: 2026/04/10 18:43:59 $ GMT

GPLv2 (c) Copyright
