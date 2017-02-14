#!/usr/bin/env perl

use warnings;
use POSIX qw(floor);
use File::Temp qw(tempfile);
use Date::Format;
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

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
# The day that follows the end of each bin.
#
# Bin 0, running from 2014-01-01 to 2014-01-31,
# is followed by the start of bin 1 on 2014-02-01.
#
my @binNextDays = (
	"2014-02-01",
	"2014-03-01",
	"2014-04-01",
	"2014-05-01",
	"2014-06-01",
	"2014-07-01",
	"2014-08-01",
	"2014-09-01",
	"2014-10-01",
	"2014-11-01",
	"2014-12-01",
	"2015-01-01", # 1Q2015
	"2015-04-01", # 2Q2015
	"2015-07-01", # 3Q2015
	"2015-10-01", # 4Q2015
	"2016-01-01", # 2016
	"2017-01-01", # 2017
	"2018-01-01", # 2018...
);

#
# Names for bins. The index into this array is
# displaced by 1, so that the first element (index 0)
# gives the name for bin -1 ("expired").
#
my @binNames = (
	"expired",
	"Jan 14",
	"Feb 14",
	"Mar 14",
	"Apr 14",
	"May 14",
	"Jun 14",
	"Jul 14",
	"Aug 14",
	"Sep 14",
	"Oct 14",
	"Nov 14",
	"Dec 14",
	"2015Q1",
	"2015Q2",
	"2015Q3",
	"2015Q4",
	"2016",
	"2017",
);

my $binEndTimes = ();
for $startDay (@binNextDays) {
	#print "startDay is $startDay\n";
	my $endTime = str2time($startDay . "T00:00:00")-1;
	push(@binEndTimes, $endTime);
	# local $endTimeText = time2str('%Y-%m-%dT%H:%M:%S', $endTime);
	# print "end time corresponding to $startDay is $endTime ($endTimeText)\n";
}

#
# Proposed evolution deadline.
#
my $deadline = "2015-01-01T00:00:00";
my $deadlineTime = str2time($deadline);

#
# Start of the current month, as an approximation of what we want
# to regard as an "expired" certificate.  Ideally, this would be
# passed in as a parameter.
#
#my $nowYearMonth = '2012-08-01T00:00:00';
my $nowYearMonth = time2str('%Y-%m-01T00:00:00', time());
my $validStart = str2time($nowYearMonth);

#
# Total size of deduplicated blobs.
#
my $dedupTotal = 0;

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
		# Output header line.
		#
		$oline = "Entity $entity ";
		$hasKeyName = !($keyname eq '(none)');
		if ($hasKeyName) {
			$oline .= "has KeyName $keyname";
		} else {
			$oline .= "has no KeyName";
		}
		push(@olines, $oline);

		# Start the blob like this if you want per-entity deduplication
		# $blob = $oline;		# start building a new blob

		# Start the blob like this if you want global deduplication
		$blob = "";

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
		# If the certificate is not associated with a KeyName,
		# we ignore it entirely.
		#
		if (!$hasKeyName) {
			# print "ignoring certificate with no KeyName\n";
			close $fh;
			next;
		}

		#
		# Have we seen this blob before?  If so, close (and delete) the
		# temporary file, and go and look for a new certificate to process.
		#
		$total_certs++;
		if (defined($blobs{$blob})) {
			$dedupTotal += (length($blob) - length($_) - 1);
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
		# Use openssl to convert the certificate to text
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

			if (/Not After : (.*)$/) {
				$notAfter = $1;
				$notAfterTime = str2time($notAfter);
				$days = ($notAfterTime-$validStart)/86400.0;
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
		# Expiry binning is on the basis of calendar period bins.
		#
		# Bin -1 is for expired certificates, bin 99 is for those that
		# expire on or after 2018-01-01T00:00:00.
		#
		if ($days < 0) {
			$expiryBin = -1;
		} else {
			$expiryBin = 99;
			my $bin = 0;
			for $binEndTime (@binEndTimes) {
				if ($notAfterTime <= $binEndTime) {
					$expiryBin = $bin;
					last;
				}
				$bin++;
			}
		}
		# print "date $notAfter gets bin $expiryBin\n";
		$expiryBinCount{$expiryBin}++;

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

	print "\nExpiry bins:\n";
	$total = 0;
	for $bin (sort numerically keys %expiryBinCount) {
		if (defined($expiryBinCount{$bin})) {
			$count = $expiryBinCount{$bin};
		} else {
			$count = 0; # nothing was put in that bin
		}
		$total += $count;
		if ($bin == 99) {
			$binName = ">=2018";
		} else {
			$binName = $binNames[$bin+1];
		}
		print "   $binName: $count\n";
	}
	print "Total: $total\n";

	print "\n";

	print "Deduplication saves: $dedupTotal\n";
}
