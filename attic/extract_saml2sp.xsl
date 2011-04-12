<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_saml2sp.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata aggregate and extracts
	SAML 2.0 support information for each SP entity.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="md ds">

	<!-- Output is plain text -->
	<xsl:output method="text"/>
	
	<xsl:template match="//md:EntityDescriptor[md:SPSSODescriptor]">
		<xsl:value-of select="@ID"/>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="contains(md:SPSSODescriptor/@protocolSupportEnumeration,
				'urn:oasis:names:tc:SAML:2.0:protocol')">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
	
</xsl:stylesheet>
