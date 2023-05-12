#!/usr/bin/perl
# $Header: /repo/per-bruce.cvs/bin/diff-time.pl,v 1.4 2023/03/25 22:21:41 bruce Exp $

if (@ARGV > 1) {
	$Meet = $ARGV[0] . ' ' . $ARGV[1];
} else {
	$Meet = '2009-03-20 18:00';
}

$MeetSec = readpipe("date --date='$Meet' +'%s.%N'");
$NowSec = readpipe("date --date='today' +'%s.%N'");

chomp $MeetSec;
chomp $NowSec;

$DiffSec = $MeetSec - $NowSec;

$Sec = $DiffSec;

$Day = int($Sec/24/60/60);
$Sec = $Sec - $Day*24*60*60;

$Hour = int($Sec/60/60);
$Sec = $Sec - $Hour*60*60;

$Min = int($Sec/60);
$Sec = $Sec - $Min*60;

$FracSec = abs(int(($Sec - int($Sec)) * 100));

$Sec = int($Sec);

# print("Debug:\n MeetSec=$MeetSec\n NowSec=$NowSec\n DiffSec=$DiffSec\n\n");

#print("$Day days, $Hour hours, $Min min, $Sec.$FracSec sec \n");

print(
	$Day,  $Day == 1  ? ' day, '    : ' days, ',
	$Hour, $Hour == 1 ? ' hour, '   : ' hours, ',
	$Min,  $Min == 1  ? ' minute, ' : ' minutes, ',
	"$Sec.$FracSec seconds \n"
);
print("Until: $Meet\n");
