#!/usr/bin/env perl -W

my $orgID = shift @ARGV;

while (<>) {
    if (/UKFederationMember/ && !/orgID/) {
        s/UKFederationMember/UKFederationMember orgID="$orgID"/;
    }
    print $_;
}
