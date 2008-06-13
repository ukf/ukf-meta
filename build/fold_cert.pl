#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not have one
# or more unfolded X.509 embedded certificates in it.  Fold these
# to a max of 64 characters per Base64 line, but preserve
# XML indentation.
#

$max = 64;	# max chars per line

while (<>) {
	if (/^(\s*)\<ds:X509Certificate\>(.*)\<\/ds:X509Certificate\>\s*$/) {
		$sp = $1;
		$spp = "$1    "; # add four spaces
		$cert = $2;
		print "$sp<ds:X509Certificate>\n";
			while (length($cert) != 0) {
				$line = $cert;
				if (length($line) > $max) {
					$line = substr($line, 0, $max)
				}
				print "$spp$line\n";
				substr($cert, 0, length($line)) = '';
			}
		print "$sp</ds:X509Certificate>\n";
	} else {
		print $_;
	}
}

# end
