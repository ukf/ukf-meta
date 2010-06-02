#!/usr/bin/perl -w

#
# trust.pl
#
# Extracts statistics about trust model support from the published metadata.
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
	open(TXT, xalanCall . " -IN $fn -XSL trust.xsl|") || die "could not open input file";
	$_ = <TXT>;
	chop;
	my ($entities, $idps, $sps, $dk_total, $dk_idp, $dk_sp, $pk_total, $pk_idp, $pk_sp) = split;
	push @overallRatio, $dk_total/$entities;
	push @idpRatio, $dk_idp/$idps;
	push @spRatio, $dk_sp/$sps;
	push @PKoverallRatio, $pk_total/$entities;
	push @PKidpRatio, $pk_idp/$idps;
	push @PKspRatio, $pk_sp/$sps;
	close TXT;
}

print "idp\n";
foreach $ratio (@idpRatio) {
	print "$ratio\n";
}

print "sp\n";
foreach $ratio (@spRatio) {
	print "$ratio\n";
}

print "overall\n";
foreach $ratio (@overallRatio) {
	print "$ratio\n";
}

print "PKidp\n";
foreach $ratio (@PKidpRatio) {
	print "$ratio\n";
}

print "PKsp\n";
foreach $ratio (@PKspRatio) {
	print "$ratio\n";
}

print "PKoverall\n";
foreach $ratio (@PKoverallRatio) {
	print "$ratio\n";
}

1;
