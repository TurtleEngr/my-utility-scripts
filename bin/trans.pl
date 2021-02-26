#!/usr/bin/perl

# pod2html --noindex --title "trans.pl"

=pod

(c) Copyright 2001 by Bruce Rafnel

=head1 NAME

trans.pl.pl - Translate text with Bablefish.

=head1 SYNOPSIS

	trans.pl [-to] [-round] -language LANGUAGE {-help}

=head1 DESCRIPTION

If -language is not specified, then output short usage help and the
list of available languages.

If -to is not specified, then the translation will be from LANGUAGE to
English.

=head1 OPTIONS

=over 4

=item B<-t*o>

Convert from English to LANGUAGE.

If this option is not specified, then the input will be converted from
LANGUAGE to English.

=item B<-r*ound>

With the option, English text will be converted to the specified
LANGUAGE, then text will be converted back to English.  If the meaning
of the text mostly survives this "round-trip", then it is likely that
the LANGUAGE text will be understood.

=item B<-l*anguage LANGUAGE>

Specify the source or target language.

=back

=head1 RETURN VALUE

=head1 ERRORS

=head1 EXAMPLES

=head1 ENVIRONMENT

=head1 SEE ALSO

WWW::Babelfish

=head1 NOTES

=head1 CAVEATS

=head1 DIAGNOSTICS

=head1 BUGS

=head1 RESTRICTIONS

=head1 AUTHOR

Bruce Rafnel

=head1 HISTORY

(c) Copyright 2001 by Bruce Rafnel

$Revision: 1.57 $

=cut

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

use WWW::Babelfish;
use Getopt::Long;

$gpTo = 0;
$gpRound = 0;
$gpLanguage = "";
$gpHelp = 0;
&GetOptions(
	"to" => \$gpTo,
	"round" => \$gpRound,
	"language:s" => \$gpLanguage,
	"help" => \$gpHelp,
);

if ($gpHelp) {
	system("pod2text $0 | more");
	exit 1;
}

$obj = new WWW::Babelfish('agent' => 'Mozilla/8.0');
die("Babelfish server unavailable\n") unless defined($obj);

if ($gpLanguage eq "") {
	print <<EOF;
Usage:
	trans.pl {-to} -language LANGUAGE {-help}

Available languages:
EOF
	foreach $i ($obj->languages) {
		print "\t$i\n";
	}
	exit 1;
}

if (!$gpRound) {
	if ($gpTo) {
		$gSource = 'English';
		$gDest = $gpLanguage;
	} else {
		$gSource = $gpLanguage;
		$gDest = 'English';
	}

	$obj->translate(
		'source' => $gSource,
		'destination' => $gDest,
		'text' => \*STDIN,
		'delimiter' => "\n\n",
		'ofh' => \*STDOUT
	);
	print "\n";
} else {
	$gSource = 'English';
	$gDest = $gpLanguage;

	$gText = $obj->translate(
		'source' => $gSource,
		'destination' => $gDest,
		'text' => \*STDIN,
		'delimiter' => "\n\n",
	);

	$obj->translate(
		'source' => $gDest,
		'destination' => $gSource,
		'text' => $gText,
		'delimiter' => "\n\n",
		'ofh' => \*STDOUT
	);
	print "\n";
}
