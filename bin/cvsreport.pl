#!/usr/bin/perl

=pod

(c) Copyright 2002 by  Computer

=head1 NAME

cvsreport.pl - Report changes in CVS

=head1 SYNOPSIS

 cvsreport.pl
	-co

	-root RootPath
	-dir RepositoryPath

	-from Tag|Date
	-to Tag|Date

	-show files,numrev,diff,add,del
	-sort name|numrev|diff|add|del

	-html
	-rawfile RawFileName

	-help
	-fmthelp text|html|man
	-debug Level
	-verbose

=head1 DESCRIPTION

For a given list of CVS directory names (relative to the CVSROOT),
generate a summary report, for the number of lines that have changed
between the specified CVS version.

Report the total number of lines across all files, in the directory
(recursively), that were: deleted or added.

For each file in each dir., list the number of lines: deleted or
added. (-show files)

Select the revision from/to range by: tags or dates. (-to, -from)

Output an HTML report. (-html)

Also output a file with the raw report values represented as Perl hash
variables.  This will be useful for debugging and for writing other
reporting scripts. (-rawfile)

=head1 OPTIONS

=over 4

=item B<-co>

If the files are already checked out, and you are cd'ed into the
directory that you want for the report.  If this option isn't given,
then "rlog" will be used (i.e. there is no need to checkout the
files).

Note: this should not be a "development" directory, i.e. no files
should be modified, so that "cvs update" will always update all files.

=item B<-root RootPath>

Specify the CVSROOT directory.  ":ext:" can be used, but the CVS_RSH
env. var.  will need to be defined before the script is run.

Default: use the value in CVS/Root, else use the CVSROOT env. var,
else error.

This option is Ignored if "-co" is used.

=item B<-dir RepositoryPath>

"RepositoryPath" is a directory name, relative to CVSROOT.  More than
one -dir can specified.

This option is Ignored if "-co" is used.

=item B<-from Tag|Date>

Earliest date or tag.  If "yesterday" is used, then a date 24 hours
before now will be used.  Default: version 1.1 (BASE) for all files.

=item B<-to Tag|Date>

Latest date or tag.  If "today" is used, then this implies HEAD.
Default: HEAD

If the "-co" option is used, then the current directory will be
updated to this date or tag.

=item B<-html>

Specify this option to output the HTML formatted report.

=item B<-show files,numrev,diff,add,del>

This option controls what is shown in the HTML report.  One or more
of these options can be specified.

files - show the individual files, rather than just the directories.
If "files" isn't on the show list, then the number of changed files
will be output.

numrev - show the number of revisions.

diff - show the number of lines added plus the number of lines deleted.

add - show the number of lines added.

del - show the number of lines deleted.

Default: numrev,diff,add,del

=item B<-sort name|numrev|diff|add|del>

This option will define the sort column.  Only one can be specified.
Note: if the column isn't shown (see -show), the results could be
confusing.

If two numbers are equal, then the names will be used as a secondary
sort key.

Default: numrev

=item B<-rawfile RawFileName>

If specified output the Perl variables, used to generate the report
totals, to RawFile.  This file's format will be suitable for inclusion
in other Perl scripts (with eval).

=item B<-help>

This help.

=item B<-debug Level>

Level is a number between 0 and 100.  If set to 0, debug is off
(default: 0).

Larger debug levels output more debug messages.  The debug messages
include the debug level number, so that you can see how to turn them
off.

Setting debug to 1 or larger, will also turn on the verbose option.

=item B<-verbose>

If this is set, output verbose status messages.

=back

=head1 RETURN VALUE

=head1 ERRORS

=head1 EXAMPLES

=head1 ENVIRONMENT

=head1 FILES

=head1 SEE ALSO

cvs rlog

=head1 NOTES

Date format:

 YYYY-MM-DD [HH:MM[Z]]

Adding a Z to the time, will define the time as Zulu (UTC), otherwise
local time will be used.

=head1 CAVEATS

1. The directory list is limited to the same repository.  I.e. the
CVSROOT doesn't change.

Enhancement: Support different CVSROOTs.  However, tag names used in
the ranges may not make sense across multiple repositories.

2.Binary files (i.e. with the -kb option) will not be included in the
report.

Enhancement: If a binary file has been changed, the number of versions
in the range could be reported in the detailed report.

3. Changes are reported for single ranges.  If a change history is
desired, then a simple wrapper script can be used to step through the
different ranges (use the output file of raw Perl variables).

4. Summaries are limited to single directories.  If multiple
directories need to be merged into a single "category", then a wrapper
script would be the best way of doing this.

5. Files: added or deleted may be ignored.

Enhancement: make a summary report of these files and list the file
names in the detailed report.  However for this to work, the script
may need to run on the cvs server.

6. "Moved" files can not be handled by cvsreport.  This is a CVS
limitation.

7. Files with zero changes (i.e. add/del lines both equal zero), for
the range, will not be listed.

Enhancement: Add an option to set a limits on what files will be
reported.  For example: show all files with more than 1000 lines
changed.  Or show the files with changes in the top 10'th percential,
for the specified range.  Or show files with changes greater than the
average number of changes seen, for the specified range.

8. If "rlog" is not supported with you version of CVS, then the
"-co" option must be used.

=head1 DIAGNOSTICS

See the -debug option.  For minimal debug info, use:

	-debug 1

=head1 BUGS

* If CVSROOT can't be found or accessed, the script silently does nothing.

* -rawfile is not implemented.

=head1 RESTRICTIONS

=head1 AUTHOR

Bruce Rafnel

=head1 HISTORY


=cut

# ---------------------------
# Variable naming convention
# The leading character defines the "scope" of the variable:
#	t - temporary or local variable
#	p - parameter
#	c - global constat
#	g - global
#	gp - global parameter (passed in from command line)

# ---------------------------
# Dependencies
require 5.001;
use Getopt::Long;

# ---------------------------
# Standard variables
$gName = &fBaseName($0);

$gCurDir = `pwd`;
chomp $gCurDir;

$gPath = $0;
$gPath =~ s![/][^/]*?$!!;
chdir $gPath;
$gPath = `pwd`;
chomp $gPath;
chdir $gCurDir;

push @INC, "/usr/local/bin:/usr/perl5/bin:$gPath";

$gVersion = '$Revision: 1.56 $';
$gVersion =~ tr/[.0-9]+//dc;

$|;

# Used by &fMsg
$cDebug = 1;	# or any larger number
$cNormal = 0;
$cVerbose = -1;
$cWarn = -2;
$cError = -3;
$cFatal = -4;
$gNumErr = 0;
$gNumWarn = 0;

# ---------------------------
# Get Options
$gpFrom = "";
$gpHtml = 0;
$gpCO = "";
$gpRawFile = "";
$gpRepositoryPath = "/";
$gpRootPath = "";
$gpShow = "numrev,diff,add,del";
$gpSort = "numrev";
$gpTo = "";
$gpDebug = 0;
$gpHelp = 0;
$gpHelpFmt = "";
$gpVerbose = 0;
&GetOptions(
	"dir:s" => \$gpRepositoryPath,
	"from:s" => \$gpFrom,
	"co" => \$gpCO,
	"html" => \$gpHtml,
	"rawfile:s" => \$gpRawFile,
	"root:s" => \$gpRootPath,
	"show:s" => \$gpShow,
	"sort:s" => \$gpSort,
	"to:s" => \$gpTo,
	"debug:i" => \$gpDebug,
	"help" => \$gpHelp,
	"fmthelp:s" => \$gpHelpFmt,
	"verbose" => \$gpVerbose,
);

if ($gpHelp) {
	if (-r "/usr/local/man/man1/$gName.1") {
		system("MANPATH=/usr/local/man; export MANPATH; man $gName");
	} elsif (-x "/usr/bin/pod2text" ) {
		system("/usr/bin/pod2text $0 | more");
	} elsif (-x "/usr/perl5/bin/pod2text") {
		system("/usr/perl5/bin/pod2text $0 | more");
	} else {
		system("awk '/\\=pod/,/\\=cut/ {print \$0}' <$0 | more");
		&fMsg($cWarn, "No pretty help, because could not find: /usr/local/man/man1/$gName.1 or /usr/bin/pod2text", $gName, __LINE__);
	}
	exit 1;
}

# ---------------------------
# Generate help files
if ($gpHelpFmt eq "text") {
	system("/usr/bin/pod2text $0 | more");
	exit 1;
} elsif ($gpHelpFmt eq "html") {
	system("/usr/bin/pod2html --noindex --norecurse --title $gName $0 | more");
	exit 1;
} elsif ($gpHelpFmt eq "man") {
	system("/usr/bin/pod2man $0 | more");
	exit 1;
}

# ---------------------------
# Validate options and set defaults

if ($gpCO) {
	if (! -f "CVS/Root") {
		&fMsg($cError, "Could not find CVS/Root.  See -co option.", __FILE__, __LINE__);
	}
	$gpRootPath = readpipe("cat CVS/Root 2>/dev/null");
	$gpRepositoryPath = readpipe("cat CVS/Repository 2>/dev/null");
	chomp $gpRootPath;
	chomp $gpRepositoryPath;
}

if ($gpRootPath eq "") {
	$gpRootPath = readpipe("cat CVS/Root 2>/dev/null");
	if ($gpRootPath ne "") {
		&fMsg($cWarn, "-root set to CVS/Root: $gpRootPath", __FILE__, __LINE__);
	} else {
		$gpRootPath = $ENV{"CVSROOT"};
	}
	if ($gpRootPath ne "") {
		&fMsg($cWarn, "-root set to \$CVSROOT: $gpRootPath", __FILE__, __LINE__);
	} else {
		&fMsg($cError, "-root can not be empty", __FILE__, __LINE__);
	}
}

if ($gpRepositoryPath eq "") {
	&fMsg($cError, "-dir can not be empty", __FILE__, __LINE__);
}

&fMsg(15, "gpFrom=$gpFrom", __FILE__, __LINE__);
if ($gpFrom ne "") {
	if ($gpFrom =~ /^[0-9][-0-9 :Z]/) {
		if ($gpFrom !~ /^[12][0-9][0-9][0-9]\-[01][0-9]\-[0-3][0-9]/) {
			&fMsg($cError, "Invalid -from date format: $gpFrom", __FILE__, __LINE__);
		} elsif ($gpFrom !~ /^[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9] +[0-2][0-9]:[0-5][0-9]Z?/) {
			&fMsg($cError, "Invalid -from time format", __FILE__, __LINE__);
		}
		$gpFrom = "-d\"$gpFrom";
		&fMsg(15, "gpFrom=$gpFrom", __FILE__, __LINE__);
	} elsif ($gpFrom eq "yesterday") {
		# Set from time to be 24 hours before now
		($tSec, $tMin, $tHour, $tDay, $tMonth, $tYear, $tWDay, $tYDay, $tisdst) = localtime(time - 86400);
		$tYear += 1900;
		++$tMonth;
		if ($tMonth < 10) {
			$tMonth = "0" . $tMonth;
		}
		if ($tDay < 10) {
			$tDay = "0" . $tDay;
		}
		if ($tHour < 10) {
			$tHour = "0" . $tHour;
		}
		if ($tMin < 10) {
			$tMin = "0" . $tMin;
		}
		$gpFrom = "-d\"$tYear-$tMonth-$tDay $tHour:$tMin";
		&fMsg(15, "gpFrom=$gpFrom", __FILE__, __LINE__);
	} else {
		$gpFrom = "-r$gpFrom";
		&fMsg(15, "gpFrom=$gpFrom", __FILE__, __LINE__);
	}
} else {
	$gpFrom = "-rBASE";
	&fMsg(15, "gpFrom=$gpFrom", __FILE__, __LINE__);
}

&fMsg(15, "gpTo=$gpTo", __FILE__, __LINE__);
if ($gpTo ne "") {
	if ($gpTo =~ /^[0-9][-0-9 :Z]/) {
		if ($gpTo !~ /^[12][0-9][0-9][0-9]\-[01][0-9]\-[0-3][0-9]/) {
			&fMsg($cError, "Invalid -to date format", __FILE__, __LINE__);
		} elsif ($gpTo !~ /^[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9] +[0-2][0-9]:[0-5][0-9]Z?/) {
			&fMsg($cError, "Invalid -to time format", __FILE__, __LINE__);
		}
		$gpTo = "<$gpTo\""
	} elsif ($gpTo eq "today") {
		$gpTo = ":HEAD"
	} else {
		$gpTo = ":$gpTo"
	}
	&fMsg(15, "gpTo=$gpTo", __FILE__, __LINE__);
} else {
	$gpTo = ":HEAD"
	&fMsg(15, "gpTo=$gpTo", __FILE__, __LINE__);
}
if ($gpFrom =~ /^-r/ && $gpTo =~ /^:/) {
	$gRange = $gpFrom . $gpTo;
} elsif ($gpFrom =~ /^-d/ && $gpTo =~ /^</) {
	$gRange = $gpFrom . $gpTo;
} elsif ($gpFrom =~ /^-r/ && $gpTo =~ /^</) {
	$gRange = "$gpFrom:" . " -d\"$gpTo";
} elsif ($gpFrom =~ /^-d/ && $gpTo =~ /^:/) {
	$gRange = "$gpFrom<\"" . " -r$gpTo";
} else {
	&fMsg($cError, "Internal error.", __FILE__, __LINE__);
}
&fMsg(15, "gpRange=$gpRange", __FILE__, __LINE__);

if ($gpSort eq "") {
	&fMsg($cError, "-sort can not be empty", __FILE__, __LINE__);
} else {
	if ($gpSort !~ /name|numrev|diff|add|del/) {
		&fMsg($cError, "$gpSort -sort option is invalid", __FILE__, __LINE__);
	}
}

if ($gpShow eq "") {
	&fMsg($cError, "-show can not be empty", __FILE__, __LINE__);
} else {
	foreach $i (split(/,/,$gpShow)) {
		if ($i !~ /files|numrev|diff|add|del/) {
			&fMsg($cError, "$i -show option is invalid", __FILE__, __LINE__);
		}
	}
}

if ($gpRawFile ne "") {
	if (! open(RAWFILE, ">$gpRawFile")) {
		&fMsg($cError, "Can not write to $gpRawFile", __FILE__, __LINE__);	}
}

if ($gNumErr) {
	die;
}

# Main ================================================

if ($gpCO) {
	&fParseLog();
} else {
	&fParseRLog();
}

if ($gpHtml) {
	&fGenReport();
}

if ($gpRawFile ne "") {
	&fDumpVar();
}

exit 0;

# Subroutines =========================================

# ---------------------------
sub fParseLog {
	# Parse the "cvs rlog" output.
	# Inputs:
	#	$gpRootPath
	#	$gpRepositoryPath
	#	$gpTo
	#	$gRange
	# Outputs:
	#	$gDirAdd
	#	$gDirAdd
	#	$gDirRev
	#	$gDirNumFile
	#	$gFileAdd
	#	$gFileDel
	#	$gFileRev
	#	$gFileList

	my $tFile;
	my $tTo = $gpTo;
	my $tChanged;

	# Subset of the ISO 8601 date format.
	# YYYY-MM-DD HH:MM
	# Local time zone is assumed.  Append a 'Z' to specify UTC.

	if ($tTo =~ /^:/) {
		$tTo =~ s/:/-r/;
	} else {
		$tTo =~ s/</-d\"/;
	}
	&fMsg($cVerbose, "cvs update $tTo", __FILE__, __LINE__);
	`cvs update -dP $tTo 1>&2`;

	&fMsg($cVerbose, "cvs log -N $gRange", __FILE__, __LINE__);
	open(LOG, "cvs log $gRange 2>&1 |");
	while (<LOG>) {
		chomp;
		&fMsg(10, "$_", __FILE__, __LINE__);

		# Get file name
		if (/^RCS file:\s+(.*),v/) {
			if ($tChanged) {
				# Inc. file count, if prev. file had changes
				++$gDirNumFile{$gpRepositoryPath};
			}
			$tFile = $1;
			$tFile =~ s|.*/$gpRepositoryPath/||;
			push @gFileList, $tFile;
			$tChanged = 0;
			&fMsg(5, "$tFile", __FILE__, __LINE__);
		}
		# Get line count (if any).  Example:
		# date: 2002/09/20 18:42:14;  author: bruce;  state: Exp;  lines: +1 -1
		if (/^date: .* state: .* lines: \+([0-9]+) \-([0-9]+)/) {
			$tChanged = 1;
			$gFileAdd{$tFile} += $1;
			$gFileDel{$tFile} += $2;
			$gDirAdd{$gpRepositoryPath} += $1;
			$gDirDel{$gpRepositoryPath} += $2;
			if ($1 + $2) {
				++$gFileRev{$tFile};
				++$gDirRev{$gpRepositoryPath};
			}
		}
	}
	close(LOG);

	return 1;
} # fParseLog

# ---------------------------
sub fParseRLog {
	# Parse the "cvs rlog" output.
	# Inputs:
	#	$gpRootPath
	#	$gpRepositoryPath
	#	$gRange
	# Outputs:
	#	$gDirAdd
	#	$gDirAdd
	#	$gDirRev
	#	$gDirNumFile
	#	$gFileAdd
	#	$gFileDel
	#	$gFileRev
	#	$gFileList

	my $tFile;
	my $tChanged;

	# Subset of the ISO 8601 date format.
	# YYYY-MM-DD HH:MM
	# Local time zone is assumed.  Append a 'Z' to specify UTC.

	&fMsg(10, "cvs -d $gpRootPath rlog -N $gRange $gpRepositoryPath 2>&1 |", __FILE__, __LINE__);
	open(LOG, "cvs -d $gpRootPath rlog -N $gRange $gpRepositoryPath 2>&1 |");
	while (<LOG>) {
		chomp;
		&fMsg(10, "$_", __FILE__, __LINE__);

		# Get file name
		if (/^RCS file: (.*),v/) {
			if ($tChanged) {
				# Inc. file count, if prev. file had changes
				++$gDirNumFile{$gpRepositoryPath};
			}
			$tFile = $1;
			$tFile =~ s/\/.*$gpRepositoryPath\///;
			push @gFileList, $tFile;
			$tChanged = 0;
			&fMsg(5, "$tFile", __FILE__, __LINE__);
		}

		# Get line count (if any).  Example:
		# date: 2002/09/20 18:42:14;  author: bruce;  state: Exp;  lines: +1 -1
		if (/^date: .* state: .* lines: \+([0-9]+) \-([0-9]+)/) {
			$tChanged = 1;
			$gFileAdd{$tFile} += $1;
			$gFileDel{$tFile} += $2;
			$gDirAdd{$gpRepositoryPath} += $1;
			$gDirDel{$gpRepositoryPath} += $2;
			if ($1 + $2) {
				++$gFileRev{$tFile};
				++$gDirRev{$gpRepositoryPath};
			}
		}
	}
	close(LOG);

	return 1;
} # fParseRLog

# ---------------------------
sub fGenReport {
	# Inputs:
	#	$gDirAdd
	#	$gDirAdd
	#	$gDirRev
	#	$gFileAdd
	#	$gFileDel
	#	$gFileList
	#	$gFileRev
	#	$gRange
	#	$gpShow
	#	$gpSort
	#	$gpRootPath
	# Outputs:
	#	STDOUT - html report

	my $tDir;
	my $tFile;
	my @tFileList;
	my $tRange = $gRange;

	$tRange =~ s/</&lt;/;

	print "<!-- Generated by cvsreport.pl $gVersion -->\n";
	print "<hr>\n<h2>$gpRootPath</h2>\n";
	if ($gpShow !~ /files/) {
		print "<table border=\"5\" cellpadding=\"10\">\n";
		print "<tr align=\"right\">\n";
		print "<th align=\"left\">Path</th>\n";
		print "<th>Num Rev</th>\n" if ($gpShow =~ /numrev/);
		print "<th>Diff</th>\n" if ($gpShow =~ /diff/);
		print "<th>Added</th>\n" if ($gpShow =~ /add/);
		print "<th>Deleted</th>\n" if ($gpShow =~ /del/);
		print "<th>Num Files</th>\n" if ($gpShow !~ /files/);
		print "</tr>\n";
	}
	foreach $tDir (keys %gDirAdd) {
		if ($gpShow =~ /files/) {
			print "<table border=\"5\" cellpadding=\"10\">\n";
			print "<tr align=\"right\">\n";
			print "<th align=\"left\">Path</th>\n";
			print "<th>Num Rev</th>\n" if ($gpShow =~ /numrev/);
			print "<th>Diff</th>\n" if ($gpShow =~ /diff/);
			print "<th>Added</th>\n" if ($gpShow =~ /add/);
			print "<th>Deleted</th>\n" if ($gpShow =~ /del/);
			print "<th>Num Files</th>\n" if ($gpShow !~ /files/);
			print "</tr>\n";
		}
		print "<tr align=\"right\">\n";
		print "<td align=\"left\"><b>$tDir/</b><br>Range: \n" . $tRange . "<br>Sort: $gpSort</td>\n";
		print "<td>" . $gDirRev{$tDir} . "</td>\n" if ($gpShow =~ /numrev/);
		print "<td>" . ($gDirAdd{$tDir} + $gDirDel{$tDir}) . "</td>\n" if ($gpShow =~ /diff/);
		print "<td>" . $gDirAdd{$tDir} . "</td>\n" if ($gpShow =~ /add/);
		print "<td>" . $gDirDel{$tDir} . "</td>\n" if ($gpShow =~ /del/);
		print "<td>" . $gDirNumFile{$tDir} . "</td>\n" if ($gpShow !~ /files/);
		print "</tr>\n";

		if ($gpShow =~ /files/) {
			@tFileList = sort fSort (keys %gFileAdd);
			foreach $tFile (@tFileList) {
				if ($gFileAdd{$tFile} + $gFileDel{$tFile} > 0) {
					print "<tr align=\"right\">\n";
					print "<td align=\"left\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$tFile</td>\n";
					print "<td>" . $gFileRev{$tFile} . "</td>\n" if ($gpShow =~ /numrev/);
					print "<td>" . ($gFileAdd{$tFile} + $gFileDel{$tFile}) . "</td>\n" if ($gpShow =~ /diff/);
					print "<td>" . $gFileAdd{$tFile} . "</td>\n" if ($gpShow =~ /add/);
					print "<td>" . $gFileDel{$tFile} . "</td>\n" if ($gpShow =~ /del/);
					print "</tr>\n";
				}
			}
		}
		if ($gpShow =~ /files/) {
			print "</table>\n";
		}
	}
	if ($gpShow !~ /files/) {
		print "</table>\n";
	}

	return 1;
} # fGenReport

# ---------------------------
sub fSort {
	my $tCmp;

	if ($gpSort =~ /name/) {
		return $a cmp $b;
	}
	if ($gpSort =~ /numrev/) {
		$tCmp = $gFileRev{$b} <=> $gFileRev{$a};
	} elsif ($gpSort =~ /diff/) {
		$tCmp = (($gFileAdd{$b} + $gFileDel{$b}) <=> ($gFileAdd{$a} + $gFileDel{$a}));
	} elsif ($gpSort =~ /add/) {
		$tCmp = $gFileAdd{$b} <=> $gFileAdd{$a};
	} elsif ($gpSort =~ /del/) {
		$tCmp = $gFileDel{$b} <=> $gFileDel{$a};
	}
	if ($tCmp == 0) {
		return $a cmp $b;
	} else {
		return $tCmp;
	}
} # fSort

# ---------------------------
sub fDumpVar {
	# Input
	#	RAWFILE - file handle
	#	$gDirAdd
	#	$gDirAdd
	#	$gDirRev
	#	$gFileAdd
	#	$gFileDel
	#	$gFileList
	#	$gFileRev
	#	$gRange
	#	$gpShow
	#	$gpSort
	#	$gpRootPath

	my $tDir;
	my $tFile;
	my @tFileList;
	my $tRange = $gRange;

	$tRange =~ s/</&lt;/;

	print RAWFILE "# Generated by cvsreport.pl $gVersion\n";
	print RAWFILE "# $gpRootPath\n";
	print RAWFILE "\"Path\",";
	print RAWFILE "\"NumRev\"," if ($gpShow =~ /numrev/);
	print RAWFILE "\"Diff\"," if ($gpShow =~ /diff/);
	print RAWFILE "\"Added\"," if ($gpShow =~ /add/);
	print RAWFILE "\"Deleted\"," if ($gpShow =~ /del/);
	print RAWFILE "\"NumFiles\"," if ($gpShow !~ /files/);
	print RAWFILE "\n";

	print "# Generated by cvsreport.pl $gVersion\n";
	print "# $gpRootPath\n";
	print "\"Path\",";
	print "\"NumRev\"," if ($gpShow =~ /numrev/);
	print "\"Diff\"," if ($gpShow =~ /diff/);
	print "\"Added\"," if ($gpShow =~ /add/);
	print "\"Deleted\"," if ($gpShow =~ /del/);
	print "\"NumFiles\"," if ($gpShow !~ /files/);
	print "\n";

	foreach $tDir (keys %gDirAdd) {
		print "\"$tDir/\",";
		print $gDirRev{$tDir} . "," if ($gpShow =~ /numrev/);
		print ($gDirAdd{$tDir} + $gDirDel{$tDir}) . "," if ($gpShow =~ /diff/);
		print $gDirAdd{$tDir} . "," if ($gpShow =~ /add/);
		print $gDirDel{$tDir} . "," if ($gpShow =~ /del/);
		print $gDirNumFile{$tDir} . "," if ($gpShow !~ /files/);
		print "\n";

		if ($gpShow =~ /files/) {
			@tFileList = sort fSort (keys %gFileAdd);
			foreach $tFile (@tFileList) {
				if ($gFileAdd{$tFile} + $gFileDel{$tFile} > 0) {
					print RAWFILE "\"$tFile\",";
					print RAWFILE $gFileRev{$tFile} . "," if ($gpShow =~ /numrev/);
					print RAWFILE ($gFileAdd{$tFile} + $gFileDel{$tFile}) . "," if ($gpShow =~ /diff/);
					print RAWFILE $gFileAdd{$tFile} . "," if ($gpShow =~ /add/);
					print RAWFILE $gFileDel{$tFile} . "," if ($gpShow =~ /del/);
					print RAWFILE "\n";
				}
			}
		}
	}

	return 1;
} # fDumpVar

# ---------------------------
sub fBaseName { 
	$_ = shift;
	s,^.*/([^/]+)$,$1,;
	return $_;
} # fBaseName

# ---------------------------
sub fMsg {
	# Input:
	#	$1 - $pLevel
	#		 0 normal		($cNormal)
	#		-1 output if $pVerbose	($cVerbose)
	#		-2 - warning		($cWarn)
	#		-3 - error		($cError)
	#		-4 - fatal error, die	($cFatal)
	#		>=1 output $pMsg, if $gpDebug >= $pLevel
	#	$2 - $pMsg - message text
	#	$3 - [$pProg] - __FILE__ 
	#	$4 - [$pLine] - __LINE__
	#	$5 - [$pFile] - output $pFile and $. if specified
	#	$gpDebug
	#	$gpVerbose
	# Output:
	#	$gNumErr - increment if $cError
	#	$gNumWarn - increment if $cWarn
	#	stderr: $pMsg
	my $pFile;
	my $pLevel;
	my $pLine;
	my $pMsg;
	my $pProg;
	my $tFile;
	my $tLoc;
	my $tMsg;
	$| = 1;

	($pLevel, $pMsg, $pProg, $pLine, $pFile) = @_;
	if ($pLevel <= $cFatal) {
		$tLevel = "Fatal Error: ";
	} elsif ($pLevel == $cError) {
		$tLevel = "Error: ";
		++$gNumErr;
	} elsif ($pLevel == $cWarn) {
		$tLevel = "Warning: ";
		++$gNumwarn;
	} elsif ($pLevel == $cNormal) {
		$tLevel = "";
	} elsif ($pLevel == $cVerbose && ($gpVerbose || $gpDebug)) {
		$tLevel = "";
	} elsif ($gpDebug >= $pLevel) {
		$tLevel = "Debug" . $pLevel . ": ";
	} else {
		return;
	}
	$tLoc = "";
	if ($pProg ne "") {
		$pProg =~ s/.+\///;
		$tLoc = " [" . $pProg . ":" . $pLine . "]";
	}
	$tFile = "";
	if ($pFile ne "") {
		$tFile =  " (" . $pFile . ":" . $. . ")";
	}
	$tMsg = $tLevel . $pMsg . $tFile . $tLoc . "\n";
	if ($pLevel <= $cFatal) {
		die $tMsg;
	} else {
		warn $tMsg;
	}
	return;
} # fMsg
