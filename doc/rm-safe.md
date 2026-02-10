# NAME

rm-safe - If recursive remove, first remove symlinks. Also can just mv files.

# SYNOPSIS

rm-safe \[-f\] \[-r\] \[-R\] \[-m\] \[-l\] \[-i\] \[-v\] \[-x\] \[-h\] FILES

    -f - force remove            -v - verbose
    -r,-R - recursive remove     -x - debug, do nothing
    -m - move files              -h - more help
    -l - log to syslog           FILES - one or more dirs or files
    -i - prompt before removing

# DESCRIPTION

This script's main purpose is to remove all symlinks, when the -r option is used. Many implementations of rm, will follow symlinks, which could lead to unintended removes of files outside of the expected levels.

Most interactive rm options are not supported, because this is mainly for use in scripts.

The -m option will try to move files to tmp dirs, rather than remove files.

## Other safety features

\* If you are cd'ed to the top / dir, rm-safe will exit with an error. Using wild cards while at that level could be very destructive. Double check what you are doing and use the standard 'rm'.

\* If you specify an absolute path, and it has less than two directory levels, then rm-safe will exit with an error. Double check what you are doing and use the standard 'rm'.

# OPTIONS

- **-f**

    Force remove. And turns off -i option.

- **-r, -R**

    Recursive removal. First symlinks will be removed.

- **-m**

    Move files tmp dir.
     If root user use:  $Tmp, or /var/tmp, or /tmp
     If not root user use:  $Tmp, or $HOME/tmp, or /var/tmp, or /tmp

    The -r option is ignored.

- **-l**

    Send log messages to syslog.

- **-i**

    Interactive prompt for removals. This turns off the -f option.

- **-h**

    This help.

- **-v**

    Verbose output.  Sent to stderr.

- **-x**

    Debug mode.  Do nothing. Just show what would be done. Multiple x options will give more debug output.

        -x - show command that would be executed
        -xx - also show the symlinks that would be removed
        -xxx - also show all internal variable options set

- **FILES**

    One or more directories or files.

# RETURN VALUE

    0 - OK
    1 - error

# ERRORS

crit: No files were specifed

crit: Already removed: FILES - Nothing to do, the file(s) are already removed

crit: Unknown option: ARG

crit: Invalid option: ARG

crit: Value required for option: ARG

crit: PWD = / - dangerous, so not allowed.

crit: FILE has less than 2 dir levels - dangerous, so not allowed

Many error messages may describe where the error is located, with the
following log message format:

    Program[PID] LEVEL: Message [LINE](ErrNo)

# EXAMPLES

# ENVIRONMENT

    $HOME
    $USER
    $Tmp - Optional. Define directory for -m option.

# FILES

# SEE ALSO

rm, find, mv, logger

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

There is no check to see if there is enough space to move files to a tmp dir.

# RESTRICTIONS

Most interactive rm options are not supported.

# AUTHOR

BAR

# HISTORY

$Revision: 1.18 $ $Date: 2026/02/10 20:38:38 $ GMT
