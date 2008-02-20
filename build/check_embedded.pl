#!/usr/bin/perl -w
use File::Temp qw(tempfile);

while (<>) {

	#
	# Handle Entity/KeyName header line.
	#
	if (/^Entity:/) {
		@args = split;
		$entity = $args[1];
		$keyname = $args[3];
		
		#
		# Output header line.
		#
		print "Entity $entity ";
		$hasKeyName = !($keyname eq '(none)');
		if ($hasKeyName) {
			print "has KeyName $keyname";
		} else {
			print "has no KeyName";
		}
		print "\n";

		#
		# Create a temporary file for this certificate in PEM format.
		#
		($fh, $filename) = tempfile(UNLINK => 1);
		#print "temp file is: $filename\n";

		# do not buffer output to the temporary file
		select((select($fh), $|=1)[0]);
		next;
	}
	
	#
	# Put other lines into a temporary file.
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
		my(@lines, $issuer, $subjectCN);
		$cmd = "openssl x509 -in $filename -noout -text |";
		open(SSL, $cmd) || die "could not open openssl subcommand";
		while (<SSL>) {
			push @lines, $_;
			if (/^\s*Issuer:\s*(.*)$/) {
				$issuer = $1;
			}
			if (/^\s*Subject:\s*.*CN=([a-z0-9\-\.]+).*$/) {
				$subjectCN = $1;
				# print "subjectCN = $subjectCN\n";
			}
		}
		close SSL;
		#print "   text lines: $#lines\n";

		#
		# Check KeyName if one has been supplied.
		#
		if ($hasKeyName && $keyname ne $subjectCN) {
			print "   *** KeyName mismatch: $keyname != $subjectCN\n";
		}
		
		#
		# Use openssl to ask whether this matches our trust fabric or not.
		#
		my $error = '';
		$serverOK = 1;
		$cmd = "openssl verify -CAfile authorities.pem -purpose sslserver $filename |";
		open(SSL, $cmd) || die "could not open openssl subcommand 2";
		while (<SSL>) {
			chomp;
			if (/error/) {
				$error = $_;
				$serverOK = 0;
			}
		}
		close SSL;
		$clientOK = 1;
		$cmd = "openssl verify -CAfile authorities.pem -purpose sslclient $filename |";
		open(SSL, $cmd) || die "could not open openssl subcommand 3";
		while (<SSL>) {
			chomp;
			if (/error/) {
				$error = $_;
				$clientOK = 0;
			}
		}
		close SSL;
		
		#
		# Irrespective of what went wrong, client and server results should match.
		#
		if ($clientOK != $serverOK) {
			print "   *** client/server purpose result mismatch: $clientOK != $serverOK\n";
		}
		
		#
		# Reduce error if possible.
		#
		if ($error =~ m/^error \d+ at \d+ depth lookup:\s*(.*)$/) {
			$error = $1;
		}
		
		#
		# Now, adjust for our expectations.
		#
		if (!$hasKeyName && $error eq 'self signed certificate') {
			$error = '';
			print "   (self signed certificate)\n";
		}
		if ($hasKeyName && $error eq 'self signed certificate') {
			$error = 'self signed certificate: remove KeyName?';
		}

		if ($error eq 'unable to get local issuer certificate') {
			$error = "unknown issuer: $issuer";
		}

		if ($error ne '') {
			print "   *** $error\n";
		}
		
		#
		# Close the temporary file, which will also cause
		# it to be deleted.
		#
		close $fh;
		
		print "\n";
	}
}
