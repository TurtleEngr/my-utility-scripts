#!/bin/bash

# --------------------------------
function fUsage
{
	# Print usage help for this script, using pod2text.
	pod2text $0
	exit 1
	cat <<EOF >/dev/null
=pod

=head1 NAME

holiday.sh - Return 0 if holiday, else non-zero

Mainly for use in cron, to skip holidays.  For example:

=head1 SYNOPSIS

	holiday.sh [-h] [-d YYYY-MM-DD] [-t HH] [-w TAG]

=head1 DESCRIPTION

This script will read a file (default: /usr/local/etc/holidays.txt) to
see if "today" (or the -d date) is a holiday.

The -d option can be passed to see if that date is a holiday.

There can be zero or more -w TAG flags.

=head1 OPTIONS

=over 4

=item B<-h>

Print this help, then exit with a 1 return code.


=item B<-d YYYY-MM-DD>

Pass in the date to test for holiday.  Default: today

=item B<-w TAG>

One or more TAGs words can be specified (using multiple -w options).
This will activate any lines that contain the TAG words between []
characters.

=back

=head1 RETURN VALUE

Return 0 if the date is a holiday, else non-zero

=head1 ERRORS

=head1 EXAMPLES

B<Example cron job:>

 cHolidayFile="/projects/mgmt4/data/tid-closed.txt /projects/mgmt4/data/tid-holidays.txt"

 # send-mail will be run 5 min. after every hour, but not on holidays
 # M H d m w  user
 5 * * * *  root  /usr/local/bin/holiday.sh || /usr/local/bin/send-email

 # "send-mail -a" on a tuesday if monday was a holiday.
 # But only on the first hour of the day.
 # M H d m w    user
 5 0 * * tue  root  /usr/local/bin/holiday.sh -d $(date --date=yesterday +\%F) && /usr/local/bin/send-email -a

B<Example holiday files>

# /projects/mgmt4/data/tid-closed.txt
# Days when CS is not open. The cron jobs will assume Sat and Sun are
# not work days, so this file is for the holiday exceptions.
...........TBD

# /projects/mgmt4/data/tid-maintenance.txt
............TBD

=head1 ENVIRONMENT

cHolidayFile - This env. var. can contain a list of file name paths of
multiple holiday files.  Default: /usr/local/etc/holidays.txt

=head1 FILES

Format of holiday file (YYYY must be at the very beginning of lines):

	# comment (the full line will be ignored)
 	YYYY-MM-DD Any text following
 	YYYY-MM-DD [TAG] Any text following
 	YYYY-MM-DD [TAG] [TAG] Any text following
 	YYYY-MM-DD {SH-EH} Any text following
 	YYYY-MM-DD {SH-EH} [TAG] Any text following

[TAG] is optional.  The record will only be included if a -w TAG
matches, one or more of the [TAG] words.  If there is no [TAG], then
the record will be used.

{SH-EH} is optional. If the current time (or the -t TIME) is between
hours SH and EH (inclusive), and the date record's date matches the -d
option, then then this will be a match, so a 0 would be returned.  The
SH and EH hours are in 24 hour format, with leading zero.

=head1 SEE ALSO

=head1 NOTES

=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

[All possible messages the program can print out--and what they mean.]

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

Bruce Rafnel

=head1 HISTORY

$Revision: 1.3 $

=cut
EOF
}

# -----------------------------------------------------
if [ $# -ne 0 ]; then
	if [ "$1" = "-h"]; then
		fUsage
	fi
fi


# Define cHolidayFile env. to override this
cHolidayFile=${cHolidayFile:-/usr/local/etc/holidays.txt}

if [ $# -eq 0 ]; then 
	tToday=$(date '+%F')
else
	# Test: /usr/local/bin/holiday.sh 2011-11-24
	tToday=$(date --date="$1" '+%F')
fi

for i in $cHolidayFile; do
	if [ ! -f $i ]; then
		echo "$0 $i file not found."
		exit 1
	fi
done

grep -qs -m 1 "^$tToday" $cHolidayFile
tRet=$?
# echo Test: $tRet
exit $tRet
