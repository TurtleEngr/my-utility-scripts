# NAME

map-pkg - DESCRIPTION

# SYNOPSIS

        map-pkg [-h[elp]] [-v[erbose] [-d[ebug Level] [-a[ll] All] File...

# DESCRIPTION

This is mainly used for making a csv file that shows where packages
are used.  The All file, contains the list all of the possible
packages, across all servers.  Then each file passed, contains the
list of all package on that server.

Usually the version numbers are removed from the package names.  This
needs to be done manually, or with another script, because the version
numbers do not follow a "regular" pattern.

# OPTIONS

- **-a\[ll\] All**

    This a list of all the lines in all of the files.

    Default: the contents of all the Files will be concatinated, and set
    to only have "unique" lines.

- **File**

    One or more files. The files should contain unique names.

- **-help**

    This help

# RETURN VALUE

\[What the program or function returns if successful.\]

# ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following: (FILE:LINE) \[PROGRAM:LINE\]

# EXAMPLES

Generate input files:

        dpkg -l | \
                awk '{print \$2}' | \
                egrep -v 'Status=|Err.=|^Name\$' | 
                sort -u >server1.pkg

Create the all input file:

        cat *.pkg | sort -u >pkg.all

Generate the map-pkg.csv file, which shows what is common across all
files:

        map-pkg.pl -a pkg.all *.pkg

or
 	map-pkg.pl \*.pkg

# ENVIRONMENT

$cmclient, $HOME

# FILES

Input files:

Blank lines and lines beginning with '#' will be ignored.

Leading and trailing white space will be trimmed.

Each line will be treated as one "key".  Lines must match exactly for
them to be listed with an 'x' in the column for that file.

# SEE ALSO

# NOTES

# CAVEATS

\[Things to take special care with; sometimes called WARNINGS.\]

# DIAGNOSTICS

\[All possible messages the program can print out--and what they mean.\]

# BUGS

\[Things that are broken or just don't work quite right.\]

# RESTRICTIONS

\[Bugs you don't plan to fix :-)\]

# AUTHOR

Bruce Rafnel

# HISTORY

Revision: 1.7
