#!/usr/bin/perl

# pod2html --noindex --title "mkconf.pl"

=pod

(c) Copyright 2004 by COMPANY

=head1 NAME

SCRIPTNAME - DESCRIPTION

=head1 SYNOPSIS

	SCRIPTNAME [-o Optiong] [-h[elp]] [-v[erbose]] [-d[ebug] level] 

=head1 DESCRIPTION


=head1 OPTIONS

=over 4

=item B<-verbose>

Verbose output.  Sent to stderr.

=back

=head1 RETURN VALUE

[What the program or function returns if successful.]

=head1 ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following: (FILE:LINE) [PROGRAM:LINE]

=head1 EXAMPLES

=head1 ENVIRONMENT

$cmclient, $HOME

=head1 FILES

=head1 SEE ALSO

=for comment =head1 NOTES

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

(c) Copyright 2004 by COMPANY

$Revision: 1.36 $ GMT 

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

$gPath = $0;
$gPath =~ s![/][^/]*?$!!;
$gCurDir = readpipe 'pwd';
chomp $gCurDir;
chdir $gPath;
$gPath = readpipe 'pwd';
chomp $gPath;
chdir $gCurDir;

push @INC,"/usr/local/bin";
push @INC,"$gPath";

use Env;
use Getopt::Long;

$gpDebug = 0;
$gpHelp = 0;
$gpVerbose = 0;
&GetOptions(
	"debug:s" => \$gpDebug,
	"help" => \$gpHelp,
	"verbose" => \$gpVerbose,
);

if ($gpHelp) {
	system("pod2text $0 | more");
	exit 1;
}

# Validate options

&fMsg(3, "Start", __FILE__, __LINE__);
