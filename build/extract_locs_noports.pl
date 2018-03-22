#!/usr/bin/perl -w

open(XML, xalanCall . "xsltproc extract_locs.xsl ../mdx/uk/collected.xml|") || die "could not open input file";
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
