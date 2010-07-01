<?xml version="1.0" encoding="UTF-8"?>
<!--

	scopes.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	a list of scopes used.  Regular expression scopes are ignored.
	Duplicates are not removed, and the result is unsorted.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<!-- Output is plain text -->
	<xsl:output method="text"/>

	<xsl:template match="//shibmd:Scope[@regex = 'true']">
		<!-- do nothing -->
	</xsl:template>
	
	<xsl:template match="//shibmd:Scope">
		<xsl:value-of select="."/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
