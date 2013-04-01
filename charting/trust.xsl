<?xml version="1.0" encoding="UTF-8"?>
<!--
	
	trust.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	statistics about the different trust models used within the
	included entities.
	
	Author: Ian A. Young <ian@iay.org.uk>
	
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="md">
	
	<!-- Output is plain text -->
	<xsl:output method="text"/>
	
	<xsl:template match="md:EntitiesDescriptor">
		<xsl:variable name="entities" select="//md:EntityDescriptor"/>
		<xsl:value-of select="count($entities)"/>
		<xsl:text> </xsl:text>
		<xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
		<xsl:value-of select="count($idps)"/>
		<xsl:text> </xsl:text>
		<xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
		<xsl:value-of select="count($sps)"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($entities[descendant::ds:X509Data])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($idps[descendant::ds:X509Data])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($sps[descendant::ds:X509Data])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($entities[descendant::ds:KeyName])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($idps[descendant::ds:KeyName])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($sps[descendant::ds:KeyName])"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="count($entities[not(descendant::ds:X509Data)])"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
