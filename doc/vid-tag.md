<div>
    <hr/>
</div>

# NAME vid-tag

Rename video files and set Title / Caption / Keywords metadata.

# SYNOPSIS

First run. Create config file: ./vid-tag.conf

    vid-tag -n -e "pEventId"

Edit config files, and/or use these options to override config file.

    vid-tag -e "pEventId" File1 [File2 ...]
        [-p "pInitials"] [-P "pName"] [-C "pCaption"] [-R "pCopyright"]
        [-E "pEventTitle"] [-c "pCity"] [-k "pKeyword"]
        [-f "pFilePattern"] [-t "pTitlePattern"] [-x "pExtra"]
        [-n] [-h] [-H pStyle] [-v] [-d]

# DESCRIPTION

vid-tag renames one or more video files and writes Title, Caption, and
Keywords metadata using **exiftool**.  The file's **Create Date** metadata
is read and used to date-stamp the output file name, the output title,
and the file-system mtime.

An example file, ./vid-tag-example.txt, will be created to show the
changes to the file with the current settings. This is best used with
the -n option and include all the files, so the time stamps will match
what is in the files.

Files are copied to the ./output/ directory, so original files are
not touched.

Files (in ./output/) will be renamed using fFilePattern and the exif
values will be added.

Large files, greater than 10 min, will be split into multiple 10 min
parts (because some hosting sites do not allow "large" files). The
exif time stamps for the split files will update for each 10 min part.

Defaults are read in this order (each layer overrides the previous):

- Built-in script defaults.
- Local config: **./vid-tag.conf** If the file does not exist it
will be created, and updated with the latest default settings.
- Command-line options will override all other settings.

After all the values are set, the results are saved to
**./vid-tag.conf** so the next run needs only needs the -e option and
the file list.

## QUICK START

### Install

- Download the latest packaged zip file, vid-tag-VER.zip
- The package can be found at:

        https://moria.whyayh.com/rel/released/software/own/vid-tag/

- Unpack the zip file to your "bin" dir.

    Typical choices:

        /usr/local/bin
        $HOME/bin
        /opt/vid-tag

    Just make sure the install dir is in your PATH env. var.

### First run of vid-tag

- cd to the directory with your video files. Copy the vid-tag.conf
file from the install dir. This is optional. If missing a default
version will be created.

        Run: vid-tag -n -e testevent

- That will create or update ./vid-tag.conf and vid-tag-example.txt
files.
- You can now edit the vid-tag.conf file, or use the command line
options to update the file. Mainly you want to change "testevent" to a
short ID that will be put in your renamed video files. See the -e
option.

### Tips

- See the -f option for how you can change the file naming
pattern, and the -t option for how you can change the Title pattern.
- After each run, the vid-tag.conf file is updated with any
changes, and the vid-tag-example.txt file will summarize how the files
are modified.
- Between each run you should remove everything in the outputs/
directory.  Your orginal files will not be modified.

# OPTIONS

- **-e "pEventId"**

    Short event tag used in file names. It is also the Id used to access
    the specific event details. If the pEventId is not found in
    vid-tag.conf, then it will be added to vid-tag.conf.

    Pattern token: **%e**.  Config key: `event.tag`. Required: "pEventId"

    The value will be changed to lower-case and any spaces will be changed
    to '\_'

- **-E "pEventTitle"**

    Long event name used in the title.  Pattern token: **%E**.
    Config key: `event.title`. Default: "Long event description."

- **-c "pCity"**

    City name.  Pattern token: **%c**.  Config key: `event.city`. Default:
    "city name"

- **-C "pCaption"**

    Caption / description metadata.  Config key: `com.caption`. Default:
    "Copyright TERMS"

- **-p "pInitials"**

    Photographer's initials / short name (no spaces).  Pattern token: **%p**.
    Config key: `com.name-short`.

- **-P "pName"**

    Photographer's full name.  Pattern token: **%P**.
    Config key: `com.name-long`. Default: First Last

- **-R "pCopyright"**

    Copyright stamp. Config key: `com.copyright` Default: "Copyright NAME YYYY"

- **-f "pFilePattern"**

    Output file-name pattern.  Config key: `com.file-pat`. Default:
    `%d_%e_%p_%f`.

- **-t "pTitlePattern"**

    Title pattern. Config key: `com.title-pat`. Default: `%D, %c, %E, by %P.`

- **-k "pKeyword"**

    Comma-separated keyword list.  Config key: `event.keyword`. Default:
    "PBP, event"

- **-x "pExtra"**

    If non-empty, appended to the generated title.
    Config key: `event.extra`.

    When setting, include a leading space and an ending '.'

- **-n**

    No-execute / dry-run.  Validate inputs and create config file
    **./vid-tag.conf**, but do not create output/, rename files, or modify
    metadata.

- **-h**

    Output this "long" usage help.  Same as `-H long`.

- **-H pStyle**

    Output usage in a specific style:

        short|usage - short usage, text
        long|text   - full usage, text
        man         - man page
        html        - HTML page
        md          - Markdown

- **-v**

    Verbose output.  Repeat for more detail (**-vv**).

        (default) - warning and above
        -v        - notice and above
        -vv       - info and above

- **-V**

    Output the script's version.

- **-d**

    Debug level. Default: 0
    Each -d increments the debug level. Log messages will be print
    if the debug level is greater than the log message's debug level.

## Pattern Tokens

    %c   city name            (-c)
    %d   file date short      "YYYY-MM-DD"
    %D   file date long       "YYYY-MM-DD WWW"
    %T   file date full       "YYYY-MM-DD_HH:MM:SS"
    %e   event short          (-e)
    %E   event long           (-E)
    %f   original file name   (path stripped)
    %p   photographer short   (-p)
    %P   photographer long    (-P)
    %x   extra title          (-x)

## Config File Format

This is the config file (`./vid-tag.conf`) format.
The value of `$gpEventId` is the primary key.

    [vid-tag "com"]
        file-pat   = %d_%e_%p_%f (pFilePatern)
        title-pat  = %D, %c, %E, by %P. (pTitlePattern)
        name-long  = Photographer Name (pName)
        name-short = Initials (pInitial)
        copyright  = pCopyright
        caption    = pCaption
    [vid-tag "pEventId"]
        title      = Long Event Title (pEventTitle)
        city       = pCity
        keyword    = word, word (pKeyword)
        extra      = Second sentence for title. (pExtra) - optional

extra - is optional, but if defined, it must end with a '.'

# RETURN VALUE

0 on success; non-zero on error.

# ERRORS

    + No input files given.
    + exiftool is not installed or not on PATH.
    + File not found: <filename>

Warnings (processing continues):

    + No CreateDate in <file>; using file mtime
    + output/<file> already exists
    + target exists, skipping: <old> -> <new>
    + exiftool returned error on <file>

# ENVIRONMENT

HOME, USER, Tmp, gpVerbose, gpDebug, gpConfLocal

# FILES

## vid-tag-N.N.zip

    vid-tag      - this script
    vid-tag.inc  - vid-tag functions
    vid-tag.conf - sample config file describing tags for an event
    bash-com.inc - utility functions
    LICENSE      - GPLv2

    ./vid-tag-example.txt - lists the changes to files
    ./output/      - generated directory, with renamed copies of files

## Generated files

    vid-tag.conf - if missing, it will be created with defaults and CLI args
    vid-tag-example.txt - lists the changes to files based on vid-tag.conf
    output/      - generated directory, with renamed copies of files

## vid-tag-test-N.N.zip

This package is for testing the vid-tag script. See the NOTES section

    vid-tag.test - optional unit and CLI integration tests
    shunit2.1    - unit test framework for vid-tag.test

## vid-tag-test-input.zip (4.5G)

Optional video files used by vid-tag.test. Only needed for
the testCli\*Slow tests. 

    MVI_0107.MP4
    MVI_0110.MP4
    MVI_0746.MP4

# SEE ALSO

Required: Linux OS (see CAVEATS for Windows and MacOS)

Required: bash, exiftool, git config, ffmpeg, sed

Optional: vid-tag.test

# NOTES

All of this code is maintained at:

    https://github.com/TurtleEngr/vid-tag

The releases are marked with vN.N tags.

# CAVEATS

This script is mainly for Linux systems. However, if you have CygWin
installed on your Windows PC, and you have install the Required
packages (and set your PATH env.) this could work. For MacOS you'll
probably want to install "brew" to get the Required programs.

If you do get this running on Windows or MacOS, let me know, with an
"issue" report, what you had to do to get it running. For example
include programs needed, configuration directions, and any changes
you made to the scripts.

# DIAGNOSTICS

This tool comes with a test script to verify vid-tag script is working
OK.  Download these files:

    vid-tag-test-VER.zip
    vid-tag-test-input.zip (4.5G)

from: https://moria.whyayh.com/rel/released/software/own/vid-tag/

Unzip vid-tag-test-VER.zip to the install dir.

Unzip vid-tag-test-input.zip to a "test" directory. In the test
directory run vid-tag.test.

If you don't have space for the vid-tag-test-input.zip files, just use
the "fast" test option for vid-tag.test. For example:

    vid-tag.test -T fast

# BUGS

Report bugs at: https://github.com/TurtleEngr/vid-tag/issues

# AUTHOR

Turtle Engineer

# HISTORY

GPLv2 (c) Copyright (See LICENSE file for terms.)

cVer=1.2.2
