# README

Some test files:
- sp.xml looks like a Shibboleth SP's automatically-generated metadata
- idp.xml looks like a Shibboleth IdP's metadata

How to test
- copy the test file to `${UKF-DATA}/entities/import.xml`
- run `import.metadata` ant target

The comments should not be copied into `imported.xml`

I have not included examples of the output
because that would break when we update the
content of `import.xsl`
