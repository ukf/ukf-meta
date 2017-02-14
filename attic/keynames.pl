#!/usr/bin/env perl

#
# keynames.pl
#
# Extracts statistics about KeyName elements from the published metadata.
#
use warnings;
use lib "../build";
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
	print "processing $month\n";
	my $fn = "cache/$month.xml";
	my $command = xalanCall . " -IN $fn -XSL ../build/extract_embedded.xsl -OUT temp.tmp";
	# print "command is $command\n";
	system($command); # || print "ignoring claimed failure in sub command\n";
	#print "Xalan run on $fn\n";
	open(TXT, "perl keynames_inner.pl -q <temp.tmp|") || die "could not open input file";
	while (<TXT>) {
		if (/^Total: (\d+)$/) {
			$count = $1;
		}
		print $_ unless $allMonths;
	}
	close TXT;
	push @counts, "$month: $count";
}

if ($allMonths) {
	print "KeyName count:\n";
	foreach $count (@counts) {
		print "$count\n";
	}
}
