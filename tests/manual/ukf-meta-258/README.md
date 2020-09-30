# Generate HTML pages from XML products 

## Tests

xsltproc ../../../utilities/orgnamescope.xsl input.xml  | diff - scopes.out 
xsltproc ../../../utilities/ua-idp.xsl input.xml | diff - uai.out
xsltproc ../../../utilities/ua-idp.xsl accented.xml | diff - accented.out


