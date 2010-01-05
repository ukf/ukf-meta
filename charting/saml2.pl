#!/usr/bin/perl -w

#
# saml2.pl
#
# Extracts statistics about SAML 2 adoption from the published metadata.
#
use lib "../build";
use Xalan;
use Months;

# ingest files
foreach $month (@months) {
	my $fn = "cache/$month.xml";
	open(TXT, xalanCall . " -IN $fn -XSL saml2.xsl|") || die "could not open input file";
	$_ = <TXT>;
	chop;
	my ($entities, $idps, $sps, $saml2total, $saml2idp, $saml2sp) = split;
	push @overallRatio, $saml2total/$entities;
	push @idpRatio, $saml2idp/$idps;
	push @spRatio, $saml2sp/$sps;
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

1;