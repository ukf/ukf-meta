# `mdx/int_edugain`

Resources associated with the eduGAIN interfederation.

Certificates:

* `mds-v1.cer` is the certificate to be used for signing the eduGAIN metadata
  aggregate at `https://mds.edugain.org/edugain-v1.xml` from early 2019.

* `mds-2014.cer` is the certificate used for signing eduGAIN metadata at
  `https://mds.edugain.org` and `https://mds.edugain.org/feed-256.xml` until
  mid-2019, at which point those locations switch to the `mds-v1.cer`
  certificate for compatibility.

Note that these two certificates wrap the same 2048-bit public key.

See the [eduGAIN certificate change
roadmap](https://technical.edugain.org/certificate_change) for further details.
