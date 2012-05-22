#!/usr/bin/perl

$seen = 0;

while (<>) {
	if (/^\s+http:\/\/ukfederation.org.uk\/2006\/11\/label/) {
		$seen = 1; # don't apply the change twice to the same file
	}
	if (!$seen && /^(\s+)http:\/\/www.w3.org\/2001\/04\/xmlenc/) {
		print "$1http://ukfederation.org.uk/2006/11/label uk-fed-label.xsd\n";
	}
	print $_;
}