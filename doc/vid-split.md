# NAME

vid-split - Split a video file into multiple files. (Can also join files.)

# SYNOPSIS

    vid-split [-d | -j | -m Min | -s Size] [-h] [-x] File.mp4

# DESCRIPTION

Split File.mp4 into multiple files that are no more than -m minutes in
length. Only files that end with 'mp4' (or MP4) are supported for the -m option.

Or split File.mp4 into multiple files that are no more than -s
megabytes in size. Any file video file format can be used with this
option.

# OPTIONS

- **-d**

    Just list the duration and size of File.mp4.

- **-m Min**

    Define the maximum number of minutes for each split file. Range limit:
    10 to 60. If < file duration, then nothing is done. This option will
    generate separate mp4 files that are standalone.

    Output file pattern for -m 20

        Base-000.mp4
        Base-020.mp4
        Base-040.mp4
        ...

- **-s Size**

    Define the maximum size in MegaBytes for each split file. Range limit:
    10 to 1900.  The files will not be valid video (or audio) files; they
    will need to be concatinated together in the order they were split.

    Output file pattern for -s 200

        Base.mp4-000
        Base.mp4-001
        Base.mp4-002
        ...

- **-j**

    The File.mp4 will be created from the files that correspond to the -m
    or -s options.

    If the File.mp4 exists it will be renamed to File.mp4.sav. If File.mp4.sav
    exists, the script will do nothing and exit.

- **-h**

    This help.

- **-x**

    Debug mode.  Do nothing. Just list the ffmpeg commands that will be run.

# RETURN VALUE

\[What the program or function returns if successful.\]

# ERRORS

Missing options.

Value required for option: \[OPT\]

Unknown option: \[OPT\]

Missing file name

Only one file name is allowed.

Could not find: ffmpeg"

Could not find: split"

Must include one of -d, -j, -m, or -s option.

\[FILE\] file is not found or is not readable

\[FILE\] exists. Remove or rename it.

Number must be between \[Min\] and \[Max\]

Invalid extension for file: \[FILE\]

Could not found any matching files to join.

Cannot figure out which files to join. There are -s and -m
patterns. Remove one set.

# EXAMPLES

## -d example

Size of file.

    vid-split -d cam1-short.mp4
    vid-split -d cam2-short.mp4

Output:

    cam1-short.mp4 Duration: 00:54:48.42 Size: 2714Mb
    cam2-short.mp4 Duration: 00:22:18.04 Size: 904Mb

## -m example

Split file into 15 minute files:

    vid-split -m 15 cam1-short.mp4
    vid-split -m 15 cam2-short.mp4

Output:

    cam1-short-000.mp4 Duraton: 00:15:00.00
    cam1-short-015.mp4 Duraton: 00:15:00.00
    cam1-short-030.mp4 Duraton: 00:15:00.00
    cam1-short-040.mp4 Duraton: 00:09:48.42

    cam2-short-000.mp4 Duraton: 00:15:00.00
    cam2-short-015.mp4 Duraton: 00:07:18.04

## -s example

Split files into 500Mb files.

    vid-split -s 500 cam1-short.mp4
    vid-split -s 500 cam2-short.mp4

Output:

    cam1-short.mp4-000 Size: 500Mb
    cam1-short.mp4-001 Size: 500Mb
    cam1-short.mp4-002 Size: 500Mb
    cam1-short.mp4-003 Size: 500Mb
    cam1-short.mp4-004 Size: 500Mb
    cam1-short.mp4-005 Size: 214Mb

    cam2-short.mp4-000 Size: 500Mb
    cam2-short.mp4-002 Size: 404Mb

# ENVIRONMENT

# FILES

# SEE ALSO

ffmpeg, split

# NOTES

If a video file is over 2GB in size, cvs will not be able to version
it across the network. So this script will use ffmeg to split the
video file into separate files.  If the resulting files are still over
2GB, then use a smaller -m value (or use the -s option).

Sources for ffmpeg split and join mp4 files:
https://superuser.com/questions/140899/ffmpeg-splitting-mp4-with-same-quality
https://trac.ffmpeg.org/wiki/Concatenate

Another solution is to use "split"

    split -a 3 -d -b 1500M File.mp4 File.mp4-

or

    vid-split -s 1500 File.mp4

But before you can use the split files they will need to joined with:

    cat File.mp4-* >File.mp4

or

    vid-split -j File.mp4

# CAVEATS

# DIAGNOSTICS

Use -x to see the ffmpeg or split commands that would be executed,
with no -x option.

# BUGS

# RESTRICTIONS

# AUTHOR

# HISTORY

$Revision: 1.12 $
