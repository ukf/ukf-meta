#!/usr/bin/perl -w

use Xalan;

open(XML, xalanCall . " -IN ../mdx/uk/collected.xml -XSL extract_locs.xsl|") || die "could not open input file";
while (<XML>) {
    chop;
    if (/^https:\/\/([^\/:]+)(:\d+)?(\/|$)/) {
        my $location = $1;
        $locations{$location} = 1;
    }
}
close XML;

foreach $loc (sort keys %locations) {
    if ($loc =~ /([^:]+)/) {
        print "$1\n";
    }
}
