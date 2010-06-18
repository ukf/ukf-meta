<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_nocert_locs.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	a list of scopes used.  Regular expression scopes are ignored.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	exclude-result-prefixes="shibmd md ds wayf">

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
