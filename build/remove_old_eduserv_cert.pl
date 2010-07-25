#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the old Eduserv gateway certificate removed from it.  Remove the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIID7jCCA1egAwIBAgIQHJ62fRr9Z6oWeYtsoVKvgzANBgkqhkiG9w0BAQUFADCB';

while (<>) {

	if (/$old_cert_line/) {
		$delete = 1;
	}
	
	if ($ended) {
		print $_;
	} else {
		push @lines, $_;
		if ($delete && /<\/KeyDescriptor/) {
			while ((pop @lines) !~ /<KeyDescriptor/) {
				# remove the KeyDescriptor body back to its initial line
			}
			undef $delete;
		}
	}
	
	# at the end...
	if (/<\/EntityDescriptor>/) {
		# re-export the old file
		while ($line = shift @lines) {
			print $line;
		}
		$ended = 1;
	}

}

# end
