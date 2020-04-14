# Tests for UK-specific check for R and S

If the entity asserts R&S, it must have a RegistrationPolicy

Other checks ensure that the RegistrationPolicy is valid

Run tests like this:

`for i in *.xml; do echo "Test: $i ==="; xsltproc ../../../mdx/uk/check_uk_rands.xsl $i; done`
