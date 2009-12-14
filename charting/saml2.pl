#!/usr/bin/perl -w

#
# saml2.pl
#
# Extracts statistics about SAML 2 adoption from the published metadata.
#
use lib "../build";
use Xalan;

@months = (
	'2006-12',
	'2007-01', '2007-02', '2007-03', '2007-04', '2007-05', '2007-06',
	'2007-07', '2007-08', '2007-09', '2007-10', '2007-11', '2007-12',
	'2008-01', '2008-02', '2008-03', '2008-04', '2008-05', '2008-06',
	'2008-07', '2008-08', '2008-09', '2008-10', '2008-11', '2008-12',
	'2009-01', '2009-02', '2009-03', '2009-04', '2009-05', '2009-06',
	'2009-07', '2009-08', '2009-09', '2009-10', '2009-11', '2009-12',
);

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