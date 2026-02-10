# NAME

hiearchy.sh - Convert full path names to hiearchy levels

# SYNOPSIS

        hiearchy.sh [-t] [-l N] [-d] <IN-FILE >OUT-FILE

# DESCRIPTION

Convert full path names to hiearchy levels.

# OPTIONS

- **-t**

    Output with one tab for each '/' in the input line.

    Default: no tabs, output "   |" for each '/' in the input line.

- **-l N**

    Number of levels to output.  If the number of '/' in the input line is
    greater than N, then the line is ignored.

- **-d**

    Only output directory lines, i.e. lines that end with '/'.

# RETURN VALUE

    0 - OK
    !0 - not OK

# ERRORS

Fatal Error:

Unknown options.

# EXAMPLES

Input file "foo.txt" has these lines:

    /tid-rel-stage/archive/ops/
    /tid-rel-stage/archive/ops/trunk/
    /tid-rel-stage/archive/ops/trunk/backup/
    /tid-rel-stage/archive/ops/trunk/backup/2010-05-13/
    /tid-rel-stage/archive/ops/trunk/backup/2010-05-13/safe.backup.xml
    /tid-rel-stage/archive/ops/trunk/backup/2011-10-19
    /tid-rel-stage/archive/ops/trunk/backup/2011-10-19/lead-uat1.trustedid.com.zip
    /tid-rel-stage/archive/ops/trunk/backup/2011-10-19/tid-sit3.trustedid.com.zip
    /tid-rel-stage/archive/ops/trunk/backup/2011-10-19/tid-uat1.trustedid.com.zip
    /tid-rel-stage/archive/ops/trunk/backup/2012-03-29/
    /tid-rel-stage/archive/ops/trunk/backup/2012-03-29/unsubscribe-db.schema.sql.gz

hierarchy.sh &lt;foo.txt

Outputs:

    /tid-rel-stage/archive/ops/
        |trunk/
        |   |backup/
        |   |   |2010-05-13/
        |   |   |   |safe.backup.xml
        |   |   |2011-10-19/
        |   |   |   |lead-uat1.trustedid.com.zip
        |   |   |   |tid-sit3.trustedid.com.zip
        |   |   |   |tid-uat1.trustedid.com.zip
        |   |   |2012-03-29/
        |   |   |   |unsubscribe-db.schema.sql.gz

hierarchy.sh &lt;foo.txt -d

Outputs:

    /tid-rel-stage/archive/ops/
        |trunk/
        |   |backup/
        |   |   |2010-05-13/
        |   |   |2011-10-19/
        |   |   |2012-03-29/

hierarchy.sh &lt;foo.txt -l 2

Outputs:

    /tid-rel-stage/archive/ops/
        |trunk/
        |   |backup/

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
