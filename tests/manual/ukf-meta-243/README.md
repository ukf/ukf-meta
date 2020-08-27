# Add CBC algorithm if no block encryption algorithms

The tests directory has a series of tests (the `.xml` files). Each of these
has a corresponding `.xml.out` which is what we expect is the transform.

This command will run the tests:

`for i in *xml; do echo "=== Test: $i ==="; xsltproc ../../../mdx/uk/add_cbc_encryption.xsl $i | diff ${i}.out -; done`

The expected output is a series of headers.

Any errors will show up as a diff from the expected output 
