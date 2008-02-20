<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_embedded.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	all embedded certificates on entities in the form of a series of
	PEM certificate blocks.
	
	A descriptive comment is added to indicate the entity in question and
	the KeyName used (if any) so that later processing can distinguish.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:shibmeta="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:str="http://exslt.org/strings"
	exclude-result-prefixes="shibmeta md ds wayf str">

	<!-- Output is plain text -->
	<xsl:output method="text"/>

	<xsl:template match="//md:EntityDescriptor//md:KeyDescriptor[.//ds:X509Certificate]">
		<xsl:text>Entity: </xsl:text>
		<xsl:value-of select="ancestor::md:EntityDescriptor/@entityID"/>
		<xsl:text> KeyName: </xsl:text>
		<xsl:choose>
			<xsl:when test=".//ds:KeyName">
				<xsl:value-of select=".//ds:KeyName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>(none)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>-----BEGIN CERTIFICATE-----&#x0a;</xsl:text>
		<xsl:apply-templates select="str:tokenize(.//ds:X509Certificate)"/>
		<xsl:text>-----END CERTIFICATE-----&#x0a;</xsl:text>
	</xsl:template>
	
	<xsl:template match="token">
		<xsl:value-of select="."/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>

	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
