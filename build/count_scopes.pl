#!/usr/bin/perl -w

use Xalan;

open(XML, xalanCall . " -IN ../xml/ukfederation-metadata-unsigned.xml -XSL extract_scopes.xsl|") || die "could not open input file";
while (<XML>) {
	# print $_;
	chop;
	my $scope = $_;
	$scopes{$scope} = 1;
}
close XML;

print scalar(keys(%scopes)), "\n";
