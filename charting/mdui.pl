#!/usr/bin/env perl -w

#
# mdui.pl
#
use lib "../build";
use Xalan;
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

	my $command = xalanCall . " -IN cache/$month.xml -XSL statistics_mdui.xsl";
	# print "command is $command\n";
	system($command); # || print "ignoring claimed failure in sub command\n";
	# print "Xalan run on $fn\n";
	print "\n";
}
