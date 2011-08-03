#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIID3TCCA0agAwIBAgIQCnFfdSGulBNKkPb/stl3IDANBgkqhkiG9w0BAQUFADCB';

# This line indicates that the new certificate is present
$new_cert_line = 'MIIEiTCCA3GgAwIBAgIRAPzB04tYcniZc/0mSMRCfXgwDQYJKoZIhvcNAQEFBQAw';

# The new certificate data
$new_cert = <<EOF;
        <KeyDescriptor use="signing">
            <ds:KeyInfo>
                <ds:KeyName>gateway.athensams.net</ds:KeyName>
                <ds:X509Data>
                    <ds:X509Certificate>
                        MIIEiTCCA3GgAwIBAgIRAPzB04tYcniZc/0mSMRCfXgwDQYJKoZIhvcNAQEFBQAw
                        NjELMAkGA1UEBhMCTkwxDzANBgNVBAoTBlRFUkVOQTEWMBQGA1UEAxMNVEVSRU5B
                        IFNTTCBDQTAeFw0xMTA3MjgwMDAwMDBaFw0xMjA3MjcyMzU5NTlaMF4xCzAJBgNV
                        BAYTAkdCMQ4wDAYDVQQIEwVCQU5FUzENMAsGA1UEBxMEQmF0aDEQMA4GA1UEChMH
                        RWR1c2VydjEeMBwGA1UEAxMVZ2F0ZXdheS5hdGhlbnNhbXMubmV0MIIBIjANBgkq
                        hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoLbk2y/QGq7FEcReCQDcP0dDxk68Ufw0
                        QH5mh46CzkPuGtxB6Q96YTUc3lVw7h9K9YHNXvVB6MlMYN2oiMYQGWuyMqMxQCzZ
                        jmwjIRiphg3+sRV3XmIFyoJej+sWbrBKzcZUAPmxYqbR8xgoizoo+vVkicKJ9V3d
                        mhyrUhSXUhJv14zgruO6RCp2XFyVSH2uKprE3Fn4qRPI/kiYe7rtTlnsKdZk9cQE
                        z+8/70QKIWfpdJCJuJfb2uLoJ8oaY9AnwCvkjuSYS9xMhbsSQFiCUJK8T/jV1gGK
                        fc7BQ58WOODkCVXWFXkSsxOGvouQ8o0El/9Uq/2d3DIAGXeczlJRhQIDAQABo4IB
                        aDCCAWQwHwYDVR0jBBgwFoAUDL2TaAzz3qujSWsrN1dH6pDjue0wHQYDVR0OBBYE
                        FNdxQBp34i4gpWGofRhgPrkvWmW/MA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8E
                        AjAAMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAYBgNVHSAEETAPMA0G
                        CysGAQQBsjEBAgIdMDoGA1UdHwQzMDEwL6AtoCuGKWh0dHA6Ly9jcmwudGNzLnRl
                        cmVuYS5vcmcvVEVSRU5BU1NMQ0EuY3JsMG0GCCsGAQUFBwEBBGEwXzA1BggrBgEF
                        BQcwAoYpaHR0cDovL2NydC50Y3MudGVyZW5hLm9yZy9URVJFTkFTU0xDQS5jcnQw
                        JgYIKwYBBQUHMAGGGmh0dHA6Ly9vY3NwLnRjcy50ZXJlbmEub3JnMCAGA1UdEQQZ
                        MBeCFWdhdGV3YXkuYXRoZW5zYW1zLm5ldDANBgkqhkiG9w0BAQUFAAOCAQEAvC1+
                        GswAC8giviw+HoLadvdWBBKi4lTbj2IXLehAApg7Mci1jYZAQCvLjI7aqF7PkZ2l
                        2MqubMwsNQr1G6x4V4Yubvm++5d5CMjihuZWPoCuNRwhryzMilumHH0TiBifSKbe
                        VY0oAsCQJRTL6W3uMB5085iuRe1H+FlecvQivxoDLyk2CSK1AuTXXPUZ6ILtWWBW
                        ba9krg5Lhvv84W+3c3vOVcb4X3KV80QxtCd5UQ26ddCrM7kMLx5qKzvMX8UqoNld
                        hNdOuL+Kxy0FQroaPsECcaeliAXYukv2vvY1poWwczjyX7eTa/WqreCf9CgraUYE
                        H2/AKOc/SSnYXhcupg==
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
