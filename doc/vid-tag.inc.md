<div>
    <hr/>
</div>

# NAME vid-tag

Rename video files and set Title, Caption, and Keywords metadata.
And generate thumbnails.

# SYNOPSIS

First run. Create initial config file: `./vid-tag.conf`

    vid-tag -n -e "pEventId" [File1 File2 ...]

Edit vid-tag.conf file, and/or use these options to override, and
define a new config file.

    vid-tag -e "pEventId" File1 [File2 ...]
        [-p "pInitials"] [-P "pName"] [-C "pCaption"] [-R "pCopyright"]
        [-E "pEventTitle"] [-c "pCity"] [-k "pKeyword"]
        [-f "pFilePattern"] [-t "pTitlePattern"]
        [-z "pTimeZone"] [-T]
        [-n] [-h] [-H pStyle] [-v] [-d]

# DESCRIPTION

vid-tag renames one or more video files and writes Title, Caption, and
Keywords metadata using the `exiftool`.  The file's `Create Date`
metadata is read and used to date-time-stamp the output file, and all
the timestamp metadata values.

Files are copied to the ./output/ directory, so the original files are
not changed in any way.

Files (in ./output/) will be renamed using the pFilePattern. Then the
EXIF values will be added to the renamed files.

Because some hosting sites do not allow "large" files, large files,
greater than 10 min, will be split into multiple 10 min parts. The
EXIF time stamps for the split files will update for each 10 min part.

After each run an example file, `./vid-tag-example.txt`, will be
created to show the changes that are (or will be) made to the files
with the current settings. This is best used with the -n option with
all the files to be processed, the time stamps will then match what is
in the files.

If the timestamps for the files are "off" by a consistent amount
the TimeZone (-z) config option can be used to adjust the times.

The config options are read in the following order (each one
overrides the previous values):

- Built-in script defaults.
- Local config: `./vid-tag.conf` If the file does not exist it
will be created with the latest default settings.
- Command-line options will override all other settings.

After all the values are set, the results are saved to
`./vid-tag.conf` so the next run will only need the -e option and the
file list.

## QUICK START

Getting and installing the tool and programs it requires.

### Install

- Download the latest packaged zip file, `vid-tag-VER.zip` from

        https://moria.whyayh.com/rel/released/software/own/vid-tag/

- Unpack the zip file to your "bin" dir.

    Typical choices:

        /usr/local/bin
        $HOME/bin
        /opt/vid-tag

    Just make sure the install dir is in your PATH env. var.

    Install the required programs, see the SEE ALSO section. The script
    will verify the prgrams can be found, in $PATH, before continuing.

### First run of vid-tag

- cd to the directory with your video files (or the directory
where you want ./output/ created).  Copy the `vid-tag.conf` file from
the install dir. This is optional. If the file is missing, a default
version will be created.

        Run: vid-tag -n -e testevent

- That will create or update `./vid-tag.conf` and
`vid-tag-example.txt` files.
- You can now edit the `vid-tag.conf` file, or use the command
line options to update the file. You will want to change "testevent"
to a short ID that will be put in your renamed video files. See the -e
option.

### Tips

- See the -f option for how you can change the file naming
pattern, and the -t option for how you can change the Title pattern.
- Use the -v option to see some progress information. Use -vv if
you want to see more progress details.
- After each run, the `vid-tag.conf` file is updated with any
changes, and the `vid-tag-example.txt` file will summarize how the
files are modified.
- Between each run you should probably remove everything in the
./outputs/ directory. Or you can leave the files there and they will
be skipped from any changes.
- Use the -z option if the file times are off by a consistent
ammount, because you forgot to set the current time with your camera,
or your camera uses UTC times and you want them adjusted to the local
time.

# OPTIONS

- **-e "pEventId"**

    Short event tag used in file names.  If the pEventId is not found,
    then it will be added to `./vid-tag.conf`.

    The value will be changed to lower-case and any spaces will be changed
    to '\_'

    Pattern token: **%e**.  Config var: `Event`. Required: "pEventId"

- **-E "pEventTitle"**

    Long event name used in the title.

    Pattern token: **%E**.  Config var: `Title`. Default: "Long
    event description."

- **-c "pCity"**

    City name.

    Pattern token: **%c**.  Config var: `City`. Default: "city name"

- **-C "pCaption"**

    Caption / description metadata. Any "Pattern Tokens" will be replaced
    in pCaption.

    Config var: `Caption`. Default: "Copyright %P %d"

- **-p "pInitials"**

    Photographer's initials / short name (no spaces).

    Pattern token: **%p**.  Config var: `NameShort`.

- **-P "pName"**

    Photographer's full name.

    Pattern token: **%P**.  Config var: `NameLong`. Default: First
    Last

- **-R "pCopyright"**

    Copyright stamp.  Any "Pattern Tokens" will be replaced in
    pCopyriight.

    Config var: `Copyright` Default: "Copyright %P %d"

- **-f "pFilePattern"**

    Output file-name pattern.  Usually you will only use the lowercase
    pattern options, because they should not have any spaces or special
    characters in them. Also the script might fail if file names have
    spaces in them.

    Config var: `FilePat`. Default: `%d_%e_%p_%f`.

- **-t "pTitlePattern"**

    Title pattern.  Usually you will use the uppercase pattern options,
    but the lowercase options can be used.

    Config var: `TitlePat`. Default: `%D, %c, %E, by %P.`

- **-k "pKeyword"**

    Comma-separated keyword list.

    Config var: `Keyword`. Default: "TBD"

- **-z "pTimeZone"**

    Config var: `TimeZone`.  Default: `local` (no conversion).

    When set to a value other than `local`, each file's CreateDate is
    converted from **pTimeZone** to the host's local time before it is used
    for the output filename, and all the other EXIF time settings.

    Pattern: `UTC[+-]H` or `UTC[+-]H:MM`.  The `UTC` prefix is
    case-insensitive (`utc-1` is accepted).

    Examples:

        -z utc-1     # zone 1 hour ahead of UTC
        -z UTC+8     # zone 8 hours behind UTC
        -z UTC-5:30  # zone 5h30m ahead of UTC
        -z utc-8:03  # your PST time was off by 3 min.
        -z local     # explicit "no conversion"

- **-T**

    Generate thumbnail images for each input video.

    Config var: `Thumb`.  Default: `no`

    The thumbnail is a JPG with the same base name as the renamed video
    file, extracted with ffmpeg from a single frame and then annotated
    text is put in the thumbnail.

    `ThumbTime["FILE"]` in vid-tag.conf can be used to define the time
    for the image that will be extracted.  Otherwise 5 seconds will be
    used.  If the file has an `Extra["FILE"]` title or a
    `ThumbTime["FILE"]` entry, the thumbnail is annotated at the top-left
    with the Extra text, and the extract time will be put after the title.
    A second annotation in the right-center will shows "VIDEO-->".  If a
    file has been split, the number of video files will be put before the
    text. For example: "3 files VIDEO-->".

    The thumbnail's EXIF is copied from the video and its DateTimeOriginal
    / CreateDate / ModifyDate / mtime are set to be one second before the
    video's CreateDate, so it will sort before the video file.

    Config var: `Thumb`. Default: `yes`.

- **-n**

    No-execute / dry-run.  Validate inputs and create config file
    `./vid-tag.conf` and `vid-tag-example.txt`, but do not create
    output/, rename files, or modify metadata.

- **-h**

    Output this "long" usage help.  This is the same as `-H long`.

- **-H pStyle**

    Output usage in a specific style:

        short|usage - short usage, text
        long|text   - full usage, text
        man         - man page
        html        - HTML page
        md          - Markdown
        
        int         - Output internal documentation as text.
        int-html    - Output internal documentation as html.
        int-md      - Output internal documentation as markdown.

- **-v**

    Verbose output.  Repeat for more detail (**-vv**).

        (default) - warnings and errors only
        -v        - notice, warnings, and errors
        -vv       - info, notice, warnings, and errors

- **-V**

    Output the script's version.

- **-d**

    Debug level. Default: 0

    Each -d increments the debug level. Debug messages will be printed
    if the debug level is greater than the debug message's debug level.
    Note: there is very little debug output because the script is best
    tested with `vid-tag.test`.

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

## Config File Format

This is the config file (`./vid-tag.conf`) format.  The file is a
**bash include file**: each line is a bash variable assignment that is
sourced by vid-tag at startup.

    Caption="..."                # pCaption          (-C)
    Copyright="..."              # pCopyright        (-R)
    FilePat="%d_%e_%p_%f"        # pFilePattern      (-f)
    NameLong="..."               # pName             (-P)
    NameShort="..."              # pInitials         (-p)
    TitlePat="%D, %c, %E, by %P." # pTitlePattern    (-t)
    Event="pEventId"             # pEventId          (-e)
    City="..."                   # pCity             (-c)
    Title="..."                  # pEventTitle       (-E)
    Keyword="word, word"         # pKeyword          (-k)
    TimeZone="UTC[+-]H[:MM]"     # pTimeZone         (-z)
    Thumb="yes"                  # pThumb            (-T)
    Extra["FILE1"]="extra title for FILE1"   # optional, per-file
    Extra["FILE2"]="extra title for FILE2"   # ...
    ThumbTime["FILE1"]="MM:SS or HH:MM:SS"   # optional, per-file

The syntax is verified with `bash -n` before the file is sourced.
Note: there should be no spaces around the '=' and all the values
should be between quotes (single ' or double ").

The **Extra** entries are optional.  Each key is the exact name of an
input file. The value is the text that will be appended to that file's
EXIF Title. The Extra text will be put in the thumbnail if -T option.
Files without a matching key are unaffected.

When vid-tag exits, it rewrites `./vid-tag.conf` with the final
effective values (defaults + previous conf + any command-line
overrides), so the next run will only need the file list.

# RETURN VALUE

0 on success; non-zero on error.

# ERRORS

Processing will stop with any of these.

    Missing one or more required programs.
    Syntax error in vid-tag.conf
    Value required for option: -?
    Unknown option: ?
    Directory ? is not writable.
    Missing pEventId, see -e option.
    -t pFilePat is missing % options
    -t pTitlePat is missing % options
    Invalid TimeZone: ? (expected UTC[+-]H[:MM] or 'local')
    No input files given. Use -h for help.
    File not found: ?
    Failed to convert: '?' from TimeZone=?

## Warnings

Processing will continue.

    Missing some some optional programs.
    No CreateDate in ?; using file mtime.
    output/? already exists, skipping.
    ? not found in output/; skipping.
    target exists, skipping: ? -> ?
    exiftool returned error? on ?

# ENVIRONMENT

HOME, USER, PATH

# FILES

## vid-tag-N.N.zip

    vid-tag      - this script
    vid-tag.inc  - vid-tag functions
    vid-tag.conf - sample config file describing tags for an event
    bash-com.inc - utility functions
    LICENSE      - GPLv2

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

Required: bash, exiftool, ffmpeg, convert, sed

Optional: vid-tag.test

# NOTES

All of this code is maintained at:

    https://github.com/TurtleEngr/vid-tag

The releases are marked with vM.m.p tags.

## Standard version numbering scheme

vM.m.p tags.

M - major version number. The program may not work with previous
versions of command line options or config files.

m - minor version number. New features or bug fixes have been added.
It will probably work with previous versions of command line options
or config files, but new features might not work with earlier versions.

p - patch version number. There have only been cosmetic changes. For
example, typos, documentation changes, and there could be some minor
bug fixes.

Any time there is a new "Release," one of these numbers will be
incremented.

Also if you are looking at this on github, the "development" branch is
for newer (maybe untested) versions (where the version number will
likely be different from a released version). The "main" branch is
where the official released code lives, with the vM.m.p tags.

# CAVEATS

This script is mainly for Linux systems. However, if you have CygWin
installed on your Windows PC, and you have install the Required
packages, defined in the SEE ALSO section, and set your PATH env.,
this could work. For MacOS you'll probably want to install "brew" to
get the Required programs.

If you do get this running on Windows or MacOS, please let me know,
with an "issue" report (label it with "enhancement" or
"documentation"). What did you do to get it running? For example
include other programs needed, configuration directions, and any
changes you made to the scripts. If you know github, fork the vid-tag
repo, add your changes, then send me a "pull" request, to the
"develop" branch.

# DIAGNOSTICS

This tool comes with a test script to verify the vid-tag script is
working OK.  Download these files from:
https://moria.whyayh.com/rel/released/software/own/vid-tag/
(the VER should match vid-tag's VER):

    vid-tag-test-VER.zip
    vid-tag-test-input.zip (4.5G) - optional

Unzip vid-tag-test-VER.zip to the install dir.

Unzip vid-tag-test-input.zip to a "test" directory. In the test
directory run:

    ./vid-tag.test -T all

If you don't have space for the vid-tag-test-input.zip files, just use
the "fast" test option for vid-tag.test. For example:

    vid-tag.test -T fast

# BUGS

Report bugs at: https://github.com/TurtleEngr/vid-tag/issues

Always include the version number of the script you were using.  And
include complete error messages you see.

# AUTHOR

Turtle Engineer

# HISTORY

GPLv2 (c) Copyright (See LICENSE file for terms.)

cVer=2.3.2
