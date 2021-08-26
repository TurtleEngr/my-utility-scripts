#!/usr/bin/perl
# Convert log file ouput into URLs

# Example use:
#	mkurl.pl <FILE.log | sort -u >URI.txt

# Example input:
# 64.41.168.244 - - [14/Jan/2008:14:53:54 -0800] "POST /registration/identity_theft_protection_products_signup2.php HTTP/1.1" 200 29686 "-" "Mozilla/5.0 (compatible; MSIE 7.0; MSIE 6.0; ScanAlert; +http://www.scanalert.com/bot.jsp) Firefox/2.0.0.3"
# 64.41.168.244 - - [14/Jan/2008:14:55:08 -0800] "GET /html/identity_theft_protection_products_008Email.php HTTP/1.1" 200 23712 "https://trustedid.com:443/html/identity_theft_protection_products_008.php" "Mozilla/5.0 (compatible; MSIE 7.0; MSIE 6.0; ScanAlert; +http://www.scanalert.com/bot.jsp) Firefox/2.0.0.3"

# Config
$cSite = "https://tid-qa4.trustedid.com";

open(hErr, '>', 'mkurl.err');
while (<>) {
	if (/ "POST (\S+) /) {
		$tURL = $1;
		$tURL =~ /([^?])+\?(.*)/;
		if ($2 eq '') {
			print "wget --post-data=\'\' " . $cSite . "\'$1\'\n";
		} else {
			print "wget --post-data=\'$2\' " . $cSite . "\'$1\'\n";
		}
	} elsif (/ "GET (\S+) /) {
		print "wget " . $cSite . "\'$1\'\n";
	} else {
		print hErr $_;
	}
}
close(hErr);
