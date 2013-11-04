#!/usr/bin/env perl -w

#
# shortkeys.pl
#
# Extracts statistics about short embedded keys from the published metadata.
#
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
	open(TXT, "perl shortkeys_inner.pl -q <temp.tmp|") || die "could not open input file";
	my $count = 0;
	while (<TXT>) {
		if (/^   1024: (\d+)$/) {
			$count = $1;
		}
		#print $_;
	}
	push @counts, "$month: $count";
	close TXT;
}

print "Key count:\n";
foreach $count (@counts) {
	print "$count\n";
}
