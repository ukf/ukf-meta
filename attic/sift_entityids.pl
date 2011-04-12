#!/usr/bin/perl

@registries = (
	# gTLDs
	'.com',
	'.edu',
	'.net',
	'.org',
	'.info',
	
	# ccTLDs which allow top-level registration
	'.es',
	'.eu',
	'.nl',
	'.tv',
	
	# ccTLD: cn
	'.edu.cn',
	
	# ccTLD: jp
	'.ac.jp',
	
	# ccTLD: my
	'.edu.my',
	
	# CC TLD: uk
	'.ac.uk',
	'.bl.uk',
	'.co.uk',
	'.gov.uk',
	'.org.uk',
	'.parliament.uk',
);

LINE: while (<>) {
	chop;

	#
	# Extract a domain from the entityID
	#
	if (/^https?:\/\/([^\:\/]+)/) {
		$domain = $1;
	} elsif (/^urn:mace:ac.uk:sdss.ac.uk:provider:(service|identity):([^:]+)/) {
		$domain = $2;
	} elsif (/^urn:mace:eduserv.org.uk:athens:federation:(uk|beta)$/) {
		$domain = 'eduserv.org.uk';
	} elsif (/^urn:mace:eduserv.org.uk:athens:provider:(.*)/) {
		$domain = $1;
	} else {
		print "*** can't extract domain from $_\n";
		next;
	}
	
	#
	# Now figure out the registrar involved with this domain.
	#
	foreach $registry (@registries) {
		if (substr($domain, -length($registry)) eq $registry) {
			# print "$domain matched $registry\n";
			next LINE;
		}
	}
	print "*** no registry match for $domain\n";
}
