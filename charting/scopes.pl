#!/usr/bin/perl -w

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
	my %scopes;
	open(TXT, xalanCall . " -IN $fn -XSL scopes.xsl|") || die "could not open input file";
	while (<TXT>) {
		chop;
		my $scope = $_;
		$scopes{$scope} = 1;
	}
	push @count, scalar(keys(%scopes));
	close TXT;
}

print "count\n";
foreach $n (@count) {
	print "$n\n";
}

1;