#!/usr/bin/env perl -W

open(F, "id-to-name.txt") || die "could not open id-to-name map";
while (<F>) {
    my ($orgid, $name) = split /[\t\n]/;
    #print "name='$name' --> orgid='$orgid'\n";
    $name_to_orgid{$name} = $orgid;
}
close(F);

while (<>) {
    #     12  2      3   3 1        4      4  5  5
    if (/^((.*)<Grant(All)?)\s+to=\"([^\"]+)\"(.*)$/) {
        my $pre = $1;
        my $xmlName = $4;
        my $post = $5;
        my $name = $xmlName;
        $name =~ s/\&amp\;/\&/;
        #print "pre -$pre- xmlName -$xmlName- name -$name- post -$post-\n";
        my $orgID = $name_to_orgid{$name};
        if (!defined($orgID)) {
            die "no map for -$xmlName- -$name-\n";
        }
        print "$pre to=\"$xmlName\" orgID=\"$orgID\"$post\n";
        #print "$pre orgID=\"$orgID\" to=\"$xmlName\"$post\n";
    } elsif (/<Grant(All)?\s+/) {
        die "bad Grant $_";
    } else {
        print $_;
    }
}
close(F);
