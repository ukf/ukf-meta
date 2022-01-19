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

Status:

* These aggregates are currently identical.

## Production Maturity Pipeline

The production maturity pipeline consists of:

* `ukfederation-test-unsigned.xml`
* `ukfederation-metadata-unsigned.xml`
* `ukfederation-back-unsigned.xml`

In this arrangement, features are first introduced to the `test` variant of the aggregate for a period
before being included in the `metadata` variant consumed by federation members.

The following additional aggregates are normally kept in sync (where appropriate) with the production `metadata`
aggregate:

* `ukfederation-cdsall-unsigned.xml`
* `ukfederation-wayf-unsigned.xml`

Once a feature has been "in production" (present in the `metadata` variant) for a period, normally one month but
subject to extension at Federation discretion, it will be introduced to the `back` variant. This provides a
temporary "fallback" mechanism for entity owners whose entities have difficulty with a newly introduced
feature in the production aggregate. Such entities are, however, expected to move back to the production
aggregate once they have resolved their issue so that the presence of the fallback aggregate once again
provides them with a fallback; not doing so would mean that they might only become aware of a new issue
when it appeared in the fallback aggregate, which would be too late to take corrective action.

### Test Aggregate vs. Production Aggregate

Status:

* These aggregates are identical

### `cds-all` Aggregate vs. Production Aggregate

Status:

* The `cdsall` aggregate omits many elements not necessary for the generation of a discovery feed.

* Otherwise, these aggregates are currently identical.

### Fallback Aggregate vs. Production Aggregate

Status:

* The `production` aggregate does not include the `<UKFederationMember>` label (`ukf-meta#34`).

* The `production` aggregate adds `<EncryptionMethod>` elements with AES128-CBC
  to SPs that have no block encryption methods listed
