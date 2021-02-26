#!/usr/bin/perl
# Convert unix time to formated time.
# Currently setup to parse 'sar -h' style output

# Input record:
# server interval time alt type value
# 0      1        2    3   4    5

while (<>) {
	chomp;
	@tArg = split('\s', $_, 100);
	print $_;
	print " " . localtime($tArg[2]) . "\n";
}
