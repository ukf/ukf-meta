#!/usr/bin/env perl

#
# saml2.pl
#
# Extracts statistics about SAML 2 adoption from the published metadata.
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
	my $fn = "cache/$month.xml";
	open(TXT, xalanCall . " -IN $fn -XSL saml2.xsl|") || die "could not open input file";
	$_ = <TXT>;
	chop;
	# print "$month: $_\n";
	my ($entities, $idps, $sps, $saml2total, $saml2idp, $saml2sp) = split;
	if ($entities == 0) {
		# print "skipping $month: $_\n";
		next;
	}
	my $mPrefix = $allMonths ? "$month: " : '';
	my $oRatio = $saml2total/$entities;
	push @overallRatio, "$mPrefix$oRatio";
	my $iRatio = $saml2idp/$idps;
	push @idpRatio, "$mPrefix$iRatio";
	my $sRatio = $saml2sp/$sps;
	push @spRatio, "$mPrefix$sRatio";
	my $p = ($saml2idp/$idps)*($saml2sp/$sps);
	push @product, "$mPrefix$p";
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

print "product\n";
foreach $ratio (@product) {
	print "$ratio\n";
}

1;
