#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIIDaTCCAtKgAwIBAgIQLqPCly3VfA8B2xVsTv59ajANBgkqhkiG9w0BAQUFADCB';

# This line indicates that the new certificate is present
$new_cert_line = 'new certificate value goes here';

# The new certificate data
$new_cert = <<EOF;
        <KeyDescriptor use="signing">
            <ds:KeyInfo>
                <ds:KeyName>gateway.athensams.net</ds:KeyName>
                <ds:X509Data>
                    <ds:X509Certificate>
                        new certificate value goes here
                    </ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>
EOF

while (<>) {
	if (/$old_cert_line/) {
		$have_old_cert = 1;
	} elsif (/$new_cert_line/) {
		$have_new_cert = 1;
	}
	
	if ($ended) {
		print $_;
	} else {
		push @lines, $_;
	}
	
	# at the end...
	if (/<\/EntityDescriptor>/) {
		# re-export the old file, adding the new certificate
		while ($line = shift @lines) {
			print $line;
			if ($have_old_cert && !$have_new_cert && $line =~ /<\/KeyDescriptor>/) {
				print $new_cert;
			}
		}
		$ended = 1;
	}

}

# end
