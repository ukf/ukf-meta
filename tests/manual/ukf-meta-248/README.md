# Tests for duplicate xml:lang

Ensuring well-formed:
```
for i in *xml; do xmllint --noout $i; done
```

Tests for existing checks:
```
xsltproc ../../../mdx/_rules/check_mdui.xsl test.xml 
[ERROR] non-unique lang values on mdui:DisplayName elements
[ERROR] non-unique lang values on mdui:Description elements
[ERROR] non-unique lang values on mdui:Keywords elements
$ xsltproc ../../../mdx/_rules/check_mdrpi.xsl test.xml 
[ERROR] non-unique lang values on mdrpi:RegistrationPolicy elements
```

New test should fail on md:ServiceName and md:ServiceDescription:
```
xsltproc ../../../mdx/_rules/check_saml2_lang.xsl AttributeConsumingService-fail.xml
[ERROR] non-unique lang values on ServiceName elements
[ERROR] non-unique lang values on ServiceDescription elements
```

New test should fail on md:Organization and md:OrganizationDisplayName
```
xsltproc ../../../mdx/_rules/check_saml2_lang.xsl Organization-fail.xml
[ERROR] non-unique lang values on OrganizationName elements
[ERROR] non-unique lang values on OrganizationDisplayName elements
```

Should pass on new tests:
```
xsltproc ../../../mdx/_rules/check_saml2_lang.xsl AttributeConsumingService-pass.xml
xsltproc ../../../mdx/_rules/check_saml2_lang.xsl Organization-pass.xml
```

`test-sp.xml` is a fragment file that is intended to fail on import
