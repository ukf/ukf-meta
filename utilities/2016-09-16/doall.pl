#!/usr/bin/env perl

use warnings;

open(F, "id-to-name.txt") || die "could not open id-to-name map";
while (<F>) {
    my ($orgid, $name) = split /[\t\n]/;
    # print "name='$name' --> orgid='$orgid'\n";
    $name_to_orgid{$name} = $orgid;
}
close(F);

open(F, "ukid-to-name.txt") || die "could not open ukid-to-name map";
while (<F>) {
    my ($ukid, $name) = split /[\t\n]/;
    # print "ukid='$ukid' --> name='$name'\n";
    if (defined $name_to_orgid{$name}) {
        # print "   --> orgid='$name_to_orgid{$name}'\n"
        my $orgid = $name_to_orgid{$name};
        $command = "perl -i patch.pl $orgid entities/$ukid.xml";
        print "$ukid --> $orgid   $command\n";
        system($command);
    } else {
        die "'$name' unmapped";
        # print "   --> undefined\n";
    }
}
close(F);
