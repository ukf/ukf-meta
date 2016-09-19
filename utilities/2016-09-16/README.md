# `utilities/2016-09-16`

These transforms and scripts were used to add an `orgID` attribute to the
`UKFederationMember` elements on all currently registered entities.

## Step 1

Generate `id-to-name.txt` as follows:

    xsltproc --output=id-to-name.txt gen-id-to-name.xsl members/members.xml

This file contains a mapping between organization IDs and canonical
organization names, like this:

ukforg4590	Ian A. Young

The first field is separated from the second by a single tab character.

## Step 2

Generate `ukid-to-name.txt` as follows:

    xsltproc gen-ukid-to-name.xsl entities/uk*.xml >ukid-to-name.txt

This file contains a mapping between entity `ID` attributes and canonical
organization names, like this:

    uk000006	Ian A. Young

Again, the separator between the first and second fields is a single tab character.

## Step 3

Combining the results of steps 1 and 2, we can generate a list of all entity
files (named after entity `ID` values as in `ukid-to-name.txt`), via
the canonical organization name, to the organization ID values found in
`members.xml`.

This is then applied to all entity fragment files by executing `./doall.pl`.

`doall` reads both data files, then iterates across all fragment files calling
`patch.pl` to inject the appropriate `orgID` value.
