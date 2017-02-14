#!/usr/bin/env perl

use warnings;

my $orgID = shift @ARGV;

while (<>) {
    if (/UKFederationMember/ && !/orgID/) {
        s/UKFederationMember/UKFederationMember orgID="$orgID"/;
    }
    print $_;
}
