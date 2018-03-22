#!/usr/bin/perl -w

open(XML, xalanCall . "xsltproc extract_locs.xsl ../mdx/int_edugain/imported.xml|") || die "could not open input file";
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
