#!/usr/bin/perl
# Test snips of cool perl code.
# To use, just copy the code fragment, that you are intrested in,
# to the top of the script.

# -------------------------------
$j = foo;
$k = "j";
$Val = $$k;
print "$k = $Val\n";
exit;

# -------------------------------
sub fDefault {
	my $pValue;
	my $pDefaut;
	($pValue, $pDefault) = @_;
print "pValue = $pValue\n";
	if ("$pValue" eq "") {
		print "Notice: Default set: $pVar=\"$pDefault\"\n";
		return($pDefault);
	}
	return($pValue);
} # fDefault

$tTest1 = "foo";
$tTest2 = "";
$tTest1 = &fDefault($tTest1, "Default1");
$tTest2 = &fDefault($tTest2, "Default2");
$tTest3 = &fDefault($tTest3, "Default3");

print "
tTest1 = $tTest1
tTest2 = $tTest2
tTest3 = $tTest3
";
exit 0;

# -------------------------------
print "$^O";
exit 0;

# -------------------------------
# Test capturing stderr and stdout redirection, and tagging them.
# Time stamp the lines.

$cmd = "test.pl";

$s = time;
open(CMD, "($cmd | sed 's/^/STDOUT:/') 2>&1 |");
$| = 1;
while (<CMD>) {
	$t = time - $s;
	if (s/^STDOUT://)  {
		print "$t stdout: ", $_;
	} else {
          	print "$t stderr: ", $_;
      	}
}
exit 0;

# -------------------------------
#!/usr/bin/perl
# test.pl
print stderr "text to stderr 0\n";
print "text to stdout 0\n";
sleep 1;
print "text to stdout 1\n";
print stderr "text to stderr 1\n";
sleep 2;
print stderr "text to stderr 2\n";
print "text to stdout 2\n";
sleep 3;
print "text to stdout 3\n";
print stderr "text to stderr 3\n";
sleep 4;
print stderr "text to stderr 4\n";
print "text to stdout 4 \n";
sleep 5;
print "text to stdout 5\n";
print stderr "text to stderr 5\n";

# -------------------------------
# Test pattern matching

$_ = '**** info       Wed May 30 21:19:26 GMT+00:00 2001      991257566505    /atg/dynamo/server/ServerMonitor        atg.server.tcp.TcpResources->sessionMemoryInfo : Sampling session and memory information.  Number of sessions=3.  Total memory=536870912, free memory=480902600 (89.58%).';

/Number of sessions=([0-9]+)\./;
$tSess = $1;

/ \(([0-9]+\.[0-9]+)%\)\./;
$tMem = $1;

print "tSess=$tSess tMem=$tMem";
exit;

# -------------------------------
# Test the setting of the ARGV with file names (where no files match
$j = "../test";
@ARGV = <$j/Makefile*>;
print "$#ARGV\n";
@ARGV = <$j/NONE*>;
print "$#ARGV\n";
while ($#ARGV >= 0 and <>) {
	print "$ARGV $_";
}
exit;

# -------------------------------
# Test the setting of the ARGV with file names
$j = "../test";
@ARGV = <$j/Makefile*>;
while (<>) {
	print "$ARGV $_";
}
exit;

# -------------------------------
$t1 = "test";
$t2 = ($t1 eq "test") + 0;
print "$t1 $t2\n";
$t1 = "testxx";
$t2 = ($t1 eq "test") + 0;
print "$t1 $t2\n";
exit;

# -------------------------------
# Test pattern matching: match the 3'rd arg that begins with a known char.
# Reads the data at end of this file.
while (<DATA>) {
	chomp;
	@tLine = split /\s+/;
	$tArg = 3;
	$tPattern = "^0";
	print "match1: $_\n" if ($tLine[$tArg] =~ /$tPattern/);

# The following does not work:
#	$tPattern = "/^0/";
#	print "match1: $_\n" if ($tLine[$tArg] =~ $tPattern);
}
exit;

# -------------------------------
# Test the time conversion functions
$gTimeFmt = "local";
$tTime = time;
($tSec, $tMin, $tHour, $tMDay, $tMon, $tYear, $tWDay, $tYDay,
	$isDST) = ($gTimeFmt eq "local") ? localtime($tTime) : gmtime($tTime);

#	N,HH:MM:SS,value,value,value,...
$, = "\t";
printf "%d$,%d-%02d-%02d$,%02d:%02d:%02d$,", $tTime, $tYear+1900, $tMon+1, $tMDay, $tHour, $tMin, $tSec;
@a = (1, 2, 3);
print "xx", @a;
print "\n";
print "done\n";
exit;

# -------------------------------
# test the sort function
%m = (
"third", 3,
"first", 1,
"second", 2
);
$, = " ";
$\ = "\n";
print keys %m;
@tSorted = sort {($m{$a} <=> $m{$b})} keys %m;
print @tSorted;
exit;

# -------------------------------
# Does @a get treated as seperate arguments to printf
@a = (1, 2, 3);
$b = 0;
printf "%03d %03d %03d %03d", $b, @a;
exit;

# -------------------------------
# Test pattern matching '|'
while (<>) {
	# feed it Makefile to test
#	$tPattern = "m/\bdiff\b|\btest\b|\bmon\b|\bdate\b/";
	$tPattern = "date|diff|test|mon|date";
	next if ($_ =~ /$tPattern/);
	print $_;
}
exit;

# -------------------------------
# Test pattern matching
while (<>) {
#	$tPat = "/test|diff/";
	$tPat = "";
	if ($_ =~ $tPat or $tPat = "") {
		print $_;
	}
}
exit;

# -------------------------------
# See what is returned for attr that don't exist
#use XML::EasyOBJ;
$oDoc = new XML::EasyOBJ('manifest.xml') or die "Can't make object";
foreach $oArch ($oDoc->arch) {
	$tArch = $oArch->getAttr('id');
	$t = $oArch->getAttr('xx');
	print $tArch . "\n";
	print "t=$t\n";
}
exit;

# -------------------------------
# Check list syntax, to from array variables
@t = (1, 2, 3, 4);
($a, $b) = @t;
print "a=$a\n";
print "b=$b\n";
exit;

# -------------------------------
# Try out readpipe and trim, leaving only the file name
$t = readpipe('pwd');
$t =~ s![^/]*/!!g;
print "$t\n";
exit;

# -------------------------------
# Test calling of subroutines, indirectly
&t1();
&t2();

$t = "t1";
&$t();
$t = "t2";
&$t();
$t = "t3";
&$t();

sub t1 {
	print "In t1\n";
}

sub t2 {
	print "In t2\n";
}
exit;

# -------------------------------
# Test fMsg
&fMsg(3, "Test", __FILE__, __LINE__);
&fMsg(2, "Test warn", __FILE__, __LINE__);
&fMsg(1, "Test error", __FILE__, __LINE__);
&fMsg(1, "Test error file", __FILE__, __LINE__, "FileName");
&fMsg(0, "Test error, die", __FILE__, __LINE__);
exit;

# -------------------------------
# General error message function
sub fMsg {
	my $pFile;
	my $pLevel;
	my $pLine;
	my $pMsg;
	my $pProg;
	my $tFile;
	my $tLoc;
	my $tMsg;

	($pLevel, $pMsg, $pProg, $pLine, $pFile) = @_;
	if ($pLevel eq 0) {
		$tLevel = "Fatal Error: ";
	} elsif ($pLevel eq 1) {
		$tLevel = "Error: ";
	} elsif ($pLevel eq 2) {
		$tLevel = "Warning: ";
	} else {
		$tLevel = "";
	}
	$pProg =~ s/.+\///;
	$tLoc = " [" . $pProg . ":" . $pLine . "]";
	$tFile = "";
	if ($pFile ne "") {
		$tFile = " (" . $pFile . ":" . $. . ")";
	}
	$tMsg = $tLevel . $pMsg . $tFile . $tLoc . "\n";
	if ($pLevel ne 0) {
		warn $tMsg;
	} else {
		die $tMsg;
	}
	return;
}
exit;

# -------------------------------
# Parse manifest.xml with XML::EasyOBJ

$oDoc = new XML::EasyOBJ('manifest.xml') || die "Can't make object";
foreach $oArch ($oDoc->arch) {
	$tArch = $oArch->getAttr('id');
	print $tArch . "\n";
	foreach $oSys ($oArch->sys) {
		$tSys = $oSys->getAttr('id');
		print "\t" . $tSys . "\n";
		foreach $oVar ($oSys->var) {
			$tId = $oVar->getAttr('id');
			$tValue = $oVar->getString();
			print "\t\t" . $tId . "=" . $tValue . "\n";
			$gVar{"$tArch.$tSys.$tId"} = $tValue;
		}
	}
}

foreach $tVar (sort(keys(%gVar))) {
	print "$tVar=$gVar{$tVar}\n";
}

print "monitor->conf->sys(id)=" .
    $oDoc->monitor(0)->conf(0)->sys->getAttr('id') . "\n";

print "monitor->conf->sys->name=" .
    $oDoc->monitor(0)->conf(0)->sys(0)->name->getString() . "\n";

print "monitor->conf->sys->prog(id)=" .
    $oDoc->monitor(0)->conf(0)->sys(0)->prog->getAttr('id') . "\n";

print "monitor->conf->sys->log=" .
    $oDoc->monitor(0)->conf(0)->sys(0)->log->getAttr('id') . "\n";

foreach $oLog ($oDoc->monitor(0)->log) {
    print "monitor->log(id)=" .
	$oLog->getAttr('id') . "\n";
    foreach $oFile  ($oLog->file) {
	print "monitor->log->file" .
	    $oFile->getString() . "\n";
    }
}

# Date::Manip; 5.33
# Digest::MD5 
# HTML::HeadParser
# LWP::UserAgent; 
# MIME::Base64 2.1
# Net::FTP 2.4
# Parse::Yapp; 0.16
# URI 1.10
# XML::DOM
# XML::EasyOBJ
# XML::Parser::PerlSAX;
# XML::Parser; 2.27

# Dependancies found in:
#XML-EasyOBJ-1.0.tar.gz
#URI-1.11.tar.gz
#DateManip-5.39.tar.gz
#MIME-Base64-2.12.tar.gz
#Digest-MD5-2.13.tar.gz
#Parse-Yapp-1.04.tar.gz
#HTML-Tagset-3.03.tar.gz
#HTML-Parser-3.19.tar.gz
#expat-1.95.0.tar.gz
#XML-Parser.2.30.tar.gz
#libnet-1.0703.tar.gz
#libwww-perl-5.51.tar.gz
#libxml-enno-1.04.tar.gz

# -------------------------------------------------------
__END__
x x x  CPU minf mjf xcal  intr ithr  csw icsw migr smtx  srw syscl  usr sys  wt idl
x x x    0    0   0    0     0    0    0    0    0    0    0     0    0   0   0 100
x x x    1    0   0   12   201    1    4    0    0    0    0     1    0   0   0  99
x x x    2    0   0    0     2    2    4    0    0    0    0     1    0   0   1  98
x x x    3    0   0    0     0    0    3    0    0    0    0     1    0   0   1  99
x x x  CPU minf mjf xcal  intr ithr  csw icsw migr smtx  srw syscl  usr sys  wt idl
x x x    0    0   0    0     0    0    0    0    0    0    0     0    0   0   0 100
x x x    1    0   0   12   201    1   15    0    0    0    0     5    0   0   0 100
x x x    2    1   0    0     2    2    1    0    0    0    0     2    0   1   0  99
x x x    3    0   0    0     0    0    2    0    0    0    0     3    0   0   0 100
