#!/usr/bin/perl -w

use ExtractCert;
use Xalan;

print "Loading endpoint locations...\n";
open(XML, xalanCall . " -IN ../xml/ukfederation-metadata.xml -XSL extract_cert_locs.xsl|") || die "could not open input file";
while (<XML>) {
	if (/^http:/) {
		print "skipping http location: $_";
	} elsif (/^https:\/\/([^\/:]+(:\d+)?)\//) {
		my $location = $1;
		$location .= ":443" unless defined $2;
		$locations{$location} = 1;
	} else {
		print "bad location: $_";
	}
}
close XML;

$count = scalar keys %locations;
print "Unique SSL with-certificate locations: $count\n";

#
# Temporary output file for certificate extraction tool.
#
$temp_der = '/tmp/probe_certs.der';

#
# Extract the certificate from each location.
#
foreach $loc (sort keys %locations) {
	print "$count: probing: $loc\n";
	$count--;

	#
	# Remove any old copy of the DER file.
	#
	unlink $temp_der;
	
	#
	# Separate location into host and port.
	#
	my ($host, $port) = split(/:/, $loc);
	#print "host: $host, port: $port\n";
	my $hostPort = "$host:$port";

	#
	# Attempt certificate extraction
	#
	system extractCertCall . " $host $port $temp_der";

	#
	# If the output file doesn't exist, the extraction failed.
	#
	if (!-e $temp_der) {
		print "*** $hostPort: certificate extraction failed\n";
		$failed{$loc} = 1;
		next;
	}
	
	#
	# Use openssl to convert the certificate to text
	#
	my(@lines, $subject, $issuer);
	$cmd = "openssl x509 -in $temp_der -inform der -noout -text -nameopt RFC2253 -modulus |";
	open(SSL, $cmd) || die "could not open openssl subcommand";
	while (<SSL>) {
		push @lines, $_;
		if (/^\s*Issuer:\s*(.*)$/) {
			$issuer = $1;
			#print "$hostPort: issuer is $issuer\n";
		}
		if (/^\s*Subject:\s*(.*)$/) {
			$subject = $1;
		}
	}
	
	if ($subject eq $issuer) {
		$issuer = "(self signed certificate)";
	}

	$issuers{$issuer}{$loc} = 1;
	$numissued++;
}
print "\n\n";

$count = scalar keys %failed;
print "\n\nProbes that failed: $count\n";
foreach $loc (sort keys %failed) {
	print "   $loc\n";
}
print "\n\n";

print "Probes we got an issuer back from: $numissued\n";
$count = scalar keys %issuers;
print "Unique issuers: $count\n";
foreach $issuer (sort keys %issuers) {
	%locs = %{ $issuers{$issuer} };
	$n = scalar keys %locs;
	print "$n: $issuer\n";
	foreach $loc (sort keys %locs) {
		print "   $loc\n";
	} 
}

#
# Clean up
#
unlink $temp_der;
