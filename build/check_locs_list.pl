#!/usr/bin/perl -w

use ExtractCert;
use File::Temp qw(tempfile);
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

#
# Load RSA key blacklists.
#
print "Loading key blacklists...\n";
open KEYS, '../build/blacklist.RSA-1024' || die "can't open RSA 1024 blacklist";
while (<KEYS>) {
	chomp;
	$rsa1024{$_} = 1;
}
close KEYS;
open KEYS, '../build/blacklist.RSA-2048' || die "can't open RSA 2048 blacklist";
while (<KEYS>) {
	chomp;
	$rsa2048{$_} = 1;
}
close KEYS;
print "Blacklists loaded.\n";

#
# Temporary output file for certificate extraction tool.
#
$temp_der = '/tmp/cert.der';

while (<>) {

	#
	# Each line of input contains at least a host name, and optionally
	# a port number.  The latter defaults to 443 if absent.
	#
	@args = split;
	$host = $args[0];
	$port = $args[1];
	$port = 443 unless $port;
	$hostPort = "$host:$port";

	#
	# Output header line.
	#
	print "Testing $hostPort\n";

	#
	# Remove any old copy of the DER file.
	#
	unlink $temp_der;

	#
	# Attempt certificate extraction
	#
	system extractCertCall . " $host $port $temp_der";

	#
	# If the output file doesn't exist, the extraction failed.
	#
	if (!-e $temp_der) {
		print "*** $hostPort: certificate extraction failed\n";
		next;
	}
	
	#
	# Use openssl to convert the certificate to text
	#
	my(@lines, $issuer, $subjectCN, $issuerCN);
	$cmd = "openssl x509 -in $temp_der -inform der -noout -text -nameopt RFC2253 -modulus |";
	open(SSL, $cmd) || die "could not open openssl subcommand";
	while (<SSL>) {
		push @lines, $_;
		if (/^\s*Issuer:\s*(.*)$/) {
			$issuer = $1;
			if ($issuer =~ /CN=([^,]+)/) {
				$issuerCN = $1;
			} else {
				$issuerCN = $issuer;
			}
		}
		if (/^\s*Subject:\s*.*?CN=([a-z0-9\-\.]+).*$/) {
			$subjectCN = $1;
			# print "subjectCN = $subjectCN\n";
		}
		if (/RSA Public Key: \((\d+) bit\)/) {
			$pubSize = $1;
			# print "   Public key size: $pubSize\n";
			if ($pubSize < 1024) {
				print "*** $hostPort: PUBLIC KEY TOO SHORT ($pubSize bits)\n";
			}
		}
		if (/Not After : (.*)$/) {
			$notAfter = $1;
			$days = (str2time($notAfter)-time())/86400.0;
			if ($days < 0) {
				print "*** $hostPort: EXPIRED\n";
			} elsif ($days < 30) {
				$days = int($days);
				print "*** $hostPort: expires in $days days\n";
			} elsif ($days < 90) {
				$days = int($days);
				print "$hostPort: expires in $days days\n";
			}
		}

		#
		# Check for weak (Debian) keys
		#
		# Weak key fingerprints loaded from files are hex SHA-1 digests of the
		# line you get from "openssl x509 -modulus", including the "Modulus=".
		#
		if (/^Modulus=(.*)$/) {
			$modulus = $_;
			# print "   modulus: $modulus\n";
			$fpr = sha1_hex($modulus);
			# print "   fpr: $fpr\n";
			if ($pubSize == 1024) {
				if (defined($rsa1024{$fpr})) {
					print "*** $hostPort: WEAK DEBIAN KEY\n";
				}
			} elsif ($pubSize == 2048) {
				if (defined($rsa2048{$fpr})) {
					print "*** $hostPort: WEAK DEBIAN KEY\n";
				}
			}
		}
	}
}
