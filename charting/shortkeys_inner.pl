#!/usr/bin/perl -w
use POSIX qw(floor);
use File::Temp qw(tempfile);
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

#
# Perform checks on a series of certificates that are to be, or have been, embedded in the
# UK federation metadata.
#
# The certificates are provided on standard input in PEM format with header lines
# indicating the entity with which they are associated.
#
# Command line options:
#
#	-q	quiet		don't print anything out if there are no problems detected
#

sub error {
	my($s) = @_;
	push(@olines, '   *** ' . $s . ' ***');
	$printme = 1;
}

sub warning {
	my ($s) = @_;
	push(@olines, '   ' . $s);
	$printme = 1;
}

sub comment {
	my($s) = @_;
	push(@olines, '   (' . $s . ')');
}

#
# Process command-line options.
#
while (@ARGV) {
	$arg = shift @ARGV;
	$quiet = 1 if $arg eq '-q';
}

#
# Hash of already-seen blobs.
#
# Each entry in the hash is indexed by the blob itself.  Each blob is a concatenated
# sequence of information that uniquely identifies an already checked key.  This is
# used to avoid processing the same blob more than once.
#
my %blobs;

#
# Blob currently being constructed.
#
my $blob;

#
# Size of expiry statistical bins.
#
my $binSize = 90;

#
# Proposed evolution deadline.
#
my $deadline = "2014-01-01T00:00:00";
my $deadlineTime = str2time($deadline);

while (<>) {

	#
	# Discard blank lines.
	#
	next if /^\s*$/;
	
	#
	# Handle Entity/KeyName header line.
	#
	if (/^Entity:/) {
		@olines = ();
		$printme = 0;
		@args = split;
		$entity = $args[1];
		$keyname = $args[3];
		
		#
		# Output header line.
		#
		$oline = "Entity $entity ";
		$hasKeyName = !($keyname eq '(none)');
		if ($hasKeyName) {
			$oline .= "has KeyName $keyname";
		} else {
			$oline .= "has no KeyName";
		}
		push(@olines, $oline);
		$blob = $oline;		# start building a new blob

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
	$blob .= '|' . $_;
	
	#
	# If this is the last line of the certificate, actually do
	# something with it.
	#
	if (/END CERTIFICATE/) {
		#
		# Have we seen this blob before?  If so, close (and delete) the
		# temporary file, and go and look for a new certificate to process.
		#
		$total_certs++;
		if (defined($blobs{$blob})) {
			# print "skipping a blob\n";
			close $fh;
			next;
		}
		
		#
		# Otherwise, remember this blob so that we won't process it again.
		#
		$blobs{$blob} = 1;
		$distinct_certs++;

		#
		# Don't close the temporary file yet, because that would cause it
		# to be deleted.  We've already arranged for buffering to be
		# disabled, so the file can simply be passed to other applications
		# as input, perhaps multiple times.
		#
		
		#
		# Collection of names this certificate contains
		#
		my %names;
		
		#
		# Use openssl to convert the certificate to text
		#
		my(@lines, $issuer, $subjectCN, $issuerCN);
		$cmd = "openssl x509 -in $filename -noout -text -nameopt RFC2253 -modulus |";
		open(SSL, $cmd) || die "could not open openssl subcommand: $!";
		$expiryBin = -1;
		while (<SSL>) {
			push @lines, $_;

			if (/^\s*Issuer:\s*(.*)$/) {
				$issuer = $1;
				if ($issuer =~ /CN=([^,]+)/) {
					$issuerCN = $1;
				} else {
					$issuerCN = $issuer;
				}
				next;
			}
			
			if (/^\s*Subject:\s*.*?CN=([a-zA-Z0-9\-\.]+).*$/) {
				$subjectCN = $1;
				$names{lc $subjectCN}++;
				# print "subjectCN = $subjectCN\n";
				next;
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
				$days = (str2time($notAfter)-time())/86400.0;
				next;
			}
			
		}
		close SSL;

		#
		# Check KeyName if one has been supplied.
		#
		if ($hasKeyName && !defined($names{lc $keyname})) {
			my $nameList = join ", ", sort keys %names;
			error("KeyName mismatch: $keyname not in {$nameList}");
		}
		
		#
		# Use openssl to ask whether this matches our trust fabric or not.
		#
		my $error = '';
		
		#
		# Close the temporary file, which will also cause
		# it to be deleted.
		#
		close $fh;

		#
		# Record expiry bin if 1024-bit key.
		#
		if ($pubSize == 1024) {
			if ($days < 0) {
				$expiryBin = -1;
				print "expired 1024-bit certificate on $entity\n";
			} else {
				$expiryBin = floor($days/$binSize);
			}
			if ($expiryBin == 0) {
				print "Expiry bin 0 dated $notAfter on $entity\n";
			} elsif ($notAfterTime > $deadlineTime) {
				print "Long expiry dated $notAfter on $entity\n";
				$expiryBin = 99;
				print "   issued by $issuerCN\n";
			}
			$expiryBinned{$expiryBin}++;
		}

		#
		# Print any interesting things related to this certificate.
		#
		if ($printme || !$quiet) {
			foreach $oline (@olines) {
				print $oline, "\n";
			}
			print "\n";
		}
	}
}

sub numerically {
	$a <=> $b;
}

if ($total_certs > 1) {
	print "Total certificates: $total_certs\n";
	if ($distinct_certs != $total_certs) {
		print "Distinct certificates: $distinct_certs\n";
	}
	print "Key size distribution:\n";
	for $pubSize (sort keys %pubSizeCount) {
		$count = $pubSizeCount{$pubSize};
		print "   $pubSize: $count\n";
	}
	print "Expiry bins:\n";
	$total = 0;
	for $bin (sort numerically keys %expiryBinned) {
		$days = $binSize * $bin;
		$count = $expiryBinned{$bin};
		$total += $count;
		print "   $bin: $count\n";
	}
	print "Total: $total\n";
}
