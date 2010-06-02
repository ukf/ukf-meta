#!/usr/bin/perl -w

#
# sizes.pl
#
use File::stat;
use Months;

# Parse command line arguments
use Getopt::Long;
my $allMonths;
GetOptions('all' => \$allMonths);

# By default, only show results for the most recent month
if (!$allMonths) {
	# reduce months table to one element
	my $oneMonth = pop @months;
	@months = ( $oneMonth );
}

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
