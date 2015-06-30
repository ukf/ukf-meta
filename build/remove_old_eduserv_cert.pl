#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the old Eduserv gateway certificate removed from it.  Remove the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
#
# Ensure that all Base64-encoded characters which affect perl pattern matching are escaped.
# For example, '+' in the variable indicates 'one or more of the preceding character', 
# whilst \+ indicates a literal + in the input string.
$old_cert_line = 'MIIEiDCCA3CgAwIBAgIQOBNA\+hb81eyfqXol6z3klDANBgkqhkiG9w0BAQUFADA2';

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
