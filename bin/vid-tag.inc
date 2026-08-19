#!/bin/bash
set -u

export cVer=2.3.5
export cBin
export cExampleFile
export cOutputDir

# Internal globals
export gFile
export gFileDate
export gFileDateFull
export gFileDateLong
export gFileDateShort
export gFileDateTouch

# External globals (set externally or by cmd line options)
declare -lx gpEventId
export gpCaption
export gpConfLocal
export gpCopyright
export gpDebug
export gpEventCity
export gpEventFileList
export gpEventKeyword
export gpEventTitle
export gpFilePat
export gpNameLong
export gpNameShort
export gpNoExec
export gpThumb
export gpTimeZone
export gpTitlePat

# Captured command line for the example file.  Set in vid-tag main.
export gpCmdLine

# Per-file collection arrays used by fExample.  Indexed by gExampleIdx.
declare -ag gExampleOrigNames
declare -ag gExampleNewNames
declare -ag gExampleTitles
declare -ag gExampleCreateDates
declare -ig gExampleIdx

# Per-file extra-title map populated by fLoadConf from "Extra[...]"
# bash array assignments in $gpConfLocal.  Keys are file basenames
# (exact, case-sensitive); values are the text appended to the EXIF
# Title for matching files.
declare -Ag gExtraMap

# Per-file thumbnail-time map populated by fLoadConf from "ThumbTime[...]"
# bash array assignments in $gpConfLocal.  Keys are file basenames
# (exact, case-sensitive); values are the timestamp (e.g. "00:02:43" or
# "5:01") passed to ffmpeg -ss when extracting the thumbnail image.
declare -Ag gThumbMap

# ========================================
# Script Functions

# --------------------------------
fUsage() {
    # Quick help, run this:
    # vid-tag -h
    local pStyle="$1"

    case $pStyle in
        short | usage | man | long | text | md)
            fComUsage -f $cBin/$cName.inc -s $pStyle | more
            ;;
        html)
            fComUsage -f $cBin/$cName.inc -s $pStyle -t "$cName Usage"
            ;;
        int)
            fComUsage -i -f $cBin/$cName.inc -f $cBin/$cName.test -f $cBin/bash-com.inc -f $cBin/bash-com.test -s long | more
            ;;
        int-html)
            fComUsage -i -f $cBin/$cName.inc -f $cBin/$cName.test -f $cBin/bash-com.inc -f $cBin/bash-com.test -s html -t "$cName Internal Doc"
            ;;
        int-md)
            fComUsage -i -f $cBin/$cName.inc -f $cBin/$cName.test -f $cBin/bash-com.inc -f $cBin/bash-com.test -s md
            ;;
        *)
            fComUsage -f $cBin/$cName.inc -s usage
            ;;
    esac
    fCleanUp

    # POD Syntax: https://perldoc.perl.org/perlpod
    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=pod

=for text ========================================

=for html <hr/>

=head1 NAME vid-tag

Rename video files and set Title, Caption, and Keywords metadata.
And generate thumbnails.

=begin html

<p>
<a href="https://github.com/TurtleEngr/vid-tag/actions/workflows/test.yml"><img src="https://github.com/TurtleEngr/vid-tag/actions/workflows/test.yml/badge.svg" alt="test" title="" /></a>
<a href="https://github.com/TurtleEngr/vid-tag/tags"><img src="https://img.shields.io/github/v/tag/TurtleEngr/vid-tag?label=release-tag" alt="Tag" title=""/></a>
<a href="https://github.com/TurtleEngr/vid-tag/issues"><img src="https://img.shields.io/github/issues-search?query=repo%3ATurtleEngr%2Fvid-tag%20is%3Aopen&amp;style=flat&amp;label=issues"/></a>
<a href="https://github.com/TurtleEngr/vid-tag/blob/develop/LICENSE"><img src="https://img.shields.io/github/license/TurtleEngr/vid-tag"/></a>
</p>

=end html

=head1 SYNOPSIS

First run. Create initial config file: F<./vid-tag.conf>

    vid-tag -n -e "pEventId" [File1 File2 ...]

Edit vid-tag.conf file, and/or use these options to override, and
define a new config file.

    vid-tag -e "pEventId" File1 [File2 ...]
        [-p "pInitials"] [-P "pName"] [-C "pCaption"] [-R "pCopyright"]
        [-E "pEventTitle"] [-c "pCity"] [-k "pKeyword"]
        [-f "pFilePattern"] [-t "pTitlePattern"]
        [-z "pTimeZone"] [-T]
        [-n] [-h] [-H pStyle] [-v] [-d]

=head1 DESCRIPTION

vid-tag renames one or more video files and writes Title, Caption, and
Keywords metadata using the C<exiftool>.  The file's C<Create Date>
metadata is read and used to date-time-stamp the output file, and all
the timestamp metadata values.

Files are copied to the ./output/ directory, so the original files are
not changed in any way.

Files (in ./output/) will be renamed using the pFilePattern. Then the
EXIF values will be added to the renamed files.

Because some hosting sites do not allow "large" files, large files,
greater than 10 min, will be split into multiple 10 min parts. The
EXIF time stamps for the split files will update for each 10 min part.

After each run an example file, F<./vid-tag-example.txt>, will be
created to show the changes that are (or will be) made to the files
with the current settings. This is best used with the -n option with
all the files to be processed, the time stamps will then match what is
in the files.

If the timestamps for the files are "off" by a consistent amount
the TimeZone (-z) config option can be used to adjust the times.

The config options are read in the following order (each one
overrides the previous values):

=over 4

=item Built-in script defaults.

=item Local config: F<./vid-tag.conf> If the file does not exist it
will be created with the latest default settings.

=item Command-line options will override all other settings.

=back

After all the values are set, the results are saved to
F<./vid-tag.conf> so the next run will only need the -e option and the
file list.

=head2 QUICK START

Getting and installing the tool and programs it requires.

=head3 Install

=over 4

=item Download the latest packaged zip file, C<vid-tag-VER.zip> from

    https://moria.whyayh.com/rel/released/software/own/vid-tag/

=item Unpack the zip file to your "bin" dir.

Typical choices:

    /usr/local/bin
    $HOME/bin
    /opt/vid-tag

Just make sure the install dir is in your PATH env. var.

Install the required programs, see the SEE ALSO section. The script
will verify the prgrams can be found, in $PATH, before continuing.

=back

=head3 First run of vid-tag

=over 4

=item cd to the directory with your video files (or the directory
where you want ./output/ created).  Copy the F<vid-tag.conf> file from
the install dir. This is optional. If the file is missing, a default
version will be created.

    Run: vid-tag -n -e testevent

=item That will create or update F<./vid-tag.conf> and
F<vid-tag-example.txt> files.

=item You can now edit the F<vid-tag.conf> file, or use the command
line options to update the file. You will want to change "testevent"
to a short ID that will be put in your renamed video files. See the -e
option.

=back

=head3 Tips

=over 4

=item See the -f option for how you can change the file naming
pattern, and the -t option for how you can change the Title pattern.

=item Use the -v option to see some progress information. Use -vv if
you want to see more progress details.

=item After each run, the F<vid-tag.conf> file is updated with any
changes, and the F<vid-tag-example.txt> file will summarize how the
files are modified.

=item Between each run you should probably remove everything in the
./outputs/ directory. Or you can leave the files there and they will
be skipped from any changes.

=item Use the -z option if the file times are off by a consistent
ammount, because you forgot to set the current time with your camera,
or your camera uses UTC times and you want them adjusted to the local
time.

=back

=head1 OPTIONS

=over 4

=item B<-e "pEventId">

Short event tag used in file names.  If the pEventId is not found,
then it will be added to F<./vid-tag.conf>.

The value will be changed to lower-case and any spaces will be changed
to '_'

Pattern token: B<%e>.  Config var: C<Event>. Required: "pEventId"

=item B<-E "pEventTitle">

Long event name used in the title.

Pattern token: B<%E>.  Config var: C<Title>. Default: "Long
event description."

=item B<-c "pCity">

City name.

Pattern token: B<%c>.  Config var: C<City>. Default: "city name"

=item B<-C "pCaption">

Caption / description metadata. Any "Pattern Tokens" will be replaced
in pCaption.

Config var: C<Caption>. Default: "Copyright %P %d"

=item B<-p "pInitials">

Photographer's initials / short name (no spaces).

Pattern token: B<%p>.  Config var: C<NameShort>.

=item B<-P "pName">

Photographer's full name.

Pattern token: B<%P>.  Config var: C<NameLong>. Default: First
Last

=item B<-R "pCopyright">

Copyright stamp.  Any "Pattern Tokens" will be replaced in
pCopyriight.

Config var: C<Copyright> Default: "Copyright %P %d"

=item B<-f "pFilePattern">

Output file-name pattern.  Usually you will only use the lowercase
pattern options, because they should not have any spaces or special
characters in them. Also the script might fail if file names have
spaces in them.

Config var: C<FilePat>. Default: C<%d_%e_%p_%f>.

=item B<-t "pTitlePattern">

Title pattern.  Usually you will use the uppercase pattern options,
but the lowercase options can be used.

Config var: C<TitlePat>. Default: C<%D, %c, %E, by %P.>

=item B<-k "pKeyword">

Comma-separated keyword list.

Config var: C<Keyword>. Default: "TBD"

=item B<-z "pTimeZone">

Config var: C<TimeZone>.  Default: C<local> (no conversion).

When set to a value other than C<local>, each file's CreateDate is
converted from B<pTimeZone> to the host's local time before it is used
for the output filename, and all the other EXIF time settings.

Pattern: C<UTC[+-]H> or C<UTC[+-]H:MM>.  The C<UTC> prefix is
case-insensitive (C<utc-1> is accepted).

Examples:

    -z utc-1     # zone 1 hour ahead of UTC
    -z UTC+8     # zone 8 hours behind UTC
    -z UTC-5:30  # zone 5h30m ahead of UTC
    -z utc-8:03  # your PST time was off by 3 min.
    -z local     # explicit "no conversion"

=item B<-T>

Generate thumbnail images for each input video.

Config var: C<Thumb>.  Default: C<no>

The thumbnail is a JPG with the same base name as the renamed video
file, extracted with ffmpeg from a single frame and then annotated
text is put in the thumbnail.

C<ThumbTime["FILE"]> in vid-tag.conf can be used to define the time
for the image that will be extracted.  Otherwise 5 seconds will be
used.  If the file has an C<Extra["FILE"]> title or a
C<ThumbTime["FILE"]> entry, the thumbnail is annotated at the top-left
with the Extra text, and the extract time will be put after the title.
A second annotation in the right-center will shows "VIDEO-->".  If a
file has been split, the number of video files will be put before the
text. For example: "3 files VIDEO-->".

The thumbnail's EXIF is copied from the video and its DateTimeOriginal
/ CreateDate / ModifyDate / mtime are set to be one second before the
video's CreateDate, so it will sort before the video file.

Config var: C<Thumb>. Default: C<yes>.

=item B<-n>

No-execute / dry-run.  Validate inputs and create config file
F<./vid-tag.conf> and F<vid-tag-example.txt>, but do not create
output/, rename files, or modify metadata.

=item B<-h>

Output this "long" usage help.  This is the same as C<-H long>.

=item B<-H pStyle>

Output usage in a specific style:

    short|usage - short usage, text
    long|text   - full usage, text
    man         - man page
    html        - HTML page
    md          - Markdown

    int         - Output internal documentation as text.
    int-html    - Output internal documentation as html.
    int-md      - Output internal documentation as markdown.

=item B<-v>

Verbose output.  Repeat for more detail (B<-vv>).

    (default) - warnings and errors only
    -v        - notice, warnings, and errors
    -vv       - info, notice, warnings, and errors

=item B<-V>

Output the script's version.

=item B<-d>

Debug level. Default: 0

Each -d increments the debug level. Debug messages will be printed
if the debug level is greater than the debug message's debug level.
Note: there is very little debug output because the script is best
tested with F<vid-tag.test>.

=back

=head2 Pattern Tokens

    %c   city name            (-c)
    %d   file date short      "YYYY-MM-DD"
    %D   file date long       "YYYY-MM-DD WWW"
    %T   file date full       "YYYY-MM-DD_HH:MM:SS"
    %e   event short          (-e)
    %E   event long           (-E)
    %f   original file name   (path stripped)
    %p   photographer short   (-p)
    %P   photographer long    (-P)

=head2 Config File Format

This is the config file (F<./vid-tag.conf>) format.  The file is a
B<bash include file>: each line is a bash variable assignment that is
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

The syntax is verified with C<bash -n> before the file is sourced.
Note: there should be no spaces around the '=' and all the values
should be between quotes (single ' or double ").

The B<Extra> entries are optional.  Each key is the exact name of an
input file. The value is the text that will be appended to that file's
EXIF Title. The Extra text will be put in the thumbnail if -T option.
Files without a matching key are unaffected.

When vid-tag exits, it rewrites F<./vid-tag.conf> with the final
effective values (defaults + previous conf + any command-line
overrides), so the next run will only need the file list.

=head1 RETURN VALUE

0 on success; non-zero on error.

=head1 ERRORS

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

=head2 Warnings

Processing will continue.

    Missing some some optional programs.
    No CreateDate in ?; using file mtime.
    output/? already exists, skipping.
    ? not found in output/; skipping.
    target exists, skipping: ? -> ?
    exiftool returned error? on ?

=for comment =head1 EXAMPLES

=head1 ENVIRONMENT

HOME, USER, PATH

=head1 FILES

=head2 vid-tag-N.N.zip

    vid-tag       - this script
    vid-tag.inc   - vid-tag functions
    vid-tag.conf  - sample config file describing tags for an event
    bash-com.inc  - utility functions
    vid-tag.test  - unit and CLI integration tests
    bash-com.test - test utility functions
    shunit2.1     - unit test framework for vid-tag.test
    LICENSE       - GPLv2

=head2 Generated files

    vid-tag.conf - if missing, it will be created with defaults and CLI args
    vid-tag-example.txt - lists the changes to files based on vid-tag.conf
    output/      - generated directory, with renamed copies of files

=head2 vid-tag-test-input.zip (4.5G)

Optional video files used by vid-tag.test. Only needed for
the testCli*Slow tests.

    MVI_0107.MP4
    MVI_0110.MP4
    MVI_0746.MP4

=head1 SEE ALSO

Required: Linux OS (see CAVEATS for Windows and MacOS)

Required: bash, exiftool, ffmpeg, convert, sed

Optional: vid-tag.test

=head1 NOTES

All of this code is maintained at:

    https://github.com/TurtleEngr/vid-tag

The releases are marked with vM.m.p tags.

=head2 Standard version numbering scheme

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

=head2 For Developers

The "main" branch is only for stable releases. Commits should be made
to the "develop" branch.

Run "make" with no targets to get the list of targets used to build
the code and release packages.

Getting started: run: "make required-prog git-config"

When you make changes, increment the cVer Makefile and run "make
build" Also, be sure to update vid-tag.test with tests for new
functionality.

Run "make test" for fast checks.

Run "make test-all" to test with actual video files.

If all OK, run "make install" to install a local copy.

If sending to others "make package" then send them the zip file in
pkg/.

=head1 CAVEATS

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
"develop" branch. (See the For Developers section.)

=head1 DIAGNOSTICS

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

=head1 BUGS

Report bugs at: https://github.com/TurtleEngr/vid-tag/issues

Always include the version number of the script you were using.  And
include complete error messages you see.

=for comment =head1 RESTRICTIONS

=head1 AUTHOR

Turtle Engineer

=head1 HISTORY

GPLv2 (c) Copyright (See LICENSE file for terms.)

cVer=2.3.5

=cut

EOF

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head1 vid-tag Internal Documentation

=internal-head2 fUsage pStyle

Select the type of help output. See -h and -H options.

=internal-head3 Config Variable to Internal Variable Map

The conf file (F<./vid-tag.conf>) uses these top-level bash variables.
fLoadConf assigns each to the corresponding internal C<gp*> global
after sourcing the file.  The conf-file variable names are NEVER
referenced directly anywhere else in the script.

    Conf-file var       Internal variable
    -------------       -----------------
    Caption             gpCaption
    Copyright           gpCopyright
    FilePat             gpFilePat
    NameLong            gpNameLong
    NameShort           gpNameShort
    TitlePat            gpTitlePat
    Event               gpEventId
    City                gpEventCity
    Keyword             gpEventKeyword
    TimeZone            gpTimeZone
    Title               gpEventTitle
    Thumb               gpThumb              (yes/no)
    Extra[<FILE>]       gExtraMap[<FILE>]    (per-file title append)
    ThumbTime[<FILE>]   gThumbMap[<FILE>]    (per-file thumbnail seek time)

=internal-head3 Per-file Extras

The B<Extra> entries are stored as a bash associative array indexed
by exact, case-sensitive file basenames (typically containing '.',
e.g. "MVI_0107.MP4").  Because the conf file is a bash include, no
special parser is needed: the C<Extra[FILE]=value> lines are simply
sourced.  fLoadConf declares C<-A Extra> before sourcing so that
indices are treated as associative keys.

=internal-cut

EOF

} # fUsage

# --------------------------------
fCleanUp() {
    fComCleanUp
    exit

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fCleanUp

Calls fComCleanUp to remove temp files and exit cleanly.

=internal-cut
EOF
} # fCleanUp

# --------------------------------
fSetGlobals() {
    fComSetGlobals

    # -------------------
    # Local config file path (sourced as a bash include by fLoadConf)
    gpConfLocal="./vid-tag.conf"

    # -------------------
    # Output directory constant
    cOutputDir="output"
    cExampleFile="vid-tag-example.txt"

    # -------------------
    # Script-level runtime flags
    gpNoExec=${gpNoExec:-0}

    # -------------------
    # Config-backed variables – hard-coded defaults.
    # Overridden in order: global conf → local conf → command line.
    gpCaption=${gpCaption:-"Copyright %P %d"}
    gpCopyright=${gpCopyright:-"Copyright %P %d"}
    gpEventCity=${gpEventCity:-"TBD"}
    gpEventFileList=${gpEventFileList:-""}
    gpEventKeyword=${gpEventKeyword:-"TBD"}
    gpEventId=${gpEventId:-""}
    gpEventTitle=${gpEventTitle:-"Event Title"}
    gpFilePat=${gpFilePat:-'%d_%e_%p_%f'}
    gpNameLong=${gpNameLong:-"First Last"}
    gpNameShort=${gpNameShort:-"TBD"}
    gpThumb=${gpThumb:-"no"}
    gpTimeZone=${gpTimeZone:-"local"}
    gpTitlePat=${gpTitlePat:-'%D, %c, %E, by %P.'}

    # -------------------
    # Thumbnail rendering constants (used by fMakeThumbnail and
    # fThumbAddLabel).  cgThumbTimeDefault is the ffmpeg -ss value used
    # when no ThumbTime is set for a file; the rest are convert(1)
    # option strings inserted verbatim into the annotate command.
    cgThumbBgColor="-undercolor black"
    cgThumbColor="-fill white"
    cgThumbFont="-font times-roman"
    cgThumbGravity="-gravity northwest -annotate +50+50"
    cgThumbMax="68"
    cgThumbPre="5"
    cgThumbSize="-pointsize 45"
    cgThumbText="VIDEO-->"
    cgThumbTextGravity="-gravity east -annotate +50+0"
    cgThumbTimeDefault="00:00:05"

    # -------------------
    # Per-file globals populated by fReadFileDate / fConvertDate
    gFile=""
    gFileDate=""
    gFileDateFull=""
    gFileDateLong=""
    gFileDateShort=""
    gFileDateTouch=""

    # -------------------
    # fExample collection state variables
    gpCmdLine=${gpCmdLine:-""}
    gExampleOrigNames=()
    gExampleNewNames=()
    gExampleTitles=()
    gExampleCreateDates=()
    gExampleIdx=0

    # -------------------
    # Per-file extras: populated by fLoadConf.  Reset to empty here so
    # repeated calls (in tests) don't accumulate stale entries.
    gExtraMap=()
    gThumbMap=()

    # -------------------
    # Required and optional external programs
    fComCheckDeps "bash exiftool ffmpeg convert sed" "cat"

    return

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fSetGlobals

Calls fComSetGlobals, then sets all script-specific globals.

Sets gpConfLocal to the standard vid-tag config paths.

Hard-coded defaults for every gpVar are applied here.  They are
overridden in order by: global conf, local conf, command-line options.

=internal-cut
EOF
} # fSetGlobals

# --------------------------------
fLoadConf() {
    # Source the local config file (bash include format).  If the file
    # does not exist, call fSaveConf to create it with the current
    # default values.
    #
    # The conf file uses these top-level bash variables:
    # Caption, Copyright, FilePat, NameLong, NameShort, TitlePat,
    # Event, City Title, Keyword, TimeZone
    # Extra[...] (optional, per-file)
    #
    # After sourcing, the values are assigned to the corresponding
    # internal gp* variables; the conf-file variables themselves are
    # NOT used directly elsewhere in the script.
    local tKey

    if [[ ! -f "$gpConfLocal" ]]; then
        fLog -p info \
            -m "Local config not found: $gpConfLocal - creating with defaults" \
            -l $LINENO
        fSaveConf
        return 0
    fi

    # Syntax check before sourcing
    if ! bash -n "$gpConfLocal"; then
        fError -m "Syntax error in $gpConfLocal" -l $LINENO
    fi

    # Declare the Extra associative array before sourcing so
    # "Extra[KEY]=VALUE" lines in the conf produce an associative (not
    # indexed) array.  Same for ThumbTime.
    local -A Extra=()
    local -A ThumbTime=()
    local Caption=""
    local Copyright=""
    local FilePat=""
    local NameLong=""
    local NameShort=""
    local TitlePat=""
    local Event=""
    local City=""
    local Title=""
    local Keyword=""
    local TimeZone=""
    local Thumb=""

    # shellcheck disable=SC1090
    source "$gpConfLocal"

    # Assign conf-file variables to internal gp* variables.  An empty
    # conf value falls back to the current gp* value (which holds the
    # default set by fSetGlobals).
    gpCaption=${Caption:-$gpCaption}
    gpCopyright=${Copyright:-$gpCopyright}
    gpFilePat=${FilePat:-$gpFilePat}
    gpNameLong=${NameLong:-$gpNameLong}
    gpNameShort=${NameShort:-$gpNameShort}
    gpTitlePat=${TitlePat:-$gpTitlePat}
    gpEventId=${Event:-$gpEventId}
    gpEventCity=${City:-$gpEventCity}
    gpEventTitle=${Title:-$gpEventTitle}
    gpEventKeyword=${Keyword:-$gpEventKeyword}
    gpTimeZone=${TimeZone:-$gpTimeZone}
    gpThumb=${Thumb:-$gpThumb}

    # Per-file extras: copy Extra associative array into gExtraMap.
    gExtraMap=()
    for tKey in "${!Extra[@]}"; do
        gExtraMap["$tKey"]="${Extra[$tKey]}"
    done

    # Per-file thumb times: copy ThumbTime associative array into gThumbMap.
    gThumbMap=()
    for tKey in "${!ThumbTime[@]}"; do
        gThumbMap["$tKey"]="${ThumbTime[$tKey]}"
    done

    # Normalise event id (spaces -> underscores, lower-cased by
    # the gpEventId declare -l attribute).
    gpEventId="${gpEventId// /_}"

    fLog -p info \
        -m "Loaded config: $gpConfLocal (event=$gpEventId, extras=${#gExtraMap[@]}, thumbs=${#gThumbMap[@]})" \
        -l $LINENO
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fLoadConf

Source the local config file (gpConfLocal, default F<./vid-tag.conf>).
The file is a bash include with top-level variable assignments:

    Caption="..."
    Copyright="..."
    FilePat="..."
    NameLong="..."
    NameShort="..."
    TitlePat="..."
    Event="..."
    City="..."
    Title="..."
    Keyword="..."
    TimeZone="..."
    Extra["FILE.mp4"]="extra title"      (optional, repeat per file)

Steps:

=internal-over 4

=internal-item 1. If the file does not exist, call fSaveConf to
create it with the current default values, then return.

=internal-item 2. Verify the syntax with C<bash -n>; on error, fError
exits the script.

=internal-item 3. Source the file inside a function scope (so the
conf-file variables are local), then assign each to the corresponding
gp* internal variable.  Empty conf values leave the gp* value at the
default set by fSetGlobals.

=internal-item 4. Copy the C<Extra> associative array into gExtraMap.

=internal-back

The conf-file variables are NEVER used directly elsewhere - only the
gp* / gExtraMap globals.  This isolates the conf-file naming from the
rest of the script.

=internal-cut
EOF
} # fLoadConf

# --------------------------------
fEscConf() {
    # Escape a string for safe inclusion inside a bash double-quoted
    # string literal: backslash, double-quote, dollar, and backtick.

    local tStr="$1"

    tStr="${tStr//\\/\\\\}"
    tStr="${tStr//\"/\\\"}"
    tStr="${tStr//\$/\\\$}"
    tStr="${tStr//\`/\\\`}"
    printf '%s' "$tStr"
    return 0
} # fEscConf

# --------------------------------
fSaveConf() {
    # Write the current values of all gp* / gExtraMap globals to the
    # local config file in bash-include format.  See fLoadConf for the
    # format description.

    local tKey

    fLog -p info -m "Saving local config: $gpConfLocal (event=$gpEventId)" -l $LINENO

    {
        echo "# vid-tag local config (bash include format)"
        echo "# Generated by vid-tag $cVer"
        echo ""
        echo "Caption=\"$(fEscConf "$gpCaption")\""
        echo "Copyright=\"$(fEscConf "$gpCopyright")\""
        echo "FilePat=\"$(fEscConf "$gpFilePat")\""
        echo "NameLong=\"$(fEscConf "$gpNameLong")\""
        echo "NameShort=\"$(fEscConf "$gpNameShort")\""
        echo "TitlePat=\"$(fEscConf "$gpTitlePat")\""
        echo "Event=\"$(fEscConf "$gpEventId")\""
        echo "City=\"$(fEscConf "$gpEventCity")\""
        echo "Title=\"$(fEscConf "$gpEventTitle")\""
        echo "Keyword=\"$(fEscConf "$gpEventKeyword")\""
        echo "TimeZone=\"$(fEscConf "$gpTimeZone")\""
        echo "Thumb=\"$(fEscConf "$gpThumb")\""
        # Per-file extras - skipped if gExtraMap is empty.
        if [[ ${#gExtraMap[@]} -gt 0 ]]; then
            # Sort keys for deterministic output (helpful for diff/round-trip).
            for tKey in $(printf '%s\n' "${!gExtraMap[@]}" | sort); do
                echo "Extra[\"$(fEscConf "$tKey")\"]=\"$(fEscConf "${gExtraMap[$tKey]}")\""
            done
        fi
        # Per-file thumb times - skipped if gThumbMap is empty.
        if [[ ${#gThumbMap[@]} -gt 0 ]]; then
            for tKey in $(printf '%s\n' "${!gThumbMap[@]}" | sort); do
                echo "ThumbTime[\"$(fEscConf "$tKey")\"]=\"$(fEscConf "${gThumbMap[$tKey]}")\""
            done
        fi
    } >"$gpConfLocal"

    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fSaveConf

Write the current effective values of all gp* config variables and
gExtraMap entries to the local config file (gpConfLocal) in
bash-include format (see fLoadConf for the format description).

This function replaces the entire conf file; sourcing the file
produced by fSaveConf must round-trip back to the same gp* /
gExtraMap values.

Values are escaped via fEscConf so backslashes, double quotes,
dollar signs, and backticks in any field do not break the bash
syntax of the written file.

=internal-cut
EOF
} # fSaveConf

# --------------------------------
fGetOpt() {
    local OPTIND=1
    local OPTARG
    local tArg

    while getopts :c:C:e:E:f:k:np:P:R:t:Tz:hH:vVd tArg; do
        case $tArg in
            # Script arguments
            c) gpEventCity="$OPTARG" ;;
            C) gpCaption="$OPTARG" ;;
            e) gpEventId="${OPTARG// /_}" ;;
            E) gpEventTitle="$OPTARG" ;;
            f) gpFilePat="$OPTARG" ;;
            k) gpEventKeyword="$OPTARG" ;;
            n) gpNoExec=1 ;;
            p) gpNameShort="$OPTARG" ;;
            P) gpNameLong="$OPTARG" ;;
            R) gpCopyright="$OPTARG" ;;
            t) gpTitlePat="$OPTARG" ;;
            T) gpThumb="yes" ;;
            z) gpTimeZone="$OPTARG" ;;
            # Common arguments
            h) fUsage long ;;
            H) fUsage "$OPTARG" ;;
            v) ((++gpVerbose)) ;;
            V)
                echo "vid-tag version: $cVer"
                exit 0
                ;;
            d) ((++gpDebug)) ;;
            # Problem arguments
            :) fError -m "Value required for option: -$OPTARG" -l $LINENO ;;
            \?) fError -m "Unknown option: $OPTARG" -l $LINENO ;;
        esac
    done
    ((--OPTIND))
    shift $OPTIND
    if [[ $# -ne 0 ]]; then
        gpEventFileList="$*"
    fi

    # Normalise event id one final time (may have been set via -e above).
    gpEventId="${gpEventId// /_}"
} # fGetOpt

# --------------------------------
fValidate() {
    local tFile

    if [[ ! -w ${gpConfLocal%/*} ]]; then
        fError -m "Directory ${gpConfLocal%/*} is not writable." -l $LINENO
    fi

    # gpEventId is required.  It may have come from the conf file
    # (Event="...") or from the -e command-line option.
    if [[ -z "$gpEventId" ]]; then
        fError -m "Missing pEventId, see required -e option." -l $LINENO
    fi

    if [[ "${gpFilePat#*%}" = "${gpFilePat}" ]]; then
        fError -m "-t pFilePat is missing % options" -l $LINENO
    fi
    if [[ "${gpTitlePat#*%}" = "${gpTitlePat}" ]]; then
        fError -m "-t pTitlePat is missing % options" -l $LINENO
    fi

    # TimeZone format check.  "local" means no conversion.
    # Valid format: "UTC[+-]H[:MM]" (case-insensitive on UTC).
    if [[ "$gpTimeZone" != "local" ]]; then
        if [[ ! "$gpTimeZone" =~ ^[Uu][Tt][Cc][+-][0-9]{1,2}(:[0-9]{2})?$ ]]; then
            fError -m "Invalid TimeZone: $gpTimeZone (expected UTC[+-]H[:MM] or 'local')" -l $LINENO
        fi
    fi

    if [[ -z "$gpEventFileList" && $gpNoExec -eq 0 ]]; then
        fError -m "No input files given. Use -h for help." -l $LINENO
    fi

    for tFile in $gpEventFileList; do
        if [[ ! -f "$tFile" ]]; then
            fError -m "File not found: $tFile" -l $LINENO
        fi
    done
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fValidate

Verify that at least one input file was given and that every file in
gpEventFileList exists on disk.  Calls fError (fatal) on the first
missing file.

=internal-cut
EOF
} # fValidate

# --------------------------------
fConvertTimeZone() {
    # Given an exiftool date string "YYYY:MM:DD HH:MM:SS", return the
    # same string converted from gpTimeZone to local time.
    #
    # When gpTimeZone is "local", the input is echoed back unchanged -
    # the caller does not need to special-case the no-op.
    #
    # The 'date' command's "TZ=..." date-string prefix is used so that
    # POSIX TZ semantics apply: e.g. gpTimeZone="utc-1" represents a
    # zone 1 hour AHEAD of UTC (just as TZ="UTC-1" does in the env).
    # The output is in the host's local time, in exiftool's format.

    local pRaw="$1"

    local tDate
    local tFixed
    local tTime

    if [[ "$gpTimeZone" = "local" ]]; then
        echo "$pRaw"
        return 0
    fi

    # Defensive validation - fValidate already enforces this on user
    # inputs but this function may be called directly from tests.
    if [[ ! "$gpTimeZone" =~ ^[Uu][Tt][Cc][+-][0-9]{1,2}(:[0-9]{2})?$ ]]; then
        fError -m "Invalid TimeZone: $gpTimeZone (expected UTC[+-]H[:MM] or 'local')" -l $LINENO
        return 1
    fi

    # Split exiftool format "YYYY:MM:DD HH:MM:SS" into date + time.
    tDate="${pRaw%% *}"
    tTime="${pRaw##* }"
    # date(1) accepts "YYYY-MM-DD" but not "YYYY:MM:DD" for the date.
    tDate="${tDate//:/-}"

    tFixed=$('date' --date="TZ=\"$gpTimeZone\" $tDate $tTime" \
        +'%Y:%m:%d %H:%M:%S' 2>/dev/null)
    if [[ -z "$tFixed" ]]; then
        fError -m "Failed to convert: '$pRaw' from TimeZone=$gpTimeZone" -l $LINENO
        return 1
    fi
    echo "$tFixed"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fConvertTimeZone "YYYY:MM:DD HH:MM:SS"

Convert the timestamp in pRaw from gpTimeZone to local time and echo it
in the same exiftool format.

If gpTimeZone is empty or "local", pRaw is echoed unchanged.

gpTimeZone must be in the form "UTC[+-]H" or "UTC[+-]H:MM" (case-
insensitive on the "UTC" prefix).  POSIX TZ sign semantics apply:
"UTC-1" means a zone one hour AHEAD of UTC, so a file CreateDate of
"2026:05:02 01:00:00" with gpTimeZone="utc-1" converts to
"2026:05:02 00:00:00" UTC, which on a host in PDT (UTC-7) becomes
"2026:05:01 17:00:00".

=internal-cut
EOF
} # fConvertTimeZone

# --------------------------------
fConvertDate() {
    # Given an exiftool date string "YYYY:MM:DD HH:MM:SS", populate the
    # four gFileDate* globals used by fApplyPattern and fProcessFile.
    local pRaw="$1"

    local tNorm

    # Normalise date separator: "YYYY:MM:DD HH:MM:SS" -> "YYYY-MM-DD HH:MM:SS"
    tNorm=$(echo "$pRaw" \
        | sed 's/^\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\)/\1-\2-\3/')

    gFileDateShort=$('date' -d "$tNorm" +"%Y-%m-%d")
    gFileDateLong=$('date' -d "$tNorm" +"%Y-%m-%d %a")
    gFileDateFull=$('date' -d "$tNorm" +"%Y-%m-%d_%H:%M:%S")
    gFileDateTouch=$('date' -d "$tNorm" +"%Y%m%d%H%M.%S")
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fConvertDate "YYYY:MM:DD HH:MM:SS"

Converts the exiftool CreateDate string into four gFileDate* globals:

    gFileDateShort  - "YYYY-MM-DD"
    gFileDateLong   - "YYYY-MM-DD WWW"
    gFileDateFull   - "YYYY-MM-DD_HH:MM:SS"
    gFileDateTouch  - "YYYYMMDDHHmm.SS"  (touch -t format)

=internal-cut
EOF
} # fConvertDate

# --------------------------------
fReadFileDate() {
    # Read CreateDate via exiftool.  Fall back to file mtime if absent.
    local pFile="$1"

    gFileDate=$(exiftool -s -s -s -CreateDate "$pFile" 2>/dev/null)
    if [[ -z "$gFileDate" ]]; then
        fLog -p warning \
            -m "No CreateDate in $pFile; using file mtime." -l $LINENO
        gFileDate=$('date' -r "$pFile" +"%Y:%m:%d %H:%M:%S")
    fi
    # Apply gpTimeZone conversion (no-op when gpTimeZone is empty or "local").
    gFileDate=$(fConvertTimeZone "$gFileDate")
    fConvertDate "$gFileDate"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fReadFileDate pFile

Read the CreateDate metadata from pFile using exiftool and call
fConvertDate to populate the gFileDate* globals.

If exiftool finds no CreateDate, the file's mtime is used as a
fallback and a warning is logged.

=internal-cut
EOF
} # fReadFileDate

# --------------------------------
fApplyPattern() {
    # Expand %-tokens in pPattern, substituting current date/event globals.
    # $1 = pattern string   $2 = original basename (for %f)
    local pPattern="$1"
    local pFile="$2"

    local tR="$pPattern"

    # Expand longer / upper-case tokens first where case-only pairs exist.
    tR="${tR//%D/$gFileDateLong}"
    tR="${tR//%d/$gFileDateShort}"
    tR="${tR//%T/$gFileDateFull}"
    tR="${tR//%E/$gpEventTitle}"
    tR="${tR//%e/$gpEventId}"
    tR="${tR//%P/$gpNameLong}"
    tR="${tR//%p/$gpNameShort}"
    tR="${tR//%c/$gpEventCity}"
    tR="${tR//%f/$pFile}"

    echo "$tR"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fApplyPattern pPattern pFile

Expand %-tokens within pPattern using the current gFileDate* and gp*
globals.  The expanded string is echoed to stdout.

Token table:

    %c   gpEventCity
    %d   gFileDateShort  "YYYY-MM-DD"
    %D   gFileDateLong   "YYYY-MM-DD WWW"
    %T   gFileDateFull   "YYYY-MM-DD_HH:MM:SS"
    %e   gpEventId
    %E   gpEventTitle
    %f   pFile  (basename of the original file)
    %p   gpNameShort
    %P   gpNameLong

=internal-cut
EOF
} # fApplyPattern

# --------------------------------
fCreateOutputDir() {
    # Create ./output/ and hard-link every input file into it.
    local tFile tBase

    if [[ ! -d "$cOutputDir" ]]; then
        mkdir -p "$cOutputDir"
        fLog -p info -m "Created output dir: $cOutputDir" -l $LINENO
    fi

    for tFile in $gpEventFileList; do
        tBase=$(basename "$tFile")
        if [[ -e "$cOutputDir/$tBase" ]]; then
            fLog -p warning \
                -m "$cOutputDir/$tBase already exists, skipping." \
                -l $LINENO
            continue
        fi
        fLog -m "Copy: $tFile -> $cOutputDir/$tBase" -l $LINENO
        rsync -aP $tFile $cOutputDir/$tBase
    done
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fCreateOutputDir

Creates cOutputDir (default: ./output/) if absent, then hard-links each
file in gpEventFileList into it.

Skips (with a warning) any link target that already exists.

=internal-cut
EOF
} # fCreateOutputDir

# --------------------------------
fExampleCollect() {
    # Append one record to the gExample* collection arrays.
    # $1 = original basename
    # $2 = exiftool-format CreateDate "YYYY:MM:DD HH:MM:SS"
    # Reads gpFilePat / gpTitlePat / gExtraMap and the gFileDate*
    # globals (already populated by fConvertDate).
    local pBase="$1"
    local pCreateDate="$2"

    local tNewName
    local tNewTitle

    tNewName=$(fApplyPattern "$gpFilePat" "$pBase")
    tNewTitle=$(fApplyPattern "$gpTitlePat" "$pBase")
    if [[ -n "${gExtraMap[$pBase]:-}" ]]; then
        tNewTitle="$tNewTitle ${gExtraMap[$pBase]}."
    fi

    gExampleOrigNames[$gExampleIdx]="$pBase"
    gExampleNewNames[$gExampleIdx]="$tNewName"
    gExampleTitles[$gExampleIdx]="$tNewTitle"
    gExampleCreateDates[$gExampleIdx]="$pCreateDate"
    ((++gExampleIdx))
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fExampleCollect pBase pCreateDate

Append one record (original name, new name, title, CreateDate) to the
gExample* arrays and bump gExampleIdx.

The gFileDate* globals must already be populated for the file (so that
fApplyPattern produces the right %d / %D / %T expansions).

=internal-cut
EOF
} # fExampleCollect

# --------------------------------
fExampleCollectSplit() {
    # If pFile's duration is greater than 10 min, append one record per
    # 10-min segment that fProcessFile would produce.  Each part inherits
    # the parent's Title and tags; only the CreateDate is shifted by
    # (partIdx * 10) minutes.  Names mirror what ffmpeg's segment muxer
    # writes in fProcessFile: "<root>-NN.mp4" (lowercase ".mp4").
    #
    # $1 = original basename                 (e.g. MVI_0746.MP4)
    # $2 = path to the input file            (used by ffmpeg -i)
    # $3 = parent's CreateDate, exiftool fmt "YYYY:MM:DD HH:MM:SS"
    local pBase="$1"
    local pFile="$2"
    local pCreateDate="$3"

    local tH
    local tM
    local tS
    local -i tMin
    local -i tNumParts
    local -i tIdx
    local -i tIncMin
    local tLength
    local tNewName
    local tNewTitle
    local tPartName
    local tPartTime

    # Read duration with the same ffmpeg call style fProcessFile uses.
    tLength=$(ffmpeg -i "$pFile" 2>&1 | grep -oP 'Duration: \K[\d:]+(?=\.)')
    if [[ -z "$tLength" ]]; then
        return 0
    fi
    IFS=':'
    read -r tH tM tS <<<"$tLength"
    IFS=' '

    # Strip any leading zeros
    tH=${tH#0}
    tM=${tM#0}
    tS=${tS#0}

    # Same threshold as fProcessFile: <= 10 min → no split.
    ((tMin = tH * 60 + tM))
    if [[ $tMin -le 10 ]]; then
        return 0
    fi

    # ceil(total_seconds / 600) - matches the segment count ffmpeg's
    # -segment_time 00:10:00 muxer will emit.
    tNumParts=$(((tMin * 60 + tS + 599) / 600))

    # Parts share the renamed root with a -NN suffix and lowercase ".mp4"
    tNewName=$(fApplyPattern "$gpFilePat" "$pBase")
    tNewName="${tNewName%.*}"

    # Parts inherit Title from the parent (TagsFromFile in fProcessFile),
    # so re-apply the title pattern with the same gFileDate* globals that
    # the parent fExampleCollect call used.
    tNewTitle=$(fApplyPattern "$gpTitlePat" "$pBase")
    if [[ -n "${gExtraMap[$pBase]:-}" ]]; then
        tNewTitle="$tNewTitle ${gExtraMap[$pBase]}."
    fi

    for ((tIdx = 0; tIdx < tNumParts; tIdx++)); do
        tPartName=$(printf "%s-%02d.mp4" "$tNewName" "$tIdx")
        ((tIncMin = tIdx * 10))
        tPartTime=$(fAddMin "$pCreateDate" $tIncMin)

        gExampleOrigNames[$gExampleIdx]="$pBase"
        gExampleNewNames[$gExampleIdx]="$tPartName"
        gExampleTitles[$gExampleIdx]="$tNewTitle"
        gExampleCreateDates[$gExampleIdx]="$tPartTime"
        ((++gExampleIdx))
    done
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fExampleCollectSplit pBase pFile pCreateDate

If pFile is longer than 10 minutes, append one gExample* record per
10-min segment that fProcessFile would create.  Part names use the
"<root>-NN.mp4" convention with lowercase ".mp4" to match ffmpeg's
segment muxer output.  CreateDate is shifted by (partIdx * 10) minutes
via fAddMin; all other tag values are inherited from the parent, so
the example file shows the same Title/Author/Keywords/etc. that
fProcessFile copies via "exiftool -TagsFromFile".

Returns 0 with no entries appended if ffmpeg returns no Duration line
or the file is 10 minutes or shorter.

=internal-cut
EOF
} # fExampleCollectSplit

# --------------------------------
fExample() {
    # Build vid-tag-example.txt showing what the next non-dry-run pass
    # would do: rename mappings into ./output/ and the exif tags that
    # will be set on each file.
    #
    # Called after fValidate / fSaveConf so all gp* config values are
    # final.  When gpNoExec is set, no real files have been validated,
    # so we use a single dummy entry: name "FILE.mp4" and CreateDate
    # set to "now".  Otherwise we walk gpEventFileList and read each
    # file's CreateDate via fReadFileDate.

    local tBase
    local tCmd
    local tFile
    local -i tIdx

    # Reset the per-file collection arrays so repeated calls don't
    # accumulate stale entries.
    gExampleOrigNames=()
    gExampleNewNames=()
    gExampleTitles=()
    gExampleCreateDates=()
    gExampleIdx=0

    # ---- Collection phase ----
    if [[ $gpNoExec -ne 0 && "$gpEventFileList" = "" ]]; then
        # Dummy entry: FILE.mp4 with the current local date/time
        gFileDate=$('date' +"%Y:%m:%d %H:%M:%S")
        fConvertDate "$gFileDate"
        fExampleCollect "FILE.mp4" "$gFileDate"
    else
        for tFile in $gpEventFileList; do
            tBase=$(basename "$tFile")
            fReadFileDate "$tFile"
            fExampleCollect "$tBase" "$gFileDate"
            # Files longer than 10 min will be split by fProcessFile;
            # mirror that here so vid-tag-example.txt previews the parts.
            fExampleCollectSplit "$tBase" "$tFile" "$gFileDate"
        done
    fi

    # ---- Output phase ----
    # Reconstruct the command line if vid-tag main did not capture it.
    if [[ -n "$gpCmdLine" ]]; then
        tCmd="$gpCmdLine"
    else
        tCmd="$cName"
        [[ $gpNoExec -ne 0 ]] && tCmd+=" -n"
        tCmd+=" -e $gpEventId"
        [[ -n "$gpEventFileList" ]] && tCmd+=" $gpEventFileList"
    fi

    {
        echo "Command:"
        echo "    $tCmd"
        echo "Files:"
        for ((tIdx = 0; tIdx < gExampleIdx; tIdx++)); do
            echo "    ${gExampleOrigNames[$tIdx]} -> $cOutputDir/${gExampleNewNames[$tIdx]}"
        done
        echo "Exif Changes:"
        for ((tIdx = 0; tIdx < gExampleIdx; tIdx++)); do
            echo " "
            echo "${gExampleNewNames[$tIdx]}"
            echo "    Title = ${gExampleTitles[$tIdx]}"
            echo " "
            echo "    Author = $gpNameLong"
            echo "    Artist = $gpCopyright"
            echo "    Copyright = $gpCopyright"
            echo " "
            echo "    Keywords = $gpEventKeyword"
            echo " "
            echo "    Caption = $gpCaption"
            echo "    Description = (see Caption)"
            echo "    Image Description = (see Caption)"
            echo " "
            echo "    Create Date = ${gExampleCreateDates[$tIdx]}"
            echo "    Date/Time Original = (see Create Date)"
            echo "    Modify Date = (see Create Date)"
            echo "    Track Create Date = (see Create Date)"
            echo "    Track Modify Date = (see Create Date)"
            echo "    Media Create Date = (see Create Date)"
            echo "    Media Modify Date = (see Create Date)"
        done
    } >"$cExampleFile"

    fLog -p info -m "Created $cExampleFile" -l $LINENO
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fExample

Build F<vid-tag-example.txt> in the current directory.  The file shows:

=internal-over 4

=internal-item 1. The (re-constructed) command line.

=internal-item 2. A "Files:" block listing each input file and its
intended renamed path under cOutputDir.

=internal-item 3. An "Exif Changes:" block listing the metadata tags
that vid-tag will write to each renamed file.

=internal-back

When gpNoExec is set, a single dummy entry is generated using
F<FILE.mp4> as the input name and the current wall-clock time as the
CreateDate, so the user can preview their conf settings before
supplying real files.  Otherwise each file in gpEventFileList is
read via fReadFileDate to get its CreateDate.

The per-file fields are accumulated into the gExample* arrays via
fExampleCollect, indexed by gExampleIdx.  The collection is read in
the output phase to format the file.

=internal-cut
EOF
} # fExample

# --------------------------------
fAddMin() {
    # Add pMin minutes to an exiftool "Create Date" grep line and
    # echo the adjusted timestamp in exiftool format.
    local pRaw="$1"
    local -i pMin=$2

    local tDate
    local tTime
    local tH
    local tM
    local tS

    # Strip the label, keeping only "YYYY:MM:DD HH:MM:SS"
    tDate="${pRaw##*: }"

    # Split into date and time parts
    tTime="${tDate##* }"
    tDate="${tDate%% *}"

    IFS=':'
    read -r tH tM tS <<<"$tTime"
    IFS=' '

    # Strip any leading zeros
    tH=${tH#0}
    tM=${tM#0}
    tS=${tS#0}

    ((tM += pMin))
    if [[ $tM -ge 60 ]]; then
        ((tH += tM / 60))
        ((tM %= 60))
    fi

    printf "%s %02d:%02d:%02d" "$tDate" "$tH" "$tM" "$tS"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fAddMin "pTimestamp" pMinutes

Add pMinutes to a timestamp and echo the result in exiftool format
"YYYY:MM:DD HH:MM:SS".

pTimestamp is either a bare exiftool timestamp ("YYYY:MM:DD HH:MM:SS")
or a grep'ed exiftool label line; in either case the date/time portion
is extracted automatically via pattern stripping.

Only minute-to-hour overflow is handled; hour-to-day overflow is not
expected for 10-minute video segments.

=internal-cut
EOF
} # fAddMin

# --------------------------------
fThumbAddLabel() {
    # Annotate the thumbnail image pThumb with pText at gravity pGravity
    # using the cgThumb* font/color/background constants.  The convert
    # output is written to a temp file in the same directory and then
    # renamed over pThumb.
    #
    # $1 = thumbnail image path
    # $2 = text label
    # $3 = convert "-gravity ... -annotate +X+Y" option string
    local pThumb="$1"
    local pText="$2"
    local pGravity="$3"

    local tTmp

    tTmp="${pThumb%.*}.tmp.jpg"

    fLog -p debug-1 \
        -m "convert $pThumb $cgThumbSize $cgThumbFont $cgThumbColor $cgThumbBgColor $pGravity \"$pText\" $tTmp" \
        -l $LINENO
    # cgThumb* and pGravity are intentionally word-split so each
    # "-flag value" pair becomes separate convert arguments.
    # shellcheck disable=SC2086
    convert "$pThumb" $cgThumbSize $cgThumbFont $cgThumbColor $cgThumbBgColor \
        $pGravity "$pText" "$tTmp"
    mv -f "$tTmp" "$pThumb"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fThumbAddLabel pThumb pText pGravity

Add a single text annotation to pThumb using convert(1).  pGravity is
the "-gravity ... -annotate +X+Y" option pair (e.g. cgThumbGravity for
the Extra/Time label, cgThumbTextGravity for the VIDEO--> label).  The
font / color / background / point-size are taken from the cgThumb*
constants set by fSetGlobals.

The output is written to a temp file and then moved over pThumb so the
file is updated atomically.  Always returns 0; convert errors are not
treated as fatal.

=internal-cut
EOF
} # fThumbAddLabel

# --------------------------------
fMakeThumbnail() {
    # Generate the thumbnail image for a renamed video file.  Called
    # from fProcessFile after the rename + EXIF write, so $gFileDate is
    # the (possibly timezone-converted) CreateDate of the source video.
    # Must be called with CWD == ./output/ (same as fProcessFile).
    #
    # $1 = renamed video file in cOutputDir
    # $2 = original basename (used for gExtraMap / gThumbMap lookup)
    # $3 = number of split parts (1 = not split, >1 = split count)
    local pRenamed="$1"
    local pOrigBase="$2"
    local -i pNumParts=$3

    local tThumb
    local tTime
    local -i tHasTime
    local tExtra
    local tLabel
    local tDate
    local tTimeOnly
    local tNorm
    local tThumbDate
    local tTouchDate

    tThumb="${pRenamed%.*}.jpg"

    # ----- Decide the ffmpeg seek time -----
    if [[ -n "${gThumbMap[$pOrigBase]:-}" ]]; then
        tTime="${gThumbMap[$pOrigBase]}"
        tHasTime=1
    else
        tTime="$cgThumbTimeDefault"
        tHasTime=0
    fi

    # ----- Extract the still image -----
    if [[ -f "$tThumb" ]]; then
        rm -f "$tThumb"
    fi
    fLog -p info -m "ffmpeg -ss $tTime -i $pRenamed -frames:v 1 $tThumb" -l $LINENO
    ffmpeg -y -ss "$tTime" -i "$pRenamed" -frames:v 1 "$tThumb" >/dev/null 2>&1

    # ----- Extra/Time label -----
    # Per spec: skip this label only when there is no Extra AND no
    # ThumbTime for this file.  Otherwise build "<extra> (<time>)" with
    # either part possibly absent.
    tExtra="${gExtraMap[$pOrigBase]:-}"
    if [[ -n "$tExtra" || $tHasTime -ne 0 ]]; then
        tLabel="${tExtra:0:$cgThumbMax}"
        if [[ $tHasTime -ne 0 ]]; then
            if [[ -n "$tLabel" ]]; then
                tLabel="$tLabel ($tTime)"
            else
                tLabel="($tTime)"
            fi
        fi
        fThumbAddLabel "$tThumb" "$tLabel" "$cgThumbGravity"
    fi

    # ----- VIDEO--> label (with split-count prefix when applicable) -----
    if [[ $pNumParts -gt 1 ]]; then
        tLabel="$pNumParts files $cgThumbText"
    else
        tLabel="$cgThumbText"
    fi
    fThumbAddLabel "$tThumb" "$tLabel" "$cgThumbTextGravity"

    # ----- Copy EXIF from the video, with times 1 sec earlier -----
    # gFileDate is exiftool format "YYYY:MM:DD HH:MM:SS".  date(1)
    # accepts "YYYY-MM-DD HH:MM:SS" for arithmetic, so normalise the
    # date colons before subtracting.  Use "$cgThumbPre second ago"
    # rather than "- 1 second": the latter is parsed by GNU date(1) as
    # a -01 UTC offset, not as subtraction.
    tDate="${gFileDate%% *}"
    tTimeOnly="${gFileDate##* }"
    tNorm="${tDate//:/-} $tTimeOnly"
    tThumbDate=$('date' -d "$tNorm $cgThumbPre second ago" +"%Y:%m:%d %H:%M:%S")
    tTouchDate=$('date' -d "$tNorm $cgThumbPre second ago" +"%Y-%m-%d %H:%M:%S")

    fLog -p info \
        -m "exiftool -TagsFromFile $pRenamed -all:all -DateTimeOriginal=$tThumbDate ... $tThumb" \
        -l $LINENO
    exiftool -overwrite_original -TagsFromFile "$pRenamed" -all:all \
        -DateTimeOriginal="$tThumbDate" \
        -CreateDate="$tThumbDate" \
        -ModifyDate="$tThumbDate" \
        "$tThumb" >/dev/null 2>&1

    fLog -p info -m "touch -d \"$tTouchDate\" $tThumb" -l $LINENO
    touch -d "$tTouchDate" "$tThumb"

    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fMakeThumbnail pRenamed pOrigBase pNumParts

Generate the thumbnail "\${pRenamed%.*}.jpg" for a renamed video file.
Reads gThumbMap and gExtraMap (keyed by pOrigBase) and uses gFileDate
(already timezone-converted by fReadFileDate) as the source for the
thumbnail's date metadata.

Steps:

=internal-over 4

=internal-item 1. Extract a single frame with ffmpeg -ss.  Time is
gThumbMap[pOrigBase] when set, otherwise cgThumbTimeDefault.

=internal-item 2. If an Extra title or a ThumbTime is defined for the
file, annotate the thumb at cgThumbGravity with "<extra> (<time>)"
(either part may be absent).  Extra text is truncated to cgThumbMax
characters.

=internal-item 3. Annotate the thumb at cgThumbTextGravity with the
cgThumbText marker.  When pNumParts > 1 the text is prefixed with
"<pNumParts> files ".

=internal-item 4. Copy all compatible EXIF from pRenamed and set
DateTimeOriginal / CreateDate / ModifyDate to one second before
gFileDate.  Set the file mtime to the same value.

=internal-back

Returns 0; per-step errors (ffmpeg/convert/exiftool) are logged but
not fatal.

=internal-cut
EOF
} # fMakeThumbnail

# --------------------------------
fProcessFile() {
    # Rename + tag a single file.  Must be called with CWD == ./output/
    local pFile="$1"

    local tH
    local tM
    local tS
    local -i tIncMin
    local -i tNumParts
    local tBase
    local tCaption
    local tCmd
    local tCopyright
    local tDate
    local tFile
    local tLength
    local tMin
    local tNewName
    local tNewTitle
    local tPart
    local tRC
    local tTime

    tBase=$(basename "$pFile")

    if [[ ! -f "$tBase" ]]; then
        fLog -p warning \
            -m "$tBase not found in $cOutputDir; skipping." -l $LINENO
        return 0
    fi
    fLog -f -m "Processing: $tBase" -l $LINENO

    fReadFileDate "$tBase"

    # ----------
    # Get the file's new name and the Title, using the patterns
    tNewName=$(fApplyPattern "$gpFilePat" "$tBase")
    tNewTitle=$(fApplyPattern "$gpTitlePat" "$tBase")
    if [[ -n "${gExtraMap[$tBase]:-}" ]]; then
        tNewTitle="$tNewTitle ${gExtraMap[$tBase]}."
    fi

    # Expand any pattern tokens in Caption and Copyright.
    tCaption=$(fApplyPattern "$gpCaption" "$tBase")
    tCopyright=$(fApplyPattern "$gpCopyright" "$tBase")

    # ----------
    # Collision guard before rename.
    if [[ "$tBase" != "$tNewName" && -e "$tNewName" ]]; then
        fLog -p warning \
            -m "target exists, skipping: $tBase -> $tNewName" -l $LINENO
        return 0
    fi

    # ----------
    # Use exiftool to rename AND set all metadata fields.
    # When a TimeZone conversion is active, also write the converted
    # local time back into every date/time field so the file's metadata
    # is consistent with the renamed path and the mtime set by touch.
    tCmd=(
        exiftool
        -overwrite_original
        -FileName="$tNewName"
        -Title="$tNewTitle"
        -Copyright="$tCopyright"
        -Artist="$tCopyright"
        -Author="$gpNameLong"
        -Keywords="$gpEventKeyword"
        -Caption="$tCaption"
        -Description="$tCaption"
        -ImageDescription="$tCaption"
    )
    if [[ "$gpTimeZone" != "local" ]]; then
        tCmd+=(
            -DateTimeOriginal="$gFileDate"
            -CreateDate="$gFileDate"
            -ModifyDate="$gFileDate"
            -TrackCreateDate="$gFileDate"
            -TrackModifyDate="$gFileDate"
            -MediaCreateDate="$gFileDate"
            -MediaModifyDate="$gFileDate"
        )
    fi
    tCmd+=("$tBase")
    fLog -p info -m "Rename: $tBase -> $tNewName" -l $LINENO
    fLog -p info -m "Set new meta values" -l $LINENO
    fLog -p debug-1 -m "Cmd: ${tCmd[*]}" -l $LINENO
    "${tCmd[@]}" 2>&1 | while IFS= read -r tLine; do
        fLog -p info -m "$tLine" -l $LINENO
    done
    tRC=${PIPESTATUS[0]}

    if [[ $tRC -ne 0 ]]; then
        fLog -p warning \
            -m "exiftool returned $tRC on $tBase" -l $LINENO
    fi

    # ----------
    # Align filesystem mtime with the metadata's CreateDate.
    fLog -p info -m "touch -d \"${gFileDateFull//_/ }\" \"$tNewName\"" -l $LINENO
    touch -d "${gFileDateFull//_/ }" "$tNewName"

    # ----------
    # See if the file needs to be split. I.e. greater than 10 min
    tLength=$(ffmpeg -i $tNewName 2>&1 | grep -oP 'Duration: \K[\d:]+(?=\.)')
    IFS=':'
    read -r tH tM tS <<<"$tLength"
    IFS=' '

    # Strip any leading zeros
    tH=${tH#0}
    tM=${tM#0}
    tS=${tS#0}
    ((tMin = $tH * 60 + $tM))

    # Compute the split-part count (1 = not split).  Used both for the
    # thumbnail's "VIDEO-->" label prefix and the split-or-not branch.
    tNumParts=1
    if [[ $tMin -gt 10 ]]; then
        tNumParts=$(((tMin * 60 + 10#$tS + 599) / 600))
    fi

    # ----------
    # Generate the thumbnail (when enabled).  Must happen after rename +
    # EXIF write and before any split, so the thumbnail is named after
    # the parent renamed file.
    if [[ "$gpThumb" = "yes" ]]; then
        fMakeThumbnail "$tNewName" "$tBase" "$tNumParts"
    fi

    if [[ $tMin -le 10 ]]; then
        return 0
    fi

    # ----------
    # Yes, split the file
    fLog -m "Split $tNewName into 10min parts" -l LINENO
    ffmpeg -i $tNewName -c copy -map 0 -segment_time 00:10:00 -f segment -reset_timestamps 1 ${tNewName%.*}-%02d.mp4 >/dev/null 2>&1

    fLog -p info -m "Copy the exif data from original" -l $LINENO
    # gFileDate is already in local time (converted by fConvertTimeZone in
    # fReadFileDate), so use it directly as the base for part timestamps.
    for tFile in ${tNewName%.*}-*.mp4; do
        fLog -p info -m "exiftool -TagsFromFile $tNewName -all:all $tFile" -l $LINENO
        exiftool -TagsFromFile $tNewName -all:all $tFile >/dev/null 2>&1

        # Increment the times for the parts
        tPart=${tFile%.mp4}
        tPart=${tPart##*-}
        ((tIncMin = tPart * 10))
        tNewTime=$(fAddMin "$gFileDate" $tIncMin)
        exiftool \
            -DateTimeOriginal="$tNewTime" \
            -CreateDate="$tNewTime" \
            -ModifyDate="$tNewTime" \
            -TrackCreateDate="$tNewTime" \
            -TrackModifyDate="$tNewTime" \
            -MediaCreateDate="$tNewTime" \
            -MediaModifyDate="$tNewTime" \
            $tFile

        # Now set the file's timestamp
        tDate=${tNewTime% *}
        tTime=${tNewTime#* }
        fLog -p info -m "touch -d \"${tDate//:/-} $tTime\" $tFile" -l $LINENO
        touch -d "${tDate//:/-} $tTime" $tFile
    done
    rm *_original

    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head2 fProcessFile pFile

Process a single video file that has already been hard-linked into
cOutputDir.  Must be called with the working directory set to cOutputDir.

Steps:

=internal-over 4

=internal-item 1. Read CreateDate from file (fReadFileDate), which
applies fConvertTimeZone so gFileDate* globals hold local time.

=internal-item 2. Expand file-name and title patterns (fApplyPattern).

=internal-item 3. Run a single exiftool call to rename and set all
metadata.  When gpTimeZone is active (not "local"), the seven
date/time exif fields (DateTimeOriginal, CreateDate, ModifyDate,
TrackCreateDate, TrackModifyDate, MediaCreateDate, MediaModifyDate)
are also written with the converted local time so the file metadata is
consistent with the renamed path.

=internal-item 4. Set filesystem mtime to the converted CreateDate (touch).

=internal-item 5. If the file is longer than 10 minutes, split it into
10-min parts with ffmpeg and copy tags from the parent.  Each part's
seven date fields and mtime are set using gFileDate (already converted)
as the base, shifted by part-index * 10 minutes via fAddMin.

=internal-back

Logs at "info" level for each step; "warning" if exiftool fails.

=internal-cut

EOF

} # fProcessFile
