#!/usr/bin/perl -w

#
# The input file is a fragment file that may or may not need to have
# the new Eduserv gateway certificate added to it.  Add the certificate if
# required, or just re-export the file unchanged.
#

# This line indicates that the old certificate is present
$old_cert_line = 'MIIDaTCCAtKgAwIBAgIQLqPCly3VfA8B2xVsTv59ajANBgkqhkiG9w0BAQUFADCB';

# This line indicates that the new certificate is present
$new_cert_line = 'MIID7jCCA1egAwIBAgIQHJ62fRr9Z6oWeYtsoVKvgzANBgkqhkiG9w0BAQUFADCB';

# The new certificate data
$new_cert = <<EOF;
        <KeyDescriptor use="signing">
            <ds:KeyInfo>
                <ds:KeyName>gateway.athensams.net</ds:KeyName>
                <ds:X509Data>
                    <ds:X509Certificate>
					    MIID7jCCA1egAwIBAgIQHJ62fRr9Z6oWeYtsoVKvgzANBgkqhkiG9w0BAQUFADCB
					    zjELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJ
					    Q2FwZSBUb3duMR0wGwYDVQQKExRUaGF3dGUgQ29uc3VsdGluZyBjYzEoMCYGA1UE
					    CxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEhMB8GA1UEAxMYVGhh
					    d3RlIFByZW1pdW0gU2VydmVyIENBMSgwJgYJKoZIhvcNAQkBFhlwcmVtaXVtLXNl
					    cnZlckB0aGF3dGUuY29tMB4XDTA4MDcyNDE0NDk1N1oXDTEwMDcyNDE0NDk1N1ow
					    bzELMAkGA1UEBhMCR0IxDjAMBgNVBAgTBUJBTkVTMQ0wCwYDVQQHEwRCYXRoMRAw
					    DgYDVQQKEwdFZHVzZXJ2MQ8wDQYDVQQLEwZBdGhlbnMxHjAcBgNVBAMTFWdhdGV3
					    YXkuYXRoZW5zYW1zLm5ldDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
					    AMYbGyRBXva/AGkSzCfmuv6+oKZbaqZvos0tVJFmcip94EtOP3VaVeW7e/ThDpuG
					    MPygrubWBFkjz3UnGIojg2+fz3MvDhAEyf6447SPEzSyve0nlSfxx+m7SOM9R491
					    b33OZ4iJF2Hj6fP9wLcr+UiMXZTfZoICThC9l5HkauhtrEHV2+9r9nc9Pq9GYzBK
					    8SKgEmsxVG9yeu36M7Rdlzuij/R83C48woH29q1GlP6ywsS1/vqNlu2I3iodCWKP
					    K0+77jCSNgQ0uM1c9Ibcsnj5zzA5km02kb4el6DhKiIWg/VnkQ6iNidAmWfbiwwz
					    nTqrmNnu+TJMZipcOQD5bM0CAwEAAaOBpjCBozAdBgNVHSUEFjAUBggrBgEFBQcD
					    AQYIKwYBBQUHAwIwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL2NybC50aGF3dGUu
					    Y29tL1RoYXd0ZVByZW1pdW1TZXJ2ZXJDQS5jcmwwMgYIKwYBBQUHAQEEJjAkMCIG
					    CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMAwGA1UdEwEB/wQCMAAw
					    DQYJKoZIhvcNAQEFBQADgYEACpy+S/rZE7rM9CBbGZX0IDHFs1i9P6yQhzxNrJ5o
					    fT31WPQwPfoncZMoJt0C8wkDDcDntODdFD7rLh3PMWyjkYfjVrpb25T3NxDLwru6
					    65NWPQOvHJSMIXS8C7HxQEIYmvAFD2KbFmiYLlHz7gyIka56E5tqdD+mbPN6Fyb2
					    se8=
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
