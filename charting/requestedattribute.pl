#!/usr/bin/env perl

#
# requestedattribute.pl
#
# Extracts statistics about SPs with RequestedAttribute elements from the published metadata.
#
use warnings;
use lib ".";
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

# print header. must be kept in sync with what comes out of requestedattribute.xsl
print "# month, number of SPs, number with AttributeConsumingService, percent with ACS\n";

# ingest files
foreach $month (@months) {
	my $fn = "cache/$month.xml";
	open(TXT, "xsltproc requestedattribute.xsl $fn|") || die "could not open input file";
	($sps, $acs) = split /\t/, <TXT>;
	chomp $acs;
	$proportion = 0;
	if ( $sps > 0 ) { $proportion = int (100 * $acs / $sps) ; }
	print "${month}\t${sps}\t${acs}\t${proportion}\n";
	close TXT;
}

