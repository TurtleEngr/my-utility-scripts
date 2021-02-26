#!/usr/bin/perl

# List of word substitutions
%gWordList = (
	'brigitte',	'bridge zeet',
	'ha',		'!C H UH1 UH1 UH1 !T',
	'hi',		'hie',
	'batteries',	'battereys',
);

$|;
open(COM, '>/dev/ttyS1') || die;

$gText = '';
while (<>) {
	$gText .= $_;
}
$gText = fEmph($gText);
print "After emph: $gText\n";
$gText = fSubWord($gText);
print "After subword: $gText\n";
$gText = '!P1!R8!F!T!W!S ' . $gText . "\n";
print "Say: $gText\n";
print COM "$gText\n";

close COM;
exit;

# -------------------------------
sub fEmph {
	my $tLine;
	($tLine) = @_;
	$tLine =~ s/(".*?")/ !P2 $1 !P1 /gm;
	$tLine =~ s/(".*?!")/ !P3 $1 !P1 /gm;
	$tLine =~ s/(\w+\?")/!P3 $1 !P1/gm;
	$tLine =~ s/"//gm;
	$tLine =~ s/\!P1 \!P1/!P1/gm;
	return $tLine;
} # fEmph

# -------------------------------
sub fSubWord {
	my $tLine;
	($tLine) = @_;
	my $tSay;

	foreach $tWord (split(/\s+/,$tLine)) {
		$tPart = $tWord;
		$tPart =~ s/\W//;
		$tPart =~ tr/[A-Z]/[a-z]/;
		if (defined($gWordList{$tPart})) {
			$tWord =~ s/$tPart/$gWordList{$tPart}/ies;
		}
		$tSay .= " " . $tWord;
	}
	return $tSay;
} # fSubWord
