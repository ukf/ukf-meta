#!/usr/bin/perl -w

use ExtractCert;

$known_bad{'census.data-archive.ac.uk:8080'} = 1; # it is really http, not https

print "Loading endpoint locations...\n";
open(XML, "xsltproc extract_nocert_locs.xsl ../xml/ukfederation-metadata.xml|") || die "could not open input file";
while (<XML>) {
	chop;
	if (/^http:/) {
		print "skipping http location: $_\n";
	} elsif (/^https:\/\/([^\/:]+(:\d+)?)(\/|$)/) {
		my $location = $1;
		$location .= ":443" unless defined $2;
		if ($known_bad{$location}) {
			print "skipping known bad location: $_\n";
		} else {
			$locations{$location} = 1;
		}
	} else {
		print "bad location: $_\n";
	}
}
close XML;

$count = scalar keys %locations;
print "Unique SSL non-certificate locations: $count\n";

#
# Temporary output file for certificate extraction tool.
#
$temp_der = '/tmp/probe_nocerts.der';

#
# Extract the certificate from each location.
#
foreach $loc (sort keys %locations) {
	print "$count: probing: $loc\n";
	$count--;

	#
	# Remove any old copy of the DER file.
	#
	unlink $temp_der;

	#
	# Separate location into host and port.
	#
	my ($host, $port) = split(/:/, $loc);
	#print "host: $host, port: $port\n";
	my $hostPort = "$host:$port";

	#
	# Take a peek at the Server header to see if it says anything about old
	# versions of OpenSSL.
	#
	$cmd = "curl --silent --connect-timeout 5 --head https://$hostPort |";
	open(CURL, $cmd) || die "could not open curl subcommand";
	undef $server;
	undef $openssl;
	while (<CURL>) {
		if (/^Server:(.*)$/) {
			$server = $1;
		}
	}
	close CURL;
	if (defined $server) {
		# print "   server: $server\n";
		if ($server =~ /OpenSSL\/([0-9a-z\.]+)/) {
			$openssl = $1;
		}
	}
	if (defined $openssl) {
		print "   openssl: $openssl\n";
		$openssl_used{$hostPort} = $openssl;
	}
}
print "\n\n";

print "OpenSSL versions detected:\n";
foreach $hostPort (sort keys %openssl_used) {
	my $version = $openssl_used{$hostPort};
	print "   $version used at $hostPort\n";
}
print "\n";

#
# Clean up
#
unlink $temp_der;
