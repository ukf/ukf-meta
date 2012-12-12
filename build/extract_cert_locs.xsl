<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_cert_locs.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	a list of service locations that require certificates to be
	presented to them.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="md">

	<!-- Output is plain text -->
	<xsl:output method="text"/>

	<xsl:template match="//md:AttributeService">
		<xsl:value-of select="@Location"/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	
	<!--
		ArtifactResolutionService endpoints on IdPs are assumed to be
		authenticated by TLS; those on SPs are assumed to be authenticated
		using other mechanisms.
	-->
	<xsl:template match="//md:IDPSSODescriptor/md:ArtifactResolutionService">
		<xsl:value-of select="@Location"/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
