# `utilities/2017-02-27`

Scripts to replace the HideFromWAYF element in entity fragment files
with the REFEDS Hide from Discovery Entity Category.

## 1. Check that no hidden IdPs have Entity Attributes already

Since there can only be a single Entity Attribute element in an entity fragment file,
we first check that there are no hidden IdPs that already have an Entity Attributes
element. If there are (and there are not too many) we edit these files manually.

Run the script on the entity fragment files: `xsltproc listHideFromWAYFandEA.xsl uk*.xml`

## 2. Replace HideFromWAYF element with hide-from-disco Entity Category

This command replaces the HideFromWAYF element with an Entity Attributes element
containing the REFEDS hide-from-disco entity category:

`replaceHideFromWAYF.pl uk*.xml`

It presumes that the `saml` and `mdattr` namespace prefixes are already defined in the
entity fragment files.

The perl regex matches the string HideFromWAYF rather than an XML element, so check
that transform has only modified the HideFromWAYF element by generating unsigned
aggregates before and after the transform and and looking at the differences.
The only changes should be the timestamp and quantities derived from the timestamp.
There is a small possibility that the generate target imports different entities from
eduGAIN -- these differences can be ignored.

```
ant samlmd.aggregates.generate
cp ukfederation-metadata.xml /tmp/
replaceHideFromWAYF.pl uk*.xml
ant samlmd.aggregates.generate
diff ukfederation-metadata.xml /tmp/
```

