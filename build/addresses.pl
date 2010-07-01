#!/usr/bin/perl

use Xalan;

#
# Load list addresses.
#
open(LIST, "list.txt") || die "could not open list addresses file";
while (<LIST>) {
	chomp; # remove \n
	$list{$_} = 1 unless $_ eq '';
}
close LIST;

#
# Load extra addresses.
#
open(EXTRAS, "extra_addresses.txt") || die "could not open extra addresses file";
while (<EXTRAS>) {
	chomp;	# remove \n
	$extras{$_} = 1 unless $_ eq '';
}
close EXTRAS;

#
# Load addresses from the metadata.
#
# Exclude support addresses using some XSLT magic.
#
# UK addresses
#
open(XML, xalanCall . " -IN ../xml/ukfederation-metadata-master.xml -XSL extract_addresses.xsl|") || die "could not open input file";
while (<XML>) {
	if (/<EmailAddress>(mailto:)?(.*)<\/EmailAddress>/) {
		$metadata{$2} = 1;
	}
}
close XML;

#
# Now figure out the addresses we want to see in the mailing list.
# Make them lower case for comparisons.
#
foreach $addr (keys %extras) {
	$wanted{lc $addr} = $addr;
}
foreach $addr (keys %metadata) {
	$wanted{lc $addr} = $addr;
}

#
# Similar lower-case hash for the current list.
#
foreach $addr (keys %list) {
	$have{lc $addr} = $addr;
}

#
# Cancel the ones that are *in* the mailing list from the wanted
# collection.  Whine about (now) unwanted entries in the
# mailing list.
#
$first = 1;
foreach $addr (sort keys %have) {
	my $a = $have{$addr};
	if (defined($wanted{$addr})) {
		delete $wanted{$addr};
	} else {
		if ($first) {
			$first = 0;
			print "\nDelete unwanted: \n";
		}
		print "$a\n";
	}
}

#
# List the ones that are wanted, but not yet in the list.
#
$first = 1;
foreach $addr (keys %wanted) {
	my $a = $wanted{$addr};
	if ($first) {
		$first = 0;
		print "\nAdd wanted: \n";
	}
	print "$a\n";
}
