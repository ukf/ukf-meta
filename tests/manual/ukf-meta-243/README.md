# Add CBC algorithm if no block encryption algorithms

## Unit tests

The tests directory has a series of tests (the `.xml` files). Each of these
has a corresponding `.xml.out` which is what we expect is the transform.

This command will run the tests:

`for i in *xml; do echo "=== Test: $i ==="; xsltproc ../../../mdx/uk/add_cbc_encryption.xsl $i | diff ${i}.out -; done`

The expected output is a series of headers.

Any errors will show up as a diff from the expected output 

## Deployment test

`xsltproc listSPsnoAES128-CBC.xsl <aggregate>` will list the entityIDs of SPs which do not
explicitly list the AES128-CBC algorithm. We expect only SPs that already list algorithms
which aren't AES128-CBC will show up here.
