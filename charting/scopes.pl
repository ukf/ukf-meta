#!/usr/bin/env perl -w

#
# scopes.pl
#
# Extracts statistics about number of scopes from the published metadata.
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
	my $fn = "cache/$month.xml";
	my %scopes;
	open(TXT, xalanCall . " -IN $fn -XSL scopes.xsl|") || die "could not open input file";
	while (<TXT>) {
		chop;
		my $scope = $_;
		$scopes{$scope} = 1;
	}
	my $prefix = scalar(@months) == 1 ? '' : "$month: ";
	my $c = scalar(keys(%scopes));
	push @count, "$prefix$c";
	close TXT;
}

print "count\n";
foreach $n (@count) {
	print "$n\n";
}

1;
