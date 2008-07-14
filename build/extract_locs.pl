#!/usr/bin/perl -w

open(XML,"java -cp ../xalan-j_2_6_0/bin/xalan.jar org.apache.xalan.xslt.Process -IN ../xml/ukfederation-metadata-unsigned.xml -XSL extract_locs.xsl|") || die "could not open input file";
while (<XML>) {
	chop;
	if (/^https:\/\/([^\/:]+(:\d+)?)(\/|$)/) {
		my $location = $1;
		$location .= ":443" unless defined $2;
		$locations{$location} = 1;
	}
}
close XML;

foreach $loc (sort keys %locations) {
	if ($loc =~ /([^:]+):(\d+)/) {
		print "$1 $2\n";
	}
}
