#!/usr/bin/perl -w
use Xalan;
use File::Temp qw(tempfile);
use Date::Parse;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

#
# Check individual entity fragment files.
#
# This utility is intended for use immediately before checking in a new entity fragment,
# or prior to checking in major changes such as to embedded trust certificates.
#
# At present, checking embedded certificates is all that this utility does, but we
# could extend it if required.
#
# The fragment is indicated by a numeric parameter, e.g. 999 would indicate uk000999.xml
#
#		./check_entity 123
#
while (@ARGV) {
	$id = shift @ARGV;
	$id = sprintf('uk%06d', $id);
	print "Processing $id...\n";
	$fn = "../entities/$id.xml";
	if (not -e $fn) {
		print "   *** NO SUCH FILE: $fn ***\n";
	} else {
		# temporary file
		$temp = '../xml/embedded.pem';
		unlink($temp) if -e $temp;
		
		# extract embedded certificates
		open(EXTRACT, xalanCall . " -IN $fn -OUT $temp -XSL extract_embedded.xsl|")
		 	|| die "could not open certificate extract process";
		while (<EXTRACT>) {
			print $_;
		}
		close EXTRACT;
		die "no embedded certificates extracted" unless -e $temp;
		
		# check embedded certificates
		open(CHECK, "cd ../xml; perl ../build/check_embedded.pl <$temp|")
			|| die "could not open certificate check process";
		while (<CHECK>) {
			next if /^Loading key blacklists\.\.\./;
			next if /^Blacklists loaded\./;
			print $_;
		}
		close CHECK;
		
		# clean up
		unlink($temp) if -e $temp;
	}
}
