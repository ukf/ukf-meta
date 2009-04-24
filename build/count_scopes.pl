#!/usr/bin/perl -w

open(XML,"java -cp ../xalan-j_2_6_0/bin/xalan.jar org.apache.xalan.xslt.Process -IN ../xml/ukfederation-metadata-unsigned.xml -XSL extract_scopes.xsl|") || die "could not open input file";
while (<XML>) {
	# print $_;
	chop;
	my $scope = $_;
	$scopes{$scope} = 1;
}
close XML;

print scalar(keys(%scopes)), "\n";
