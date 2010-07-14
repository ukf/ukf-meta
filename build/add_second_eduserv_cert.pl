#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIID7jCCA1egAwIBAgIQHJ62fRr9Z6oWeYtsoVKvgzANBgkqhkiG9w0BAQUFADCB';

# This line indicates that the new certificate is present
$new_cert_line = 'MIID3TCCA0agAwIBAgIQCnFfdSGulBNKkPb/stl3IDANBgkqhkiG9w0BAQUFADCB';

# The new certificate data
$new_cert = <<EOF;
        <KeyDescriptor use="signing">
            <ds:KeyInfo>
                <ds:KeyName>gateway.athensams.net</ds:KeyName>
                <ds:X509Data>
                    <ds:X509Certificate>
                        MIID3TCCA0agAwIBAgIQCnFfdSGulBNKkPb/stl3IDANBgkqhkiG9w0BAQUFADCB
                        zjELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJ
                        Q2FwZSBUb3duMR0wGwYDVQQKExRUaGF3dGUgQ29uc3VsdGluZyBjYzEoMCYGA1UE
                        CxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEhMB8GA1UEAxMYVGhh
                        d3RlIFByZW1pdW0gU2VydmVyIENBMSgwJgYJKoZIhvcNAQkBFhlwcmVtaXVtLXNl
                        cnZlckB0aGF3dGUuY29tMB4XDTEwMDYxNjAwMDAwMFoXDTExMDgxNTIzNTk1OVow
                        XjELMAkGA1UEBhMCR0IxDjAMBgNVBAgTBUJBTkVTMQ0wCwYDVQQHFARCYXRoMRAw
                        DgYDVQQKFAdFZHVzZXJ2MR4wHAYDVQQDFBVnYXRld2F5LmF0aGVuc2Ftcy5uZXQw
                        ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBjvSyxeNiVQBJuXquzjcw
                        4VXHsTNgexaiJIrIgEpdoUUkDV0ElNQonMeZsR3jQZsaUQBHBkkSe7OCo3dbp9z+
                        1dPTbE99+vn0rIIQUWE57IiQxVDkmAZLNh5tufcLaYgIhIbHevyN4HrqBWdiYM5R
                        NHiwDLDFVnjVHmoml2+E+Ld76RcfBZzsyDGTGyRk+1RU9GIUX654v1E2L8h+7DFu
                        0s/gIyV1GHgwPo4cQCBTgz9WCe8ka4WC2ruURJDAtnenJ1G+fVwV8+8sckDTJ31k
                        YIsc9VsdPhy0iUX1NUisJ8ioiiv5BRYRpN7mS9XQo7wrtvTsab8ebmxqTYvCns+9
                        AgMBAAGjgaYwgaMwDAYDVR0TAQH/BAIwADBABgNVHR8EOTA3MDWgM6Axhi9odHRw
                        Oi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlU2VydmVyUHJlbWl1bUNBLmNybDAdBgNV
                        HSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwMgYIKwYBBQUHAQEEJjAkMCIGCCsG
                        AQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMA0GCSqGSIb3DQEBBQUAA4GB
                        AJEUjauWEO0PxgTpQOHt1MhWTNjZ1xYDU5LgbV+5Dgk4SaRE8MiFe+TvKayDtjOE
                        U82y/51lIeA73wB30urypdrXZ/DcexJSzl5uLeaDdh+aTc9CUcLxGvWxE+Zwry9P
                        2hzpuFAg/YwBMQWK2k6bYcNtSwViWkn9iizXMJ232qZN
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
