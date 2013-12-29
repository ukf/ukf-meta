#!/usr/bin/perl -w
use File::Temp qw(tempfile);
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

sub error {
	my($s) = @_;
	print '   *** ' . $s . ' ***' . "\n";
}

sub warning {
	my ($s) = @_;
	print '   ' . $s . "\n";
}

sub comment {
	my($s) = @_;
	print '   (' . $s . ')' . "\n";
}

while (<>) {

	#
	# Handle certificate header line.
	#
	if (/BEGIN CERTIFICATE/) {
		
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
		# Use openssl to convert the certificate to text
		#
		my(@lines, $issuer, $issuerCN, $subject, $subjectCN, $pubSize);
		$cmd = "openssl x509 -in $filename -noout -text -nameopt RFC2253 -modulus |";
		open(SSL, $cmd) || die "could not open openssl subcommand";
		while (<SSL>) {
			push @lines, $_;

			#
			# Extract the issuer and subject names.
			#
			if (/^\s*Issuer:\s*(.*)$/) {
				$issuer = $1;
				next;
			} elsif (/^\s*Subject:\s*(.*)$/) {
				$subject = $1;
				next;
			}
			
			#
			# Extract the public key size.  This is displayed differently
			# in different versions of OpenSSL.
			#
			if (/RSA Public Key: \((\d+) bit\)/) { # OpenSSL 0.9x
				$pubSize = $1;
				next;
			} elsif (/^\s*Public-Key: \((\d+) bit\)/) { # OpenSSL 1.0
				$pubSize = $1;
				next;
			}
			
			#
			# Extract best-before date/time.
			#
			if (/Not After : (.*)$/) {
				$notAfter = $1;
				next;
			}
			
			#
			# Extract the public key modulus and exponent.
			#
			if (/^Modulus=(.*)$/) {
				$modulus = $_;
				# print "   modulus: $modulus\n";
				next;
			} elsif (/Exponent: (\d+)/) {
				$exponent = $1;
				# print "   exponent: $exponent\n";
				next;
			}

		}
		close SSL;
		#print "   text lines: $#lines\n";

		#
		# Close the temporary file, which will also cause
		# it to be deleted.
		#
		close $fh;

		#
		# Print a header, distinguishing the role of the certificate.
		#		
		if ($subject eq $issuer) {
			# self-signed certificate, i.e., root
			print " \n"; # force blank line in Ant output
			print "Root certificate:\n";
			print "   Issuer: $issuer\n";
		} else {
			# not self signed, must be intermediate
			print "Intermediate certificate:\n";
			print "   Issuer: $issuer\n";
			print "   Subject: $subject\n";
		}

		if ($pubSize < 1024) {
			error('PUBLIC KEY TOO SHORT');
		} elsif ($pubSize < 2048) {
			warning("short public key of $pubSize bits");
		}

		#print "   not after $notAfter\n";
		$days = (str2time($notAfter)-time())/86400.0;
		if ($days < 0) {
			print "   *** EXPIRED ***\n";
		} elsif ($days < 365) {
			$days = int($days);
			print "   *** expires in $days days at $notAfter\n";
		} elsif ($days < (365*2)) {
			$days = int($days);
			print "   expires in $days days at $notAfter\n";
		}

		#
		# Look for reasonable public exponent values.
		#
		if (($exponent & 1) == 0) {
			error("RSA public exponent $exponent is even");
		} elsif ($exponent <= 3) {
			error("insecure RSA public exponent $exponent");
		} elsif ($exponent < 65537) {
			warning("small RSA public exponent $exponent")
		}
			
		print "\n";
	}
}
