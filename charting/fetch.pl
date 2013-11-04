#!/usr/bin/perl -w

#
# fetch.pl
#
use File::stat;
use Months;

$fn = '../xml/ukfederation-metadata.xml';
$fn2 = '../xml/ukfederation-stats.html';

foreach $month (@months) {
	print "Fetching $month...";
	
	my $dest1 = "cache/$month.xml";
	if (!-e $dest1) {
		system("/usr/bin/env svn update $fn --quiet --revision \\{$month-01T00:00:00Z\\}");
		system("cp $fn $dest1");
	}
	
	my $dest2 = "cache/$month.html";
	if (!-e $dest2) {
		system("/usr/bin/env svn update $fn2 --quiet --revision \\{$month-01T00:00:00Z\\}");
		system("cp $fn2 $dest2");
	}
	
	print "\n";
}
