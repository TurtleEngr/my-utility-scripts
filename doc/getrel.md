# getrel

# SYNOPSIS

    Config: ~/.getrel.cfg
    [export getrel_onlan=1]
    getrel [-r Name] [-g | -u | -d | -s] [-b] [-f] [-l] [-L] [-h] [-x]
        -r repo - default: rel          -f force
        -g - get, download              -l - local (not recursive)
        -u - upload                     -L - same as getrel_onlan=1
        -d - get all directories        -h - this help
        -s - status                     -x debug
        -b - batch, no prompts

# DESCRIPTION

Get local copies of files from the remote "rel" repository.  Mainly
this is used for large video, audio, and binary files.

If -L option or env. var. getrel\_onlan is set to 1, then the
remote.${pRel}.host-lan name will be used, instead of the
remote.${pRel}.host-wan name.

# OPTIONS

- **-r Name**

    Repository name, in the config file. Default: rel

- **-g**

    Get files, recursively, from the remote server, from the remote dir
    that is equivalent to the local dir.  Newer local files will not be
    overwritten. If the -f option is used, then the remote files can
    overwrite any local files.  If the -l option is used, then only the
    current local dir is updated (i.e. not recursive).  If you are not
    cd'ed in a "local" rel dir, then output a warning, and do nothing.

- **-u**

    Upload files, recursively, to the remote server, to the remote dir
    that is equivalent to the local dir.  Only files that are not on the
    remote server will be uploaded.  If -f option, then update all remote
    files, but only if the local file is "newer" If you are not cd'ed in a
    "local" rel dir, then output a warning, and do nothing.

- **-d**

    Update the local dir area with all the remote dirs.  Required to run
    this once.  Running it again, new dirs will be added.

- **-s**

    Show the status of the -r rel dirs.

- **-f**

    Force option. Newer source files will replace older files destination files.

    The default method is to ignore existing files, i.e. to only update
    missing files.

- **-l**

    Local dir only option (not recursive).  For use with the -g and -u
    options

- **-L**

    This is the same as setting: getrel\_onlan=1

- **-h**

    Print this help

- **-x**

    Set debug on. Just show what would be done.

# RETURN VALUE

# ERRORS

\* Local rel dirs are not writable.

\* Not in a local rel dir, when using the -g or -u options.

# EXAMPLES

# ENVIRONMENT

getrel\_onlan, GIT\_CONFIG, HOME, USER

# FILES

## Config File: $HOME/.getrel.cfg

    # Default
    [remote]
           home = /mnt/asimov.data3/rel
           sym = /rel
           host-wan = moria.whyayh.com
           host-lan = asimov.lan
           user = bruce
    [local]
           # -l
           home = /mnt/plasma.data1/rel
           sym = /rel
    # Named
    [remote per-rel]
           home = /home/bruce/per-rel
           sym = /home/bruce/per-rel
           host-wan = moria.whyayh.com
           host-lan = asimov.lan
           user = bruce
    [local per-rel]
           home = /home/bruce/per-rel
           sym = /home/bruce/per-rel
    [opt]
           exclude = --exclude=.svn --exclude=.git --exclude=CVS --exclude=cachefiles
           # -d
           dir = -rvptgoPl -f+_*/ -f-_*
           # -g
           get = -vptgoPl
           get-no-force = --ignore-existing
           # -gf
           get-force = --update
           # -u
           update = -vptgoPl
           update-no-force = --ignore-existing
           # -uf
           update-force = --update

# SEE ALSO

rsync, git config

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

Bruce Rafnel

# HISTORY
