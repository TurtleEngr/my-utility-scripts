# NAME

vid-cp2rel - DESCRIPTION

# SYNOPSIS

        vid-cp2rel -d RelDir [-u] FileList
                   [-h] [-l] [-v] [-x]

# DESCRIPTION

Copy each FileName in FileList to the specified RelDir directory.
Only versioned files can be copied with the is script to a
RelDir. "cvs commit" will be run, to be sure the file has been saved.

The destination file name will be set to: ProjectName\_Date\_Ver\_FileName

    ProjectName - /home/video/[ProjectName]
    Date - date for the HEAD version
    Ver - HEAD version

# OPTIONS

- **-d RelDir**

    Destination RelDir:

        arc|archive - RelDir=/rel/archive/video/own/[YYYY-MM-DD]/

        dev|develop|development - RelDir=/rel/development/video/[ProjectName]/

        rel|release|released - RelDir=/rel/released/video/[ProjectName]/

- **-u**

    Run "getrel -ulL" in the destination dir (RelDir) to upload any new or
    modified files.

- **-h**

    This help.

- **-l**

    Send log messages to syslog.

- **-v**

    Verbose output.  Sent to stderr.

- **-x**

    Debug mode.  Do nothing? Don't log to syslog. Multiple x options turns
    on more debug output.

# RETURN VALUE

0 - if OK

!0 - if error

# ERRORS

Many error messages may describe where the error is located, with the
following log message format:

    Program: PID NNNN: Message [LINE](ErrNo)

    Missing options.
    Value required for option: OPT
    Unknown option: OPT
    Missing files
    Invalid -d option: RelDir
    You are not in a /home/video project dir
    You are not in a CVS working dir
    /mnt/usb-video is not mounted
    cvs commit error with File

# EXAMPLES

You are cd'd in /home/video/skit/src/final and it has files:

    Name           HEAD    Date
    raw-4up.mp4    1.2     2018-12-24
    raw-scene2.mp4 1.3     2018-12-26
    editor-1.mp4   1.1     2019-01-10
    editor-2.mp4   1.1     2019-01-15
    editor-3.mp4   1.8     2019-02-01
    final-1.mp4    1.1     2019-03-18
    final-3.mp4    1.5     2019-04-16
    trailer-1.mp4  1.2     2019-03-19
    trailer-2.mp4  1.4     2019-04-17

    vid-cp2rel -d archive raw*

           /rel/archive/video/own/2018-12-24/skit_2018-12-24_1.2_raw-4up.mp4
           /rel/archive/video/own/2018-12-26/skit_2018-12-26_1.3_raw-scene2.mp4

    vid-cp2rel -d dev editor*

           /rel/development/skit/skit_2019-01-10_1.1_editor-1.mp4
           /rel/development/skit/skit_2019-01-15_1.1_editor-2.mp4

    vid-cp2rel -d release final-3* trailer*

           /rel/released/skit/skit_2019-04-16_1.5_final-3.mp4
           /rel/released/skit/skit_2019-03-19_1.2_trailer-1.mp4
           /rel/released/skit/skit_2019-04-17_1.4_trailer-2.mp4

# ENVIRONMENT

# FILES

# SEE ALSO

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

# HISTORY

$Revision: 1.17 $ $Date: 2024/11/09 20:12:20 $ GMT
