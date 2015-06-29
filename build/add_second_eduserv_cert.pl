#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#


# This line indicates that the old certificate is present
#
# Ensure that all Base64-encoded characters which affect perl pattern matching are escaped.
# For example, '+' in the variable indicates 'one or more of the preceding character', 
# whilst \+ indicates a literal + in the input string.
$old_cert_line = 'MIIEiDCCA3CgAwIBAgIQOBNA\+hb81eyfqXol6z3klDANBgkqhkiG9w0BAQUFADA2';

# This line indicates that the new certificate is present
$new_cert_line = 'MIIDvjCCAqagAwIBAgIEVOxCIjANBgkqhkiG9w0BAQsFADCBoDEoMCYGCSqGSIb3';

# The new certificate data
$new_cert = <<EOF;
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>
                        MIIDvjCCAqagAwIBAgIEVOxCIjANBgkqhkiG9w0BAQsFADCBoDEoMCYGCSqGSIb3
                        DQEJARYZYXRoZW5zaGVscEBlZHVzZXJ2Lm9yZy51azELMAkGA1UEBhMCR0IxETAP
                        BgNVBAgMCFNvbWVyc2V0MQ0wCwYDVQQHDARCYXRoMRAwDgYDVQQKDAdFZHVzZXJ2
                        MRMwEQYDVQQLDApPcGVuQXRoZW5zMR4wHAYDVQQDDBVnYXRld2F5LmF0aGVuc2Ft
                        cy5uZXQwHhcNMTUwMjI0MDkyMDA2WhcNMjUwMjI0MDkyMDA2WjCBoDEoMCYGCSqG
                        SIb3DQEJARYZYXRoZW5zaGVscEBlZHVzZXJ2Lm9yZy51azELMAkGA1UEBhMCR0Ix
                        ETAPBgNVBAgMCFNvbWVyc2V0MQ0wCwYDVQQHDARCYXRoMRAwDgYDVQQKDAdFZHVz
                        ZXJ2MRMwEQYDVQQLDApPcGVuQXRoZW5zMR4wHAYDVQQDDBVnYXRld2F5LmF0aGVu
                        c2Ftcy5uZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCandpa4o0N
                        jtw1DqbrrNTfOVe1PqyXIIVmDrJ6VUR/mokXXu+m5Gm+1f+3lyN5IA2YMn9Z8Yo3
                        7JQjIHs+xVS3q4nT1ewS7S3en1pdXKsH1WnUnVWUmpl9WJZrUwi5i8X80LNyr7Pm
                        udhuKNEATGUXkA/xWCkk2d8jf91hy7Qu+HA8LOKtdbbNigErh2IY/YuNWUVUqgGb
                        MH5BGr7ZEhPrz+Vwcf9lhPW+tKpKpZEzJfQiq8EoPaeMXEpKWBEErm67gkWFCA5V
                        hfcJLqFjQEC3pWOxt5rZVS8gl/Z33VSJZVzY5jWcQzmGaLXPHXyiKPmixl6+DjGl
                        UM0ylNF7GvtDAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAFhmhujLZueiJ6F7mQCp
                        fB0Hj4Y8FyFUUc8NMAt5Set7H4DKSSl4shcqisZBa5yTdyenYwkmBszvCWs6Yeep
                        +zJmCR62cb/f1M32oMzLm02OlznWMkE8/IajGmdxTnB6Z/XcdMMIiCeok4kqe5KM
                        d5oRAyNskHYZ+8kzhs2zTveR+rqCtYxa/AYpwf7n0VQR9clBSNCIT4BCRi10aPE5
                        31VIxl4ljY3CwNoZ4lQTU/0aj8O4j68V2neiQb8lewAii0b2xoyOGYP4okd7T2tl
                        4gl2noVbCvYNjd6GYze/w4lgwiemkby7wu5sN1lEudgKDV+H54wU29ZIyDEFM6DD
                        NE4=
                    </ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>
        <KeyDescriptor use="signing">
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
			if ($have_old_cert && !$have_new_cert && $line =~ /<KeyDescriptor/) {
				print $new_cert;
			}
		}
		$ended = 1;
	}

}

# end
