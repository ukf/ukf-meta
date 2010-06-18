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
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:str="http://exslt.org/strings"
	exclude-result-prefixes="md ds wayf str">

	<!-- Output is plain text -->
	<xsl:output method="text"/>

	<xsl:template match="//md:EntityDescriptor//md:KeyDescriptor[.//ds:X509Certificate]">
		<xsl:variable name="keydesc" select="."/>
		<xsl:variable name="entity" select="ancestor::md:EntityDescriptor"/>
		<xsl:for-each select="$keydesc//ds:X509Certificate">
			<xsl:text>Entity: </xsl:text>
			<xsl:if test="$entity/@ID">
				<xsl:text>[</xsl:text>
				<xsl:value-of select='$entity/@ID'/>
				<xsl:text>]</xsl:text>
			</xsl:if>
			<xsl:value-of select="$entity/@entityID"/>
			<xsl:text> KeyName: </xsl:text>
			<xsl:choose>
				<xsl:when test="$keydesc//ds:KeyName">
					<xsl:value-of select="$keydesc//ds:KeyName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(none)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&#x0a;</xsl:text>
			<xsl:text>-----BEGIN CERTIFICATE-----&#x0a;</xsl:text>
			<xsl:apply-templates select="str:tokenize(.)"/>
			<xsl:text>-----END CERTIFICATE-----&#x0a;</xsl:text>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="token">
		<xsl:value-of select="."/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>

	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
