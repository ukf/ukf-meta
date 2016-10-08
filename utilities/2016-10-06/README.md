# `utilities/2016-10-06`

These transforms and scripts were used to add an `orgID` attribute to the
`Grant` and `GrantAll` elements on all participants in the `members.xml` file.

## Step 1

Generate `id-to-name.txt` as follows:

    xsltproc --output id-to-name.txt gen-id-to-name.xsl members/members.xml

This file contains a mapping between organization IDs and canonical
organization names, like this:

ukforg4590	Ian A. Young

The first field is separated from the second by a single tab character.

## Step 2

Apply the `patch.pl` script to generate a new version of `members.xml`.

    ./patch.pl members/members.xml >members/members-new.xml

Compare the two versions of the file before replacing the old one.
