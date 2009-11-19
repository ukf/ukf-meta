#!/usr/bin/perl -w

#
# sizes.pl
#
use File::stat;

@months = (
	'2006-12',
	'2007-01', '2007-02', '2007-03', '2007-04', '2007-05', '2007-06',
	'2007-07', '2007-08', '2007-09', '2007-10', '2007-11', '2007-12',
	'2008-01', '2008-02', '2008-03', '2008-04', '2008-05', '2008-06',
	'2008-07', '2008-08', '2008-09', '2008-10', '2008-11', '2008-12',
	'2009-01', '2009-02', '2009-03', '2009-04', '2009-05', '2009-06',
	'2009-07', '2009-08', '2009-09', '2009-10', '2009-11',	
);

# ingest files
foreach $month (@months) {
	my $fn = "cache/$month.xml";
	$stat = stat($fn);
	$size = $stat->size;
	$wc = int(`grep '</Entity' $fn | wc -l`);
	$ratio = int($size/$wc);
	push @sizes, $size;
	push @counts, $wc;
	push @ratios, $ratio;
}

print "months\n";
foreach $month (@months) {
	print "$month\n";
}

print "size\n";
foreach $size (@sizes) {
	print "$size\n";
}

print "sizeM\n";
foreach $size (@sizes) {
	$size /= 1000000;
	print "$size\n";
}

print "entities\n";
foreach $count (@counts) {
	print "$count\n";
}

print "ratio\n";
foreach $ratio (@ratios) {
	print "$ratio\n";
}

print "ratioK\n";
foreach $ratio (@ratios) {
	$ratio /= 1000;
	print "$ratio\n";
}
