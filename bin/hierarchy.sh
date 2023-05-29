#!/bin/bash
# Usage:
#       heirarchy.sh

# --------------------------------
function fUsage() {
    # Print usage help for this script, using pod2text.
    pod2text $0
    exit 1
    cat <<EOF >/dev/null
=pod

=head1 NAME

hiearchy.sh - Convert full path names to hiearchy levels

=head1 SYNOPSIS

        hiearchy.sh [-t] [-l N] [-d] <IN-FILE >OUT-FILE

=head1 DESCRIPTION

Convert full path names to hiearchy levels.

=head1 OPTIONS

=over 4

=item B<-t>

Output with one tab for each '/' in the input line.

Default: no tabs, output "   |" for each '/' in the input line.

=item B<-l N>

Number of levels to output.  If the number of '/' in the input line is
greater than N, then the line is ignored.

=item B<-d>

Only output directory lines, i.e. lines that end with '/'.

=back

=head1 RETURN VALUE

 0 - OK
 !0 - not OK

=head1 ERRORS

Fatal Error:

Unknown options.

=head1 EXAMPLES

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

hierarchy.sh <foo.txt

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

hierarchy.sh <foo.txt -d

Outputs:

    /tid-rel-stage/archive/ops/
        |trunk/
        |   |backup/
        |   |   |2010-05-13/
        |   |   |2011-10-19/
        |   |   |2012-03-29/

hierarchy.sh <foo.txt -l 2

Outputs:

    /tid-rel-stage/archive/ops/
        |trunk/
        |   |backup/

=head1 ENVIRONMENT

=head1 FILES

=head1 SEE ALSO

=head1 NOTES

=head1 CAVEATS

=head1 DIAGNOSTICS

=head1 BUGS

=head1 RESTRICTIONS

=head1 AUTHOR

=head1 HISTORY

=cut
EOF
    exit
} # fUsage

# ==================================================

# ---------------------
# Config
cAWK=awk
which nawk 2>/dev/null 1>&2
if [ $? -eq 0 ]; then
    cAWK=nawk
fi
which gawk 2>/dev/null 1>&2
if [ $? -eq 0 ]; then
    cAWK=gawk
fi

# ---------------------
# Defaults

# No tabs
pTab="s/        /   |/g"

# Max level
pLevel=200

# All files
pDirOnly="cat"

# ---------------------
while getopts :hl:td tArg; do
    case $tArg in
        h) fUsage ;;
        l)
            pLevel=$OPTARG
            let pLevel=pLevel-1
            ;;
        t) pTab="" ;;
        d) pDirOnly="grep '/$'" ;;
        :)
            echo "Error: Value required for option: $OPTARG"
            exit 1
            ;;
        \?)
            echo "Error: Unknown option: $OPTARG"
            exit 1
            ;;
    esac
done
let tOptInd=OPTIND-1
shift $tOptInd
if [ $# -ne 0 ]; then
    echo "Error: Unknown option: $*"
    exit 1
fi

# ---------------------
# Process the stdin

eval $pDirOnly | $cAWK -v pLevel=$pLevel '
NR == 1 {
        # Output first line in full
        print $0
        tTrim = gsub("[^/]*/", "", $0)
        next
}
{
        tEnd = sub("/$","",$0)
        tLevel = gsub("[^/]*/", "", $0)
        if ((tLevel - tTrim) > pLevel) {
                next
        }
        for (i=1; i<=(tLevel-tTrim); i++) {
                printf("\t")
        }
        if (tEnd) {
                print "\t" $0 "/"
        } else {
                print "\t" $0
        }
}
' | sed "$pTab"
