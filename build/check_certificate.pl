#!/usr/bin/perl -w
use File::Temp qw(tempfile);
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

#
# Check individual certificate files.
#
# This utility performs certificate checking against raw certificate files.
#
#		./check_certificate.pl /tmp/foo.pem
#
open(PIPE, "|(cd ../xml;perl ../build/check_embedded.pl)")
	|| die 'could not open certificate check process';

while (@ARGV) {
	$fn = shift @ARGV;
	open(IN, $fn) || die "could not open $fn: $!";
	print PIPE "Entity: $fn keyname (none)\n";
	while (<IN>) {
		print PIPE $_;
	}
	close IN;
}

close PIPE;
