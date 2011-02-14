#!/usr/bin/perl -w

#
# Months.pm
#
use File::stat;
use Date::Manip::Date;
use Date::Manip::Delta;

@months = ( );

$date = new Date::Manip::Date;
$date->parse_date('2006-12-01') && die('could not parse base date');

$now = new Date::Manip::Date;
$now->parse('today') && die('could not parse today');

$oneMonth =  new Date::Manip::Delta;
$oneMonth->parse("1 month") && die('could not parse delta');

#
# Enumerate all month beginnings that have already happened, then stop.
#
while ($date->cmp($now) < 0) {
	local $dateStr = $date->printf('%Y-%m');
	# print "date string $dateStr\n";
	push @months, $dateStr;
	
	# move on one month
	$date = $date->calc($oneMonth);
}

1;
