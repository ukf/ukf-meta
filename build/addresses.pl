#!/usr/bin/perl

open(XML,"../sdss-sites-13.xml") || die "could not open input file";

while (<XML>) {
    if (/<EmailAddress>mailto:(.*)<\/EmailAddress>/) {
	if (!defined($lowered{lc $1})) {
	    $lowered{lc $1} = $1;
	    push @addresses, $1;
	}
    }
}

foreach $addr (@addresses) {
    print $addr, "\n";
}

close XML;
