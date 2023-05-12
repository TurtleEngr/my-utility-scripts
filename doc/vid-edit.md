# NAME

vid-edit - kdenlive edit

# SYNOPSIS

    vid-edit [-b] [-c] [-l] [-v KdenLiveVer] [-h] [FileName[.kdenlive]]

# DESCRIPTION

After committing all files in the current directory, run kdenlive with
the file passed in. The version of kdenlive will be picked out of the file.

The -v option can be used to define another version of kdenlive to be run on
the file. It is recommended that you only pick one major version ahead at a
time.

If the file is versioned, it will be committed before starting.  It is
recommended that you exit and start kdenlive frequently to checkpoint
your file.  kdenlive can sometimes end up with corrupted files. Look
at the version logs to check out previous versions to find a stable
one.  On exit, be sure to add any new files.

# OPTIONS

- **-b**

    Batch mode. Do not prompt for inputs.

- **-c**

    If defined, skip the CVS  checks and commits.

- **-l**

    Use the latest version. (See variable: $cLatestVer

- **-v KdenLiveVer**

    Pick a different kdenlive version.

    The archived versions are: 16.11, 16.12, 17.04, 17.12, 19.04, 19.08

    The current versions are: 18.12,  19.12, 20.04, 20.12, 21

    The AppImage program files will be found at:
    /rel/archive/software/ThirdParty/kdenlive/ (or /usr/local/bin/)

- **-h**

    This help.

# RETURN VALUE

# ERRORS

Many error messages may describe where the error is located, with the
following log message format:

    Program: PID NNNN: Message [LINE]

## Errors

Could not find \[FileName\], or it is not writable.

kdenliveversion not found. Is \[FileName\] a kdenlive file?

Could not find directory: \[AppImageDir\]

No version available for \[VER\]. \[VER\] is the lastest version. You will need to upgrade.

Not found: \[AppImage Binary\]\]

To fix, add \[FileName\] to a CVS repository.

\[CVS/Root\] is not mounted

Missing options.

Value required for option: \[OPTARG\]

Unknown option: \[OPTARG\]

Unknown options: \[OPTARG\]

## Warnings

VER is different from the file version: VER

# EXAMPLES

# ENVIRONMENT

# FILES

/tmp/kdenlive.log - output from command line. It is overwritten every time.

/rel/archive/software/ThirdParty/kdenlive - location of the kdenlive
AppImage binaries.

# SEE ALSO

logit

# NOTES

CVS is used for versioning, rather than the git, because it is easier to
remove large binary files and versions.

If you are working on a project where there is a lot of collaboration
AND all have a high speed network, the git would be a better
choice. However the will still be a need to remove old binary files
from the git repo, or it will become too large to be useable.

# CAVEATS

There is no warning, if you specify a version that is earlier than the
kdenlive file's version.

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

# HISTORY

$Revision: 1.13 $ $Date: 2023/05/12 01:16:38 $ GMT
