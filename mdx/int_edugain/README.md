# `mdx/int_edugain`

Resources associated with the eduGAIN interfederation.

Certificates:

* `mds-v1-1.cer` is the certificate used for signing the eduGAIN
  metadata aggregate from early 2021 and intended to be used until the
  end of 2022.

* `mds-v1.cer` is the certificate used for signing the eduGAIN metadata
  aggregate at `https://mds.edugain.org/edugain-v1.xml` from early 2019 to
  early 2021.

* `mds-2014.cer` is the certificate used for signing eduGAIN metadata at
  `https://mds.edugain.org` and `https://mds.edugain.org/feed-256.xml` until
  mid-2019, at which point those locations switched to the `mds-v1.cer`
  certificate for compatibility.

  See the [eduGAIN certificate change
  roadmap](https://technical.edugain.org/certificate_change) for further details.

Note that all three certificates wrap the same 2048-bit public key.
