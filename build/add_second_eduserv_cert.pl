#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIIEiTCCA3GgAwIBAgIRAPzB04tYcniZc/0mSMRCfXgwDQYJKoZIhvcNAQEFBQAw';

# This line indicates that the new certificate is present
$new_cert_line = 'MIIEiDCCA3CgAwIBAgIQOBNA+hb81eyfqXol6z3klDANBgkqhkiG9w0BAQUFADA2';

# The new certificate data
$new_cert = <<EOF;
        <KeyDescriptor use="signing">
            <ds:KeyInfo>
                <ds:KeyName>gateway.athensams.net</ds:KeyName>
                <ds:X509Data>
                    <ds:X509Certificate>
                        MIIEiDCCA3CgAwIBAgIQOBNA+hb81eyfqXol6z3klDANBgkqhkiG9w0BAQUFADA2
                        MQswCQYDVQQGEwJOTDEPMA0GA1UEChMGVEVSRU5BMRYwFAYDVQQDEw1URVJFTkEg
                        U1NMIENBMB4XDTEyMDcwNjAwMDAwMFoXDTE1MDcwNjIzNTk1OVowXjELMAkGA1UE
                        BhMCR0IxDjAMBgNVBAgTBUJBTkVTMQ0wCwYDVQQHEwRCYXRoMRAwDgYDVQQKEwdF
                        ZHVzZXJ2MR4wHAYDVQQDExVnYXRld2F5LmF0aGVuc2Ftcy5uZXQwggEiMA0GCSqG
                        SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDbB17KWAYcAxwqBJLKiCNrX18NQpeYoJBv
                        6/ilSgtEYJxmcvS+dDFWoFoLCKJt+nfuoegPOZHTeNxyxmg4fMXw0PulVWgQxW0s
                        0zggonUc7VQ98Ny4rkBY0IpOcMzJv1leKk7w0mXfCGZwMacZ9uy5BpM84raTyOTz
                        P0MI28PjWTVAohhVK34CeUm0vUwVzemN0INctgyIdzEHlb6nteKCYKCnjsi2KTO8
                        spumdA3rcU/u+0rUR5auJ0ZsDtUMg7BQw0W6MAkcXEHuC5uGJuLSyhO3h1G1D5L4
                        5Xq5rKvV5FqyRP++hrEoiA2z3lMXtjxEaT4CELiiHbxdukaqw2aZAgMBAAGjggFo
                        MIIBZDAfBgNVHSMEGDAWgBQMvZNoDPPeq6NJays3V0fqkOO57TAdBgNVHQ4EFgQU
                        f4VPXF2nfnxOVFGmLcxxPaq5y+wwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQC
                        MAAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMBgGA1UdIAQRMA8wDQYL
                        KwYBBAGyMQECAh0wOgYDVR0fBDMwMTAvoC2gK4YpaHR0cDovL2NybC50Y3MudGVy
                        ZW5hLm9yZy9URVJFTkFTU0xDQS5jcmwwbQYIKwYBBQUHAQEEYTBfMDUGCCsGAQUF
                        BzAChilodHRwOi8vY3J0LnRjcy50ZXJlbmEub3JnL1RFUkVOQVNTTENBLmNydDAm
                        BggrBgEFBQcwAYYaaHR0cDovL29jc3AudGNzLnRlcmVuYS5vcmcwIAYDVR0RBBkw
                        F4IVZ2F0ZXdheS5hdGhlbnNhbXMubmV0MA0GCSqGSIb3DQEBBQUAA4IBAQBDDpET
                        eseuUBypZlPJMfm2eg3jFIgJOTdxvMNU88EuLXTiSSgRWQAjy7QPHprkFiXUyOu5
                        EdBbXhuTcecRESOqM5pHxZulnWtrggXc9IGy7TzjxsrxFXb881qiVwGu7kiYPv1F
                        IwK6IQfbdbUXiTLNxrLogMYI4T7YwYkkKdA4nCy3aUuucz5uuIovLvLVrtZ9YN66
                        XWcW/d0prifYI70Cwo4ydOJgm0WbqllJRVnP5jI9+pDa1cX6tku8raFkDUZxJfU9
                        IlvryvkiiZTpoo7QOu6aJVAwU33BXcTQyEeCyp5PAvaeNJWCFpQ85gNSxJdVPIqm
                        6pd2Nd0SphPSYavr
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
