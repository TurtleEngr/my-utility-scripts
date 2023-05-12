#!/usr/bin/perl
# $Header: /repo/per-bruce.cvs/bin/map-pkg.pl,v 1.5 2023/03/25 22:21:42 bruce Exp $

# Example: pod2html --noindex --title "mkconf.pl"

=pod

=head1 NAME

map-pkg - DESCRIPTION

=head1 SYNOPSIS

	map-pkg [-h[elp]] [-v[erbose] [-d[ebug Level] [-a[ll] All] File...

=head1 DESCRIPTION

This is mainly used for making a csv file that shows where packages
are used.  The All file, contains the list all of the possible
packages, across all servers.  Then each file passed, contains the
list of all package on that server.

Usually the version numbers are removed from the package names.  This
needs to be done manually, or with another script, because the version
numbers do not follow a "regular" pattern.

=head1 OPTIONS

=over 4

=item B<-a[ll] All>

This a list of all the lines in all of the files.

Default: the contents of all the Files will be concatinated, and set
to only have "unique" lines.

=item B<File>

One or more files. The files should contain unique names.

=item B<-help>

This help

=back

=head1 RETURN VALUE

[What the program or function returns if successful.]

=head1 ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following: (FILE:LINE) [PROGRAM:LINE]

=head1 EXAMPLES

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
 	map-pkg.pl *.pkg

=head1 ENVIRONMENT

$cmclient, $HOME

=head1 FILES

Input files:

Blank lines and lines beginning with '#' will be ignored.

Leading and trailing white space will be trimmed.

Each line will be treated as one "key".  Lines must match exactly for
them to be listed with an 'x' in the column for that file.

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

Revision: 1.7

=cut

# ---------------------------------------------------
# Function
sub fMsg {
	# Input:
	#	Args:
	#	 	$pLevel
	#			0 - fatal error, die
	#			1 - error
	#			2 - warning
	#			3 - normal
	#			4 - normal, output if $pVerbose
	#			5 or more - output if $pDebug >= $pLevel
	#		$pMsg - message text
	#		[$pProg] - __FILE__ 
	#		[$pLine] - __LINE__
	#		[$pFile] - output $pFile and $. if specified
	#	$gpDebug
	#	$gpVerbose
	# Output:
	#	warn ...
	my $pFile;
	my $pLevel;
	my $pLine;
	my $pMsg;
	my $pProg;
	my $tFile;
	my $tLoc;
	my $tMsg;

	($pLevel, $pMsg, $pProg, $pLine, $pFile) = @_;
	if ($pLevel == 0) {
		$tLevel = "Fatal Error: ";
	} elsif ($pLevel == 1) {
		$tLevel = "Error: ";
	} elsif ($pLevel == 2) {
		$tLevel = "Warning: ";
	} elsif ($pLevel == 3) {
		$tLevel = "";
	} elsif ($pLevel == 4 && $gpVerbose) {
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
	if ($pLevel != 0) {
		warn $tMsg;
	} else {
		die $tMsg;
	}
	return;
} # fMsg

# ---------------------------------------------------
# Main

local $gPath = $0;
$gPath =~ s![/][^/]*?$!!;
local $gCurDir = readpipe 'pwd';
chomp $gCurDir;
chdir $gPath;
local $gPath = readpipe 'pwd';
chomp $gPath;
chdir $gCurDir;

push @INC,"/usr/local/bin";
push @INC,"$gPath";

use Env;
use Getopt::Long;

local $tFile;
local $tFileList;
local $tName;
local %tAll;
local $tHead;

local $cMsgFatal = 0;
local $cMsgErr = 1;
local $cMsgWarn = 2;
local $cMsg = 3;
local $cMsgVerbose = 4;
local $cMsgDebug1 = 5;
local $cMsgDebug2 = 10;
local $cMsgDebug3 = 15;

local $gpDebug = 0;
local $gpHelp = 0;
local $gpVerbose = 0;
local $gpAll = "";
&GetOptions(
	"debug:s" => \$gpDebug,
	"help" => \$gpHelp,
	"verbose" => \$gpVerbose,
	"all:s" => \$gpAll,
);

if ($gpHelp) {
	system("pod2text $0 | more");
	exit 1;
}

# Validate options
&fMsg($cMsgVerbose, "Start", __FILE__, __LINE__);

local @gpFileList = @ARGV;
foreach $tFile (@gpFileList) {
	if (! -f $tFile) {
		&fMsg($cMsgFatal, "Could not find file: $tFile", __FILE__, __LINE__);
	}
	$tFileStr .= $tFile
}

if ($gpAll eq "") {
	$gpAll = "/tmp/map-pkg.all.tmp";
	$tFileList = join(' ', @gpFileList);
	&fMsg($cMsgDebug2, "sort -u $tFileList >$gpAll", __FILE__, __LINE__);
	system("sort -u $tFileList >$gpAll");
}

&fMsg($cMsgDebug2, "All=$gpAll", __FILE__, __LINE__);
if (! -f $gpAll) {
	&fMsg($cMsgFatal, "Could not find file: $gpAll", __FILE__, __LINE__);
}

# -----------------------
# Functional section

# Load the All hash variable with the file in gpAll (each name is a
# key and the first value)
&fMsg($cMsgVerbose, "Processing File: $gpAll", __FILE__, __LINE__);
open(hAll, "<", $gpAll) or &fMsg($cMsgFatal, "Could not open file: $gpAll", __FILE__, __LINE__);
while (<hAll>) {
	chomp;
	$tName = $_;
	$Name =~ s/^\s+//;
	$Name =~ s/\s+$//;
	if ($tName =~ /^\s*#/ or $tName =~ /^$/) {
		next;
	}
	$tAll{$tName} = $tName;
	&fMsg($cMsgDebug3, "Name=$tName", __FILE__, __LINE__);
}

# Set Head var. to the "All" file name
$tHead = $gpAll;

# For each of the files
foreach $tFile (@gpFileList) {
	&fMsg($cMsgVerbose, "Processing File: $tFile", __FILE__, __LINE__);

	# Append a "," and the name of the file to the Head var.
	$tHead .= ",$tFile";

	# Append a ',' to all All hash values
	foreach $tName (keys(%tAll)) {
		$tAll{$tName} .= ',';
	}

	# Read each Name from the file
	open(hFile, "<", $tFile) or &fMsg($cMsgFatal, "Could not open file: $tFile", __FILE__, __LINE__);
	while (<hFile>) {
		chomp;
		$tName = $_;
		&fMsg($cMsgDebug3, "Name=$tName tAll=" . $tAll{$tName}, __FILE__, __LINE__);

		# If no All hash exists for that name, output an Error
		if (! exists($tAll{$tName})) {
			&fMsg($cMsgErr, "$tName is not in the All list", __FILE__, __LINE__);
			$tAll{$tName} .= 'ERROR';
		}
		# Append a 'x' to that All hash with that Name
		$tAll{$tName} .= 'x';
	}
	close(hFile);
}

# Output the csv file
open(hFile, ">", "map-pkg.csv") or &fMsg($cMsgFatal, "Could not open file: map-pkg.csv", __FILE__, __LINE__);
print hFile "$tHead\n";
foreach $tName (keys(%tAll)) {
	print hFile $tAll{$tName}, "\n";
}
close(hFile);

&fMsg($cMsgVerbose, "Done", __FILE__, __LINE__);
