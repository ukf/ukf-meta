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
# Size of fixed-width expiry statistical bins.
#
my $binSize = 90;

my @quarterStartDays = (
	"2012-10-01", # 4Q2012
	"2013-01-01", # 1Q2013
	"2013-04-01", # 2Q2013
	"2013-07-01", # 3Q2013
	"2013-10-01", # 4Q2013
	"2014-01-01"  # 1Q2014
);

my @binNames = (
	"expired",
	"3Q2012",
	"4Q2012",
	"1Q2013",
	"2Q2013",
	"3Q2013",
	"4Q2013",
	"2014...",
);

my $quarterEndTimes = ();
for $startDay (@quarterStartDays) {
	#print "startDay is $startDay\n";
	my $endTime = str2time($startDay . "T00:00:00")-1;
	push(@quarterEndTimes, $endTime);
}

#
# Proposed evolution deadline.
#
my $deadline = "2014-01-01T00:00:00";
my $deadlineTime = str2time($deadline);

my $excessThreshold = 5; # years

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
			
			if (/Not Before: (.*)$/) {
				$notBefore = $1;
				$noteBeforeTime = str2time($notBefore);
			}

			if (/Not After : (.*)$/) {
				$notAfter = $1;
				$notAfterTime = str2time($notAfter);
				$days = ($notAfterTime-time())/86400.0;
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
		# For non-1024-bit keys, just look at whether it is expired.
		#
		if ($pubSize != 1024) {
			if ($days < 0) {
				error("EXPIRED");
				$expiredOther++;
			}
		}

		#
		# Record expiry bin if 1024-bit key.
		#
		if ($pubSize == 1024) {

			#
			# Complain about keys with an excessive cryptoperiod (more than
			# about three years).
			#
			my $validYears = ($notAfterTime - $noteBeforeTime)/(86400.0*365.0);
			my $years = sprintf "%.1f", $validYears;
			if ($validYears >= $excessThreshold) {
				error("excess cryptoperiod $years years expires $notAfter");
				$excessCount++;
			}

			#
			# First expiry binning is on the basis of number of days left to
			# run.  Bin -1 is for expired certificates, bin 99 is for those that
			# expire on or after 2014-01-01T00:00:00.
			#
			if ($days < 0) {
				$expiryBin = -1;
				if ($days < -180) {
					my $d = floor(-$days);
					error("long-expired ($d days) 1024-bit certificate");
				} else {
					warning("expired 1024-bit certificate");
				}
			} else {
				$expiryBin = floor($days/$binSize);
			}
			if ($expiryBin == 0) {
				# print "Expiry bin 0 dated $notAfter on $entity\n";
			} elsif ($notAfterTime > $deadlineTime) {
				warning("long expiry dated $notAfter");
				$expiryBin = 99;
				comment("issued by $issuerCN");
				if ($validYears >= $excessThreshold) {
					$excessPlusDeadline++;
				}
			}
			$expiryBinned{$expiryBin}++;

			#
			# Second expiry binning is on the basis of calendar quarter bins.
			#
			if ($days < 0) {
				$expiryBin = -1;
			} else {
				$expiryBin = 99;
				my $bin = 0;
				for $quarterEndTime (@quarterEndTimes) {
					if ($notAfterTime <= $quarterEndTime) {
						$expiryBin = $bin;
						last;
					}
					$bin++;
				}
			}
			$expiryQuarterCount{$expiryBin}++;
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

	print "\nExpiry bins:\n";
	$total = 0;
	for $bin (sort numerically keys %expiryBinned) {
		$days = $binSize * $bin;
		$count = $expiryBinned{$bin};
		$total += $count;
		print "   $bin: $count\n";
	}
	print "Total: $total\n";

	print "\nExpiry quarters:\n";
	$total = 0;
	for $bin (sort numerically keys %expiryQuarterCount) {
		$count = $expiryBinned{$bin};
		$total += $count;
		if ($bin == 99) {
			$binName = ">=2014";
		} else {
			$binName = $binNames[$bin+1];
		}
		print "   $binName: $count\n";
	}
	print "Total: $total\n";

	print "\n";
	print "Excess cryptoperiod threshold: $excessThreshold\n";
	print "Excess cryptoperiod: $excessCount\n";
	print "Excess plus deadline: $excessPlusDeadline\n";
	print "Expired, other key sizes: $expiredOther\n";
}
