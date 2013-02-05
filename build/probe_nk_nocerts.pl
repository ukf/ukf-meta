#!/usr/bin/perl -w

use POSIX qw(floor);
use Date::Parse;
use ExtractCert;
use Xalan;

sub error {
	my($s) = @_;
	print '   *** ' . $s . ' ***' . "\n";
	$printme = 1;
}

sub warning {
	my ($s) = @_;
	print '   ' . $s . "\n";
	$printme = 1;
}

sub comment {
	my($s) = @_;
	print '   (' . $s . ')' . "\n";
}

$known_bad{'census.data-archive.ac.uk:8080'} = 1; # it is really http, not https

#
# Number of days in the past we should regard as "long expired".
#
my $longExpiredDays = 30*3; # about three months

print "Loading endpoint locations...\n";
open(XML, xalanCall . " -IN ../xml/ukfederation-metadata.xml -XSL extract_nk_nocert_locs.xsl|") || die "could not open input file";
while (<XML>) {
	my ($entity, $url) = split;
	if ($url =~ /^https:\/\/([^\/:]+(:\d+)?)(\/|$)/) {
		my $location = $1;
		$location .= ":443" unless defined $2;
		if ($known_bad{$location}) {
			print "skipping known bad location: $_\n";
		} else {
			$locations{$location} = $entity;
		}
	} else {
		print "bad location: $_\n";
	}
}
close XML;

$count = scalar keys %locations;
print "Unique SSL non-certificate locations: $count\n";

#
# Temporary output file for certificate extraction tool.
#
$temp_der = '/tmp/probe_nocerts.der';

#
# Extract the certificate from each location.
#
foreach $loc (sort keys %locations) {
	my $entity = $locations{$loc};
	print "$count: probing $entity: $loc\n";
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
	# Use openssl to convert the certificate to text
	#
	my(@lines, $issuer, $subjectCN, $issuerCN);
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

		#
		# Extract the public key size.  This is displayed differently
		# in different versions of OpenSSL.
		#
		if (/RSA Public Key: \((\d+) bit\)/) { # OpenSSL 0.9x
			$pubSize = $1;
			$pubSizeCount{$pubSize}++;
			# print "   Public key size: $pubSize\n";
			if ($pubSize < 1024) {
				error('PUBLIC KEY TOO SHORT');
			}
			next;
		} elsif (/^\s*Public-Key: \((\d+) bit\)/) { # OpenSSL 1.0
			$pubSize = $1;
			$pubSizeCount{$pubSize}++;
			# print "   Public key size: $pubSize\n";
			if ($pubSize < 1024) {
				error('PUBLIC KEY TOO SHORT');
			}
			next;
		}
		
		if (/Not After : (.*)$/) {
			$notAfter = $1;
			$notAfterTime = str2time($notAfter);
			$days = ($notAfterTime-time())/86400.0;
			if ($days < -$longExpiredDays) {
				my $d = floor(-$days);
				error("EXPIRED LONG AGO ($d days; $notAfter)");
			} elsif ($days < 0) {
				error("EXPIRED ($notAfter)");
			} elsif ($days < 18) {
				$days = int($days);
				error("expires in $days days ($notAfter)");
			} elsif ($days < 36) {
				$days = int($days);
				warning("expires in $days days ($notAfter)");
			}
			next;
		}

	}

	if ($pubSize < 2048) {
		warning("short public key: $pubSize bits, certificate expires $notAfter");
	}

	if ($subject eq $issuer) {
		$issuer = "(self-signed certificate)";
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
