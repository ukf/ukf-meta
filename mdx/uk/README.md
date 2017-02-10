# UK Federation Tooling

This directory contains the MDA configurations specific to the UK Federation. The main configuration here
is found in `generate.xml`, which generates a complete set of aggregate output files:

* `ukfederation-back-unsigned.xml`
* `ukfederation-cdsall-unsigned.xml`
* `ukfederation-export-preview-unsigned.xml`
* `ukfederation-export-unsigned.xml`
* `ukfederation-metadata-unsigned.xml`
* `ukfederation-stats.xml`
* `ukfederation-test-unsigned.xml`
* `ukfederation-wayf-unsigned.xml`

One reason for the large number of output files is to establish a pair of _maturity pipelines_ allowing
us to introduce new features, such as entity attributes or new types of metadata, to an initial limited
audience before making them available to the whole federation.

## Export Maturity Pipeline

The export maturity pipeline consists of:

* `ukfederation-export-preview-unsigned.xml`
* `ukfederation-export-unsigned.xml`

In this arrangement, features are first introduced to the `export-preview` variant of the aggregate for a period
before being included in the `export` version consumed by interfederation partners such as eduGAIN.

### Export Preview Aggregate vs. Export Aggregate

Status (2017-02-10):

* these aggregates are currently identical

## Production Maturity Pipeline

The production maturity pipeline consists of:

* `ukfederation-test-unsigned.xml`
* `ukfederation-metadata-unsigned.xml`
* `ukfederation-back-unsigned.xml`

In this arrangement, features are first introduced to the `test` variant of the aggregate for a period
before being included in the `metadata` variant consumed by federation members.

Once a feature has been "in production" (present in the `metadata` variant) for a period, normally one month but
subject to extension at Federation discretion, it will be introduced to the `back` variant. This provides a
temporary "fallback" mechanism for entity owners whose entities have difficulty with a newly introduced
feature in the production aggregate. Such entities are, however, expected to move back to the production
aggregate once they have resolved their issue so that the presence of the fallback aggregate once again
provides them with a fallback; not doing so would mean that they might only become aware of a new issue
when it appeared in the fallback aggregate, which would be too late to take corrective action.

### Test Aggregate vs. Production Aggregate

Status (2017-02-08):

* the test aggregate implements a _blacklisting_ approach to entity attributes imported from eduGAIN,
while the production aggregate implements the traditional entity attribute _whitelist_.
* the test aggregate no longer implements the "key use" fixup required for pre-1.3.1 Shibboleth SPs.
This adds the `use="signing"` XML attribute to `<KeyDescriptor>` elements present in IdP metadata
without a `use` attribute. It is not needed for later releases of the Shibboleth SP.
* The test aggregate normalises the `xenc` namespace to not use a prefix, as it is not very commonly used.

### Fallback Aggregate vs. Production Aggregate

Status (2017-02-08):

* The production aggregate defines the `saml` namespace prefix (used by entity attributes) on the document element
instead of in each SAML `<Attribute>`. (2017-02-08)
* The production aggregate defines the `mdattr` namespace prefix (used by entity attributes) on the document element
instead of in each `<EntityAttributes>` element. (2017-02-08)
