#!/usr/bin/perl -w

use Xalan;

open(XML, xalanCall . " -IN ../xml/ukfederation-metadata-unsigned.xml -XSL extract_saml2sp.xsl|") || die "could not open input file";
while (<XML>) {
	my ($id, $result) = split;
	$results{$id} = $result;
	print $_;
}
close XML;

open(IDS, "ids.txt") || die "could not open ids file";
while (<IDS>) {
	chop;
	$id = $_;
	if (defined $results{$id}) {
		$result = $results{$id};
	} else {
		$result = 'SP?';
	}
	print "$result\n";
}
close IDS;
