set -u

export cVer=1.3
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

# Per-file extra-title map populated by fLoadExtras from the
# [vid-tag "extra"] section of $gpConfLocal.  Keys are file basenames
# (exact, case-sensitive); values are the text appended to the EXIF
# Title for matching files.
declare -Ag gExtraMap
# Raw text of the [vid-tag "extra"] block, captured by fLoadExtras
# and re-emitted by fSaveExtras.  Used to round-trip the section
# unchanged across git-config based reads/writes.
export gExtraSection

# ========================================
# Script Functions

# --------------------------------
fUsage() {
    # Quick help, run this:
    # vid-tag -h
    local pStyle="$1"

    case $pStyle in
        short | usage | man | long | text | md)
            fComUsage -f $cBin/$cName.inc -s $pStyle
            ;;
        html)
            fComUsage -f $cBin/$cName.inc -s $pStyle -t "$cName Usage"
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

Rename video files and set Title / Caption / Keywords metadata.

=head1 SYNOPSIS

First run. Create config file: ./vid-tag.conf

    vid-tag -n -e "pEventId"

Edit config files, and/or use these options to override config file.

    vid-tag -e "pEventId" File1 [File2 ...]
        [-p "pInitials"] [-P "pName"] [-C "pCaption"] [-R "pCopyright"]
        [-E "pEventTitle"] [-c "pCity"] [-k "pKeyword"]
        [-f "pFilePattern"] [-t "pTitlePattern"]
        [-z "pTimeZone"]
        [-n] [-h] [-H pStyle] [-v] [-d]

=head1 DESCRIPTION

vid-tag renames one or more video files and writes Title, Caption, and
Keywords metadata using B<exiftool>.  The file's B<Create Date> metadata
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

=over 4

=item Built-in script defaults.

=item Local config: B<./vid-tag.conf> If the file does not exist it
will be created, and updated with the latest default settings.

=item Command-line options will override all other settings.

=back

After all the values are set, the results are saved to
B<./vid-tag.conf> so the next run needs only needs the -e option and
the file list.

=head2 QUICK START

=head3 Install

=over 4

=item Download the latest packaged zip file, vid-tag-VER.zip

=item The package can be found at:

    https://moria.whyayh.com/rel/released/software/own/vid-tag/

=item Unpack the zip file to your "bin" dir.

Typical choices:

    /usr/local/bin
    $HOME/bin
    /opt/vid-tag

Just make sure the install dir is in your PATH env. var.

=back

=head3 First run of vid-tag

=over 4

=item cd to the directory with your video files. Copy the vid-tag.conf
file from the install dir. This is optional. If missing a default
version will be created.

    Run: vid-tag -n -e testevent

=item That will create or update ./vid-tag.conf and vid-tag-example.txt
files.

=item You can now edit the vid-tag.conf file, or use the command line
options to update the file. Mainly you want to change "testevent" to a
short ID that will be put in your renamed video files. See the -e
option.

=back

=head3 Tips

=over 4

=item See the -f option for how you can change the file naming
pattern, and the -t option for how you can change the Title pattern.

=item Use the -v option to see some progress information. Use -vv if
you want to see more progress details.

=item After each run, the vid-tag.conf file is updated with any
changes, and the vid-tag-example.txt file will summarize how the files
are modified.

=item Between each run you should probably remove everything in the
outputs/ directory. Or you can leave the files there and they will be
skipped from any changes.

=back

=head1 OPTIONS

=over 4

=item B<-e "pEventId">

Short event tag used in file names. It is also the Id used to access
the specific event details. If the pEventId is not found in
vid-tag.conf, then it will be added to vid-tag.conf.

Pattern token: B<%e>.  Config key: C<event.tag>. Required: "pEventId"

The value will be changed to lower-case and any spaces will be changed
to '_'

=item B<-E "pEventTitle">

Long event name used in the title.  Pattern token: B<%E>.
Config key: C<event.title>. Default: "Long event description."

=item B<-c "pCity">

City name.  Pattern token: B<%c>.  Config key: C<event.city>. Default:
"city name"

=item B<-C "pCaption">

Caption / description metadata.  Config key: C<com.caption>. Default:
"Copyright TERMS"

=item B<-p "pInitials">

Photographer's initials / short name (no spaces).  Pattern token: B<%p>.
Config key: C<com.name-short>.

=item B<-P "pName">

Photographer's full name.  Pattern token: B<%P>.
Config key: C<com.name-long>. Default: First Last

=item B<-R "pCopyright">

Copyright stamp. Config key: C<com.copyright> Default: "Copyright NAME YYYY"

=item B<-f "pFilePattern">

Output file-name pattern.  Config key: C<com.file-pat>. Default:
C<%d_%e_%p_%f>.

=item B<-t "pTitlePattern">

Title pattern. Config key: C<com.title-pat>. Default: C<%D, %c, %E, by %P.>

=item B<-k "pKeyword">

Comma-separated keyword list.  Config key: C<event.keyword>. Default:
"PBP, event"

=item B<-z "pTimeZone">

The TimeZone in which the input video files' B<CreateDate> values
were recorded.  When set to a value other than C<local> (or empty),
each file's CreateDate is converted from B<pTimeZone> to the host's
local time before it is used for the output filename, the title's
date tokens (B<%d>, B<%D>, B<%T>), the example file's "Create Date"
display, and the filesystem mtime applied via C<touch>.

The on-disk exif B<Create Date> in the output file is left unchanged
- only what vid-tag derives from it is shifted.

Pattern: C<UTC[+-]H> or C<UTC[+-]H:MM>.  The C<UTC> prefix is
case-insensitive (C<utc-1> is accepted).  POSIX TZ sign semantics
apply, so C<utc-1> represents a zone one hour B<ahead> of UTC.

Config key: C<event.time-zone>.  Default: C<local> (no conversion).

Examples:

    -z utc-1     # zone 1 hour ahead of UTC (e.g. CET in winter)
    -z UTC+8     # zone 8 hours behind UTC
    -z UTC-5:30  # zone 5h30m ahead of UTC (e.g. IST)
    -z local     # explicit "no conversion"

=item B<-n>

No-execute / dry-run.  Validate inputs and create config file
B<./vid-tag.conf>, but do not create output/, rename files, or modify
metadata.

=item B<-h>

Output this "long" usage help.  Same as C<-H long>.

=item B<-H pStyle>

Output usage in a specific style:

    short|usage - short usage, text
    long|text   - full usage, text
    man         - man page
    html        - HTML page
    md          - Markdown

=item B<-v>

Verbose output.  Repeat for more detail (B<-vv>).

    (default) - warning and above
    -v        - notice and above
    -vv       - info and above

=item B<-V>

Output the script's version.

=item B<-d>

Debug level. Default: 0
Each -d increments the debug level. Log messages will be print
if the debug level is greater than the log message's debug level.

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

This is the config file (F<./vid-tag.conf>) format.
The value of C<$gpEventId> is the primary key.

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
        time-zone  = UTC[+-]H[:MM] | local (pTimeZone) - optional
    [vid-tag "extra"]
        FILE1      = extra title text for FILE1 - optional
        FILE2      = extra title text for FILE2 - optional
        ...

The B<[vid-tag "extra"]> section is optional.  Each key is the exact
basename of an input file (case-sensitive); the value is the text that
will be appended to that file's EXIF Title.  Files without a matching
key are unaffected.

The append rule: a single space follows the title's trailing '.', then
the section value, then a closing '.'.  Example: with title
"S<2026-03-01 Sun, Redwood City, Service, by Bruce Rafnel.>" and
B<extra> entry "Service fragment", the resulting Title is
"S<2026-03-01 Sun, Redwood City, Service, by Bruce Rafnel. Service fragment.>".

The B<extra> keys typically contain '.' (e.g. "MVI_0107.MP4"), which
B<git config> cannot parse.  For this reason, the section is read and
written by an internal awk-based parser; it round-trips through
C<vid-tag.conf> unchanged on every run.  Edit it by hand.

time-zone - is optional.  Omit (or set to C<local>) to disable the
CreateDate timezone conversion.  See the B<-z> option for the format
and semantics.

=head1 RETURN VALUE

0 on success; non-zero on error.

=head1 ERRORS

    + No input files given.
    + exiftool is not installed or not on PATH.
    + File not found: <filename>

Warnings (processing continues):

    + No CreateDate in <file>; using file mtime
    + output/<file> already exists
    + target exists, skipping: <old> -> <new>
    + exiftool returned error on <file>

=for comment =head1 EXAMPLES

=head1 ENVIRONMENT

HOME, USER, Tmp, gpVerbose, gpDebug, gpConfLocal

=head1 FILES

=head2 vid-tag-N.N.zip

    vid-tag      - this script
    vid-tag.inc  - vid-tag functions
    vid-tag.conf - sample config file describing tags for an event
    bash-com.inc - utility functions
    LICENSE      - GPLv2

    ./vid-tag-example.txt - lists the changes to files
    ./output/      - generated directory, with renamed copies of files

=head2 Generated files

    vid-tag.conf - if missing, it will be created with defaults and CLI args
    vid-tag-example.txt - lists the changes to files based on vid-tag.conf
    output/      - generated directory, with renamed copies of files

=head2 vid-tag-test-N.N.zip

This package is for testing the vid-tag script. See the NOTES section

    vid-tag.test - optional unit and CLI integration tests
    shunit2.1    - unit test framework for vid-tag.test

=head2 vid-tag-test-input.zip (4.5G)

Optional video files used by vid-tag.test. Only needed for
the testCli*Slow tests. 

    MVI_0107.MP4
    MVI_0110.MP4
    MVI_0746.MP4

=head1 SEE ALSO

Required: Linux OS (see CAVEATS for Windows and MacOS)

Required: bash, exiftool, git config, ffmpeg, sed

Optional: vid-tag.test

=head1 NOTES

All of this code is maintained at:

    https://github.com/TurtleEngr/vid-tag

The releases are marked with vN.N tags.

=head1 CAVEATS

This script is mainly for Linux systems. However, if you have CygWin
installed on your Windows PC, and you have install the Required
packages (and set your PATH env.) this could work. For MacOS you'll
probably want to install "brew" to get the Required programs.

If you do get this running on Windows or MacOS, let me know, with an
"issue" report, what you had to do to get it running. For example
include programs needed, configuration directions, and any changes
you made to the scripts.

=head1 DIAGNOSTICS

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

=head1 BUGS

Report bugs at: https://github.com/TurtleEngr/vid-tag/issues

=for comment =head1 RESTRICTIONS

=head1 AUTHOR

Turtle Engineer

=head1 HISTORY

GPLv2 (c) Copyright (See LICENSE file for terms.)

cVer=1.3

=cut

EOF

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head1 vid-tag Internal Documentation

=internal-head3 fUsage pStyle

Select the type of help output. See -h and -H options.

=internal-head2 CONFIG KEY TO VARIABLE MAP

These are internal variables.

    Config key        Variable
    ---------         --------
    com.caption       gpCaption
    com.copyright     gpCopyright
    com.file-pat      gpFilePat
    com.name-long     gpNameLong
    com.name-short    gpNameShort
    com.title-pat     gpTitlePat
    event.tag         gpEventId
    event.city        gpEventCity
    event.keyword     gpEventKeyword
    event.time-zone   gpTimeZone
    event.title       gpEventTitle
    extra.<FILE>      gExtraMap[<FILE>]   (per-file title append)

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

=internal-head3 fCleanUp

Calls fComCleanUp to remove temp files and exit cleanly.

=internal-cut
EOF
} # fCleanUp

# --------------------------------
fSetGlobals() {
    fComSetGlobals

    # -------------------
    # Config file locations for fComGetConfig / fComSetConfig
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
    gpCaption=${gpCaption:-"Copyright TERMS"}
    gpCopyright=${gpCopyright:-"Copyright NAME YYYY"}
    gpEventCity=${gpEventCity:-"TBD"}
    gpEventFileList=${gpEventFileList:-""}
    gpEventKeyword=${gpEventKeyword:-"TBD"}
    gpEventId=${gpEventId:-""}
    gpEventTitle=${gpEventTitle:-"TBD"}
    gpFilePat=${gpFilePat:-'%d_%e_%p_%f'}
    gpNameLong=${gpNameLong:-"TBD"}
    gpNameShort=${gpNameShort:-"TBD"}
    gpTimeZone=${gpTimeZone:-""}
    gpTitlePat=${gpTitlePat:-'%D, %c, %E, by %P.'}

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
    # Per-file extras: populated by fLoadExtras, written back by
    # fSaveExtras.  Map is reset here; section text starts empty.
    gExtraMap=()
    gExtraSection=""

    # -------------------
    # Required and optional external programs
    fComCheckDeps "bash exiftool git ffmpeg sed" "cat"

    return

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fSetGlobals

Calls fComSetGlobals, then sets all script-specific globals.

Sets gpConfLocal to the standard vid-tag config paths.

Hard-coded defaults for every gpVar are applied here.  They are
overridden in order by: global conf, local conf, command-line options.

=internal-cut
EOF
} # fSetGlobals

# --------------------------------
fLoadConf() {
    # Read event-specific overrides from the local config file.
    # The section prefix is the current value of gpEventId, which has
    # already been set from the global conf (and possibly pre-scanned
    # from the command line via -e).
    local tId

    if [[ ! -f "$gpConfLocal" ]]; then
        fLog -p info -m "Local config not found: $gpConfLocal" -l $LINENO
        return 0
    fi

    if [[ "$gpEventId" = "tbd" || -z "$gpEventId" ]]; then
        fError -m "gpEventId not set; cannot read local config sections." -l $LINENO
    fi

    gpCaption=$(      fComGetConfig -l -k "$cName.com.caption"    -d "$gpCaption")
    gpCopyright=$(    fComGetConfig -l -k "$cName.com.copyright"  -d "$gpCopyright")
    gpFilePat=$(      fComGetConfig -l -k "$cName.com.file-pat"   -d "$gpFilePat")
    gpNameLong=$(     fComGetConfig -l -k "$cName.com.name-long"  -d "$gpNameLong")
    gpNameShort=$(    fComGetConfig -l -k "$cName.com.name-short" -d "$gpNameShort")
    
    gpTitlePat=$(     fComGetConfig -l -k "$cName.com.title-pat" -d "$gpTitlePat")

    # event.tag is the canonical source for gpEventId in local conf
    tId=$(fComGetConfig -l -k "$cName.$gpEventId.title")
    if [[ -z "$tId" ]]; then
        fLog -p warn -m "Event $gpEventId not found, it will be added to $gpConfLocal" -l $LINENO
    fi

    gpEventTitle=$(   fComGetConfig -l -k "$cName.$gpEventId.title"     -d "$gpEventTitle")
    gpEventCity=$(    fComGetConfig -l -k "$cName.$gpEventId.city"      -d "$gpEventCity")
    gpEventKeyword=$( fComGetConfig -l -k "$cName.$gpEventId.keyword"   -d "$gpEventKeyword")
    gpTimeZone=$(     fComGetConfig -l -k "$cName.$gpEventId.time-zone" -d "$gpTimeZone")

    gpEventId="${gpEventId// /_}"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLoadLocalConf

Reads the local config file (gpConfLocal, default ./vid-tag.conf) using
fComGetConfig -l.  The section prefix is the current gpEventId value.

If the file is absent, or gpEventId is not yet known, the function
returns silently with a warning.

=internal-cut
EOF
} # fLoadConf

# --------------------------------
fSaveConf() {
    # Write the current values to the local config file under the
    # [$gpEventId ...] section.

    if [[ -z "$gpEventId" ]]; then
        fError -m "Cannot save local config: gpEventId is not set." -l $LINENO
    fi

    fLog -p info -m "Saving local config: $gpConfLocal (tag=$gpEventId)" -l $LINENO
    fComSetConfig -l -k "$cName.com.caption"     -v "$gpCaption"
    fComSetConfig -l -k "$cName.com.copyright"   -v "$gpCopyright"
    fComSetConfig -l -k "$cName.com.file-pat"    -v "$gpFilePat"
    fComSetConfig -l -k "$cName.com.name-long"   -v "$gpNameLong"
    fComSetConfig -l -k "$cName.com.name-short"  -v "$gpNameShort"
    fComSetConfig -l -k "$cName.com.title-pat"   -v "$gpTitlePat"

    fComSetConfig -l -k "$cName.$gpEventId.title"     -v "$gpEventTitle"
    fComSetConfig -l -k "$cName.$gpEventId.city"      -v "$gpEventCity"
    fComSetConfig -l -k "$cName.$gpEventId.keyword"   -v "$gpEventKeyword"

    if [[ -n "$gpTimeZone" ]]; then
       fComSetConfig -l -k "$cName.$gpEventId.time-zone" -v "$gpTimeZone"
    fi

    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fSaveLocalConf

Writes the current effective values of all gp* config variables to the
local config file (gpConfLocal) under the [$gpEventId ...] sections,
using fComSetConfig -l.

Called when -s is present on the command line.

=internal-cut
EOF
} # fSaveConf

# --------------------------------
fLoadExtras() {
    # Read the [vid-tag "extra"] section from $gpConfLocal and populate
    # the gExtraMap associative array (keyed by exact, case-sensitive
    # file basename).  Also save the raw section text in gExtraSection
    # and STRIP the section from $gpConfLocal so subsequent git-config
    # based reads/writes (fComGetConfig / fComSetConfig) don't choke on
    # keys that contain '.' (e.g. "MVI_0107.MP4").
    #
    # Round-trip is completed by fSaveExtras which appends the saved
    # section back to $gpConfLocal at the end of the run.
    local tLine tKey tValue tTmp

    gExtraMap=()
    gExtraSection=""

    if [[ ! -f "$gpConfLocal" ]]; then
        return 0
    fi

    # Capture the section text verbatim (header + body lines).
    gExtraSection=$(awk '
        /^[[:space:]]*\[[[:space:]]*vid-tag[[:space:]]+"extra"[[:space:]]*\]/ {
            in_sec=1; print; next
        }
        /^[[:space:]]*\[/ { in_sec=0 }
        in_sec { print }
    ' "$gpConfLocal")

    if [[ -z "$gExtraSection" ]]; then
        return 0
    fi

    # Parse "key = value" lines into the map.  Skip the header,
    # blank lines, and '#' / ';' comments.
    while IFS= read -r tLine; do
        [[ "$tLine" =~ ^[[:space:]]*\[ ]] && continue
        [[ "$tLine" =~ ^[[:space:]]*$ ]]  && continue
        [[ "$tLine" =~ ^[[:space:]]*[\#\;] ]] && continue
        if [[ "$tLine" =~ ^[[:space:]]*([^=[:space:]][^=]*[^=[:space:]]|[^=[:space:]])[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            tKey="${BASH_REMATCH[1]}"
            tValue="${BASH_REMATCH[2]}"
            # Trim trailing whitespace from value
            tValue="${tValue%"${tValue##*[![:space:]]}"}"
            gExtraMap["$tKey"]="$tValue"
        fi
    done <<< "$gExtraSection"

    # Strip the [vid-tag "extra"] section from the file in place so
    # the rest of the run can use git config without errors.
    tTmp="${gpConfLocal}.vt$$"
    awk '
        /^[[:space:]]*\[[[:space:]]*vid-tag[[:space:]]+"extra"[[:space:]]*\]/ {
            in_sec=1; next
        }
        /^[[:space:]]*\[/ { in_sec=0 }
        !in_sec { print }
    ' "$gpConfLocal" > "$tTmp" && mv "$tTmp" "$gpConfLocal"

    fLog -p info -m "Loaded ${#gExtraMap[@]} extra entries from $gpConfLocal" -l $LINENO
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fLoadExtras

Read the [vid-tag "extra"] section from gpConfLocal into the
gExtraMap associative array.  Each "FILENAME = text" line becomes
gExtraMap["FILENAME"]="text".  Match against command-line file
basenames is exact and case-sensitive.

Side effects:

=internal-over 4

=internal-item gExtraMap is reset and populated.

=internal-item gExtraSection holds the original section text
(header + body) so fSaveExtras can re-emit it unchanged.

=internal-item The [vid-tag "extra"] section is removed from
gpConfLocal in place.  This is required because git config (used
by fComGetConfig / fComSetConfig) refuses to parse a file whose
keys contain '.', and typical filenames such as "MVI_0107.MP4"
have dotted extensions.

=internal-back

If gpConfLocal does not exist, the function returns silently
with an empty map and empty section.

=internal-cut
EOF
} # fLoadExtras

# --------------------------------
fSaveExtras() {
    # Re-attach the [vid-tag "extra"] section to $gpConfLocal.  The
    # text is whatever fLoadExtras captured at the start of the run,
    # so the section round-trips unchanged regardless of any other
    # writes to the file.
    if [[ -z "$gExtraSection" ]]; then
        return 0
    fi
    if [[ ! -f "$gpConfLocal" ]]; then
        return 0
    fi

    # Make sure the file ends with a newline before appending.
    if [[ -s "$gpConfLocal" && $(tail -c1 "$gpConfLocal" | wc -l) -eq 0 ]]; then
        echo >> "$gpConfLocal"
    fi
    printf '%s\n' "$gExtraSection" >> "$gpConfLocal"
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fSaveExtras

Append the saved gExtraSection (captured by fLoadExtras) back to
gpConfLocal.  Called once at the end of the script run, after
fSaveConf has finished writing the git-config-managed sections.

If gExtraSection is empty (no [vid-tag "extra"] section was
present at load time, or the run started with no conf file), this
function is a no-op.

=internal-cut
EOF
} # fSaveExtras

# --------------------------------
fPreScanOpts() {
    # First-pass option scan: extract only -e (event tag)
    # before loading the local config file.  The full getopts parse in
    # Main will apply all options after the config files are loaded.

    local OPTIND=1
    local OPTARG
    
    while (( $# > 0 )); do
        case "$1" in
            -e)
                gpEventId="${2// /_}"
                return 0
                ;;
            -h)
                fUsage long
                exit 0
                ;;
            -H)
                fUsage $2
                exit 0
                ;;
            -V)
                echo "vid-tag version: $cVer"
                exit 0
                ;;
            -*)
                # Unknown flag: skip it and its argument (if present)
                shift
                # If the next token isn't another flag, consume it too
                if [[ "${1-}" != -* && -n "${1-}" ]]; then
                    shift
                fi
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ -z "$gpEventId" ]]; then
        fError -m "Missing pEventId, see required -e option." -l $LINENO
    fi

    if [[ ! -f "$gpConfLocal" ]]; then
        fSaveLocalConf
    fi
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fPreScanOpts

Scans command-line arguments for -e and -s before the config files are
loaded.  This ensures that fLoadLocalConf uses the correct event tag
even when -e is supplied on the command line.

A full option parse is done later in Main after config loading.

=internal-cut
EOF
} # fPreScanOpts

# --------------------------------
fGetOpt() {
    local OPTIND=1
    local OPTARG
    local tArg

    while getopts :c:C:e:E:f:k:np:P:R:t:z:hH:vVd tArg; do
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
            z) gpTimeZone="$OPTARG" ;;
            # Common arguments
            h) fUsage long ;;
            H) fUsage "$OPTARG" ;;
            v) ((++gpVerbose)) ;;
            V) echo "vid-tag version: $cVer"
               exit 0
               ;;
            d) ((++gpDebug)) ;;
            # Problem arguments
            :)  fError -m "Value required for option: -$OPTARG" -l $LINENO ;;
            \?) fError -m "Unknown option: $OPTARG"             -l $LINENO ;;
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

    if [[ "${gpFilePat#*%}" = "${gpFilePat}" ]]; then
        fError -m "-t pFilePat is missing % options" -l $LINENO
    fi
    if [[ "${gpTitlePat#*%}" = "${gpTitlePat}" ]]; then
        fError -m "-t pTitlePat is missing % options" -l $LINENO
    fi

    # TimeZone format check.  Empty or "local" means no conversion.
    # Valid format: "UTC[+-]H[:MM]" (case-insensitive on UTC).
    if [[ -n "$gpTimeZone" && "$gpTimeZone" != "local" ]]; then
        if [[ ! "$gpTimeZone" =~ ^[Uu][Tt][Cc][+-][0-9]{1,2}(:[0-9]{2})?$ ]]; then
            fError -m "Invalid TimeZone: $gpTimeZone (expected UTC[+-]H[:MM] or 'local')" -l $LINENO
        fi
    fi

    if [[ $gpNoExec -ne 0 ]]; then
        # Don't check the files
        return 0
    fi

    if [[ -z "$gpEventFileList" ]]; then
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

=internal-head3 fValidate

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
    # When gpTimeZone is empty or "local", the input is echoed back
    # unchanged - the caller does not need to special-case the no-op.
    #
    # The 'date' command's "TZ=..." date-string prefix is used so that
    # POSIX TZ semantics apply: e.g. gpTimeZone="utc-1" represents a
    # zone 1 hour AHEAD of UTC (just as TZ="UTC-1" does in the env).
    # The output is in the host's local time, in exiftool's format.
    local pRaw="$1"
    
    local tDate
    local tFixed
    local tTime

    if [[ -z "$gpTimeZone" || "$gpTimeZone" = "local" ]]; then
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

=internal-head3 fConvertTimeZone "YYYY:MM:DD HH:MM:SS"

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

    gFileDateShort=$( 'date' -d "$tNorm" +"%Y-%m-%d")
    gFileDateLong=$(  'date' -d "$tNorm" +"%Y-%m-%d %a")
    gFileDateFull=$(  'date' -d "$tNorm" +"%Y-%m-%d_%H:%M:%S")
    gFileDateTouch=$( 'date' -d "$tNorm" +"%Y%m%d%H%M.%S")
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fConvertDate "YYYY:MM:DD HH:MM:SS"

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

=internal-head3 fReadFileDate pFile

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

=internal-head3 fApplyPattern pPattern pFile

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

=internal-head3 fCreateOutputDir

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

    tNewName=$(  fApplyPattern "$gpFilePat"  "$pBase")
    tNewTitle=$( fApplyPattern "$gpTitlePat" "$pBase")
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

=internal-head3 fExampleCollect pBase pCreateDate

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

    local -i tH
    local -i tM
    local -i tS
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
    IFS=':' read -r tH tM tS <<< "$tLength"
    IFS=' '

    # Strip any leading zeros so bash arithmetic doesn't treat them as octal.
    tH=$((10#$tH))
    tM=$((10#$tM))
    tS=$((10#$tS))

    # Same threshold as fProcessFile: <= 10 min → no split.
    ((tMin = tH * 60 + tM))
    if [[ $tMin -le 10 ]]; then
        return 0
    fi

    # ceil(total_seconds / 600) - matches the segment count ffmpeg's
    # -segment_time 00:10:00 muxer will emit.
    tNumParts=$(( (tMin * 60 + tS + 599) / 600 ))

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

    for (( tIdx=0; tIdx < tNumParts; tIdx++ )); do
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

=internal-head3 fExampleCollectSplit pBase pFile pCreateDate

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
        for (( tIdx=0; tIdx < gExampleIdx; tIdx++ )); do
            echo "    ${gExampleOrigNames[$tIdx]} -> $cOutputDir/${gExampleNewNames[$tIdx]}"
        done
        echo "Exif Changes:"
        for (( tIdx=0; tIdx < gExampleIdx; tIdx++ )); do
            echo "${gExampleNewNames[$tIdx]}"
            echo "    Title = ${gExampleTitles[$tIdx]}"
            echo "    Author = $gpNameLong"
            echo "    Artist = $gpCopyright"
            echo "    Copyright = $gpCopyright"
            echo "    Keywords = $gpEventKeyword"
            echo "    Caption = $gpCaption"
            echo "    Description = (see Caption)"
            echo "    Image Description = (see Caption)"
            echo "    Create Date = ${gExampleCreateDates[$tIdx]}"
            echo "    Date/Time Original = (see Create Date)"
            echo "    Modify Date = (see Create Date)"
            echo "    Track Create Date = (see Create Date)"
            echo "    Track Modify Date = (see Create Date)"
            echo "    Media Create Date = (see Create Date)"
            echo "    Media Modify Date = (see Create Date)"
        done
    } > "$cExampleFile"

    fLog -p info -m "Created $cExampleFile" -l $LINENO
    return 0

    # shellcheck disable=SC2317
    cat <<EOF >/dev/null
=internal-pod

=internal-head3 fExample

Build B<vid-tag-example.txt> in the current directory.  The file shows:

=internal-over 4

=internal-item 1. The (re-constructed) command line.

=internal-item 2. A "Files:" block listing each input file and its
intended renamed path under cOutputDir.

=internal-item 3. An "Exif Changes:" block listing the metadata tags
that vid-tag will write to each renamed file.

=internal-back

When gpNoExec is set, a single dummy entry is generated using
B<FILE.mp4> as the input name and the current wall-clock time as the
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
    local -i tH
    local -i tM
    local -i tS

    # Strip the label, keeping only "YYYY:MM:DD HH:MM:SS"
    tDate="${pRaw##*: }"

    # Split into date and time parts
    tTime="${tDate##* }"
    tDate="${tDate%% *}"

    IFS=':' read -r tH tM tS <<< "$tTime"
    IFS=' '

    # Remove any leading zeros for arithmetic
    tM=$((10#$tM))
    tH=$((10#$tH))

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

=internal-head3 fAddMin "pTimestamp" pMinutes

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
fProcessFile() {
    # Rename + tag a single file.  Must be called with CWD == ./output/
    local pFile="$1"

    local -i tH
    local -i tM
    local -i tS
    local -i tIncMin
    local tBase
    local tCmd
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
    tNewName=$(  fApplyPattern "$gpFilePat"  "$tBase")
    tNewTitle=$( fApplyPattern "$gpTitlePat" "$tBase")
    if [[ -n "${gExtraMap[$tBase]:-}" ]]; then
        tNewTitle="$tNewTitle ${gExtraMap[$tBase]}."
    fi

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
        -Copyright="$gpCopyright"
        -Artist="$gpCopyright"
        -Author="$gpNameLong"
        -Keywords="$gpEventKeyword"
        -Caption="$gpCaption"
        -Description="$gpCaption"
        -ImageDescription="$gpCaption"
    )
    if [[ -n "$gpTimeZone" && "$gpTimeZone" != "local" ]]; then
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
    tCmd+=( "$tBase" )
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
    IFS=':' read -r tH tM tS <<< "$tLength"
    IFS=' '
    ((tMin = $tH * 60 + $tM))
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
        ((tIncMin=tPart * 10))
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

=internal-head3 fProcessFile pFile

Process a single video file that has already been hard-linked into
cOutputDir.  Must be called with the working directory set to cOutputDir.

Steps:

=internal-over 4

=internal-item 1. Read CreateDate from file (fReadFileDate), which
applies fConvertTimeZone so gFileDate* globals hold local time.

=internal-item 2. Expand file-name and title patterns (fApplyPattern).

=internal-item 3. Run a single exiftool call to rename and set all
metadata.  When gpTimeZone is active (non-empty and not "local"), the
seven date/time exif fields (DateTimeOriginal, CreateDate, ModifyDate,
TrackCreateDate, TrackModifyDate, MediaCreateDate, MediaModifyDate) are
also written with the converted local time so the file metadata is
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
