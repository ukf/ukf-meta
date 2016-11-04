#!/usr/bin/env perl -w

#
# fetch.pl
#
use File::stat;
use Months;

# Call git on the products directory
my $git = "/usr/bin/env git -C ../../ukf-products";

$fn1 = 'aggregates/ukfederation-metadata.xml';
$fn2 = 'aggregates/ukfederation-stats.html';

foreach $month (@months) {
	print "Fetching $month...";

	# Find the commit immediately prior to the start of that month.
	my $instant = "$month-01T00:00:00Z";
	my $commit = `$git rev-list -n 1 --before=$instant master`;
	chomp $commit;
	print "$commit";

	my $dest1 = "cache/$month.xml";
	if (!-e $dest1) {
		system("$git show $commit:$fn1 >$dest1");
	}

	my $dest2 = "cache/$month.html";
	if (!-e $dest2) {
		system("$git show $commit:$fn2 >$dest2");
	}

	print "\n";
}
