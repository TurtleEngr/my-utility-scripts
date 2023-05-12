# NAME

cvs-rm-ver - remove all version except HEAD version for files

# SYNOPSIS

        cvs-rm-ver [-b] [-n] [-h] [-l] [-v] [-x[x..]] Files...

# DESCRIPTION

This command will remove all CVS revisions except the HEAD version.
This is mostly useful for binary files because that will save
space. The -b option can be used to limit this operation only for
files with the -kb setting.

The command is optimized to do nothing if there is only one revision.

This operation can only be undone by restoring the File,v file on the
repository server.

# OPTIONS

- **-b**

    Only remove revisions from binary files.

- **-n**

    No execute. Just list the files that will have their revisions trimmed.

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

# ERRORS

Many error messages may describe where the error is located, with the
following log message format:

    Program: PID NNNN: Message [LINE](ErrNo)

## Fatal Errors:

Missing file names on command line.

File not found.

Not in a CVS directory.

## Warnings:

Skipping directory.

# EXAMPLES

# ENVIRONMENT

    $CVS_RSH

# FILES

    CVS/

# SEE ALSO

    cvs admin -o ::HEAD
    trans-sp

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

There could be problems if revisions have symbolic names.

The file names must not contain spaces or weird special characters.
They should only use the characters: \[a-zA-Z\]\[0-9\]\[.-\_\]

# RESTRICTIONS

# AUTHOR

# HISTORY

    $Revision: 1.3 $;
    $Date: 2023/05/12 01:16:36 $ GMT
