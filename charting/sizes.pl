#!/usr/bin/env perl

#
# sizes.pl
#
use warnings;
use lib ".";
use File::stat;
use Months;

# Parse command line arguments
use Getopt::Long;
my $allMonths;
my $oneYear;
GetOptions('all' => \$allMonths, 'year' => \$oneYear);

# By default, only show results for the most recent month
if ($allMonths) {
	# leave table intact
} elsif ($oneYear) {
	# reduce months table to just the last 12 entries
	@months = @months[-12..-1];
} else {
	# reduce months table to one element
	@months = @months[-1..-1];
}

# ingest files
foreach $month (@months) {
	print "Processing $month\n";

	#
	# Process the archived file, representing all entities,
	# including those imported from other federations.
	#
	my $fn = "cache/$month.xml";
	my $stat = stat($fn);
	my $all_size = $stat->size;
	my $all_count = int(`grep '</Entity' $fn | wc -l`);
	my $all_ratio = int($all_size/$all_count);
	push @all_sizes,  $all_size;
	push @all_counts, $all_count;
	push @all_ratios, $all_ratio;

	#
	# Now generate a reduced version of the archived
	# file that contains only UK federation registered entities.
	#
	my $command = "xsltproc --output temp.tmp just_ours.xsl $fn";
	# print "command is $command\n";
	system($command); # || print "ignoring claimed failure in sub command\n";
	# print "xsltproc run on $fn\n";

	#
	# Process the reduced version of the archived file.
	#
	$fn = "temp.tmp";
	$stat = stat($fn);
	my $our_size = $stat->size;
	my $our_count = int(`grep '</Entity' $fn | wc -l`);
	my $our_ratio = int($our_size/$our_count);
	push @our_sizes,  $our_size;
	push @our_counts, $our_count;
	push @our_ratios, $our_ratio;
}

print "months\n";
foreach $month (@months) {
	print "$month\n";
}

print "sizeM (all)\n";
foreach $size (@all_sizes) {
	$size /= 1000000;
	print "$size\n";
}

print "sizeM (UK)\n";
foreach $size (@our_sizes) {
	$size /= 1000000;
	print "$size\n";
}

print "entities (all)\n";
foreach $count (@all_counts) {
	print "$count\n";
}

print "entities (UK)\n";
foreach $count (@our_counts) {
	print "$count\n";
}

print "ratioK (all)\n";
foreach $ratio (@all_ratios) {
	$ratio /= 1000;
	print "$ratio\n";
}

print "ratioK (UK)\n";
foreach $ratio (@our_ratios) {
	$ratio /= 1000;
	print "$ratio\n";
}
