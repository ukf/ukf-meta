
Manual tests for checking Sirtfi version 2 conformance

Run the following bash command in this directory to see the thrown errors

```bash
for i in *.xml; do echo $i; xsltproc ../../../mdx/_rules/check_sirtfi2.xsl $i; done
```
