<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_authorities.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	the certificate authorities in the form of a series of
	PEM certificate blocks.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"

    xmlns:mdxTextUtils="xalan://uk.ac.sdss.xalan.md.TextUtils"
	extension-element-prefixes="mdxTextUtils"

	exclude-result-prefixes="shibmd md ds wayf">

	<!-- Output is plain text -->
	<xsl:output method="text"/>

	<xsl:template match="//md:EntitiesDescriptor/md:Extensions/shibmd:KeyAuthority//ds:X509Certificate">
		<xsl:text>-----BEGIN CERTIFICATE-----&#x0a;</xsl:text>
		<xsl:value-of select="mdxTextUtils:wrapBase64(.)"/>
		<xsl:text>&#x0a;-----END CERTIFICATE-----&#x0a;</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
