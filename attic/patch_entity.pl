#!/usr/bin/perl

while (<>) {
	if (/AthensPUIDAuthority/) {
		next;
	}
	print $_;
}
