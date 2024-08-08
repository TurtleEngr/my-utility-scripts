<div>
    <hr/>
</div>

# NAME mksymlink

Save and restore symlinks to/from .symlink.$HOSTNAME definition files.
If .symlink.$HOSTNAME does not exist for restore, then look for
'.symlink'.

# SYNOPSIS

        mksymlink [-s] [-r] [-c] [-f]
                  [-h] [-H pStyle] [-v] [-x] [-T pTest]

# DESCRIPTION

CVS does not save symlinks. git saves symlinks, but they may not work.
This tool will save symlink definitions, in the current directory,
and save them in host-specific files named .symlink.$HOSTNAME (-s).

Then the tool can be used to restore (-r) or check (-c) the symlinks
in the current directory against the .symlink.$HOSTNAME file. If you
are on a different host, then copy from an existing .symlink.\* file
and use the check (-c) option to see if it will work, and adjust as
needed.

# OPTIONS

- **-s**

    Save symlinks to .symlink.$HOSTNAME

    You need to manually rename .symlink.$HOSTNAME to .symlink if the
    symlinks will be the same across different hosts.

    Convert $HOME/ in links to '~/'.

    Only file symlinks are saved. Directory symlinks are ignored, unless
    the -f option is used.

    Only current dir symlinks are saved.

    Symlink pointing to missing files will not be saved (see warning
    output)

    This option will create a new .symlink.$HOSTNAME, so you should do -c
    and -r first to not loose links. Also version the .symlink.$HOSTNAME
    files before updating them.

    If .symlink.$HOSTNAME already exists, then it will be moved to a
    backup version, .symlink.$HOSTNAME.sav~

- **-r**

    Restore symlinks defined in .symlink.$HOSTNAME or .symlink if
    .symlink.$HOSTNAME is not found.

    Skip the ones were the destination file does not exist.

    Skip symlinks that are already defined, unless -f option is used.

    Error if .symlink.$HOSTNAME and .symlink files are missing.

- **-f**

    With the -r option, force existing symlinks to be updated if they
    already exist.

    With the -s option, force saving symlinks to directories.

- **-c**

    Check simlinks.

    Warning if an existing symlink does not point to an existing file (or
    directory).

    Warning if links in .symlink.$HOSTNAME or .symlink are not found in current dir.

    Warning if files are not found for the links in .symlink.$HOSTNAME or .symlink

    Error if .symlink.$HOSTNAME and .symlink files are missing.

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
            int         - Also output internal documentation as text.
            int-html    - Also output internal documentation as html.
            int-md      - Also output internal documentation as markdown.

- **-v**

    Verbose output. Default is is only output (or log) messages with
    level "warning" and higher.

    \-v - output "notice" and higher.

    \-vv - output "info" and higher.

- **-x**

    Set the gpDebug level. Add 1 for each -x.
    Or you can set gpDebug before running the script.

    Only show what would be done, when using the other options.

    See: fLog and fLog2 (Internal documentation)

- **-T pTest**

    Run the unit test functions in this script.

    "-T all" will run all of the functions that begin with "test".
    Otherwise "pTest" should match the test function names separated with
    spaces (between quotes).

    "-T list" will list all of the test functions.

    "-T com" will run all the tests for bash-com.inc

    For more details about shunit2 (or shunit2.1), see
    shunit2/shunit2-manual.html
    [Source](https://github.com/kward/shunit2)

    See shunit2, shunit2.1

    Also for more help, use the "-H int" option.

## Globals

These are globals that may affect how the script runs. Just about all
of these globals that begin with "gp" can be set and exported before
the script is run. That way you can set your own defaults, by putting
them in your ~/.bashrc or ~/.bash\_profile files.

The the "common" CLI flags will override the initial variable settings.

- **Tmp**

    This is the top directory where tmp file will be put.

    Default: /tmp/$USER/mksymlink/

    if gpDebug is 0, temp files will usually include the PID.

- **gpVerbose**

    If set to 0, only log message at "warning" level and above will be output.

    If set to 1, all non-debug messages will be output.

    See -v, fLog

    Default: 0

- **gpDebug**

    If set to 0, all "debug" and "debug-N" level messages will be skipped.

    If not 0, all "debug" level messages will be output.

    Or if "debug-N" level is used, then if gpDebug is <= N, then the
    log message will be output, otherwise it is skipped.

    See -x

# RETURN VALUE

0 if OK

!0 if Errors

# ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following log message format:

    Program: PID NNNN: Message [LINE](ErrNo)

# EXAMPLES

# ENVIRONMENT

See Globals section for details.

HOME, HOSTNAME, gpVerbose, gpDebug

# SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

# DIAGNOSTICS

To verify the script is internally OK, run: mksymlink -T all

# BUGS

Dir symlinks are not saved. (why not?)

# HISTORY

GPLv3 (c) Copyright 2022
