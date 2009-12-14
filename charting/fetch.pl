#!/usr/bin/perl -w

#
# fetch.pl
#
use File::stat;

$fn = '../xml/ukfederation-metadata.xml';
$fn2 = '../xml/ukfederation-stats.html';

@months = (
	'2006-12',
	'2007-01', '2007-02', '2007-03', '2007-04', '2007-05', '2007-06',
	'2007-07', '2007-08', '2007-09', '2007-10', '2007-11', '2007-12',
	'2008-01', '2008-02', '2008-03', '2008-04', '2008-05', '2008-06',
	'2008-07', '2008-08', '2008-09', '2008-10', '2008-11', '2008-12',
	'2009-01', '2009-02', '2009-03', '2009-04', '2009-05', '2009-06',
	'2009-07', '2009-08', '2009-09', '2009-10', '2009-11', '2009-12',
);

foreach $month (@months) {
	print "Fetching $month...";
	system("svn update $fn --quiet --revision \\{$month-01T00:00:00Z\\}");
	system("cp $fn cache/$month.xml");
	system("svn update $fn2 --quiet --revision \\{$month-01T00:00:00Z\\}");
	system("cp $fn2 cache/$month.html");
	print "\n";
}
