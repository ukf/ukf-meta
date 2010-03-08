#!/usr/bin/perl -w
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

while (<>) {

	#
	# Handle certificate header line.
	#
	if (/BEGIN CERTIFICATE/) {
		
		#
		# Output header line.
		#
		print "Authority certificate:\n";

		#
		# Create a temporary file for this certificate in PEM format.
		#
		($fh, $filename) = tempfile(UNLINK => 1);
		#print "temp file is: $filename\n";

		# do not buffer output to the temporary file
		select((select($fh), $|=1)[0]);
	}
	
	#
	# Put all lines into a temporary file.
	#
	print $fh $_;
	
	#
	# If this is the last line of the certificate, actually do
	# something with it.
	#
	if (/END CERTIFICATE/) {
		#
		# Don't close the temporary file yet, because that would cause it
		# to be deleted.  We've already arranged for buffering to be
		# disabled, so the file can simply be passed to other applications
		# as input, perhaps multiple times.
		#
		
		#
		# Use openssl to convert the certificate to text
		#
		my(@lines, $issuer, $subjectCN, $issuerCN, $pubSize);
		$cmd = "openssl x509 -in $filename -noout -text -nameopt RFC2253 -modulus |";
		open(SSL, $cmd) || die "could not open openssl subcommand";
		while (<SSL>) {
			push @lines, $_;
			if (/^\s*Issuer:\s*(.*)$/) {
				$issuer = $1;
				print "   Issuer: $issuer\n";
			}
			if (/^\s*Subject:\s*(.*)$/) {
				$subject = $1;
				print "   Subject: $subject\n" unless $subject eq $issuer;
			}
			if (/RSA Public Key: \((\d+) bit\)/) {
				$pubSize = $1;
				print "   Public key size: $pubSize\n";
				if ($pubSize < 1024) {
					print "      *** PUBLIC KEY TOO SHORT ***\n";
				}
			}
			if (/Not After : (.*)$/) {
				$notAfter = $1;
				$days = (str2time($notAfter)-time())/86400.0;
				if ($days < 0) {
					print "   *** EXPIRED ***\n";
				} elsif ($days < 365) {
					$days = int($days);
					print "   *** expires in $days days\n";
				} elsif ($days < (365*2)) {
					$days = int($days);
					print "   expires in $days days\n";
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
						print "   *** WEAK DEBIAN KEY ***\n";
					}
				} elsif ($pubSize == 2048) {
					if (defined($rsa2048{$fpr})) {
						print "   *** WEAK DEBIAN KEY ***\n";
					}
				}
			}
			
		}
		close SSL;
		#print "   text lines: $#lines\n";

		#
		# Close the temporary file, which will also cause
		# it to be deleted.
		#
		close $fh;
		
		print "\n";
	}
}
