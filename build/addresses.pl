#!/usr/bin/perl

open(XML,"../xml/sdss-metadata-unsigned.xml") || die "could not open input file";

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
