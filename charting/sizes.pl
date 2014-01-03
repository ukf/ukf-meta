#!/usr/bin/perl -w

#
# sizes.pl
#
use lib "../build";
use File::stat;
use Xalan;
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
	my $command = xalanCall . " -IN $fn -XSL just_ours.xsl -OUT temp.tmp";
	# print "command is $command\n";
	system($command); # || print "ignoring claimed failure in sub command\n";
	# print "Xalan run on $fn\n";

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
