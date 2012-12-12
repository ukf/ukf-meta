<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_addresses.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and extracts
	a list of contact e-mail addresses.  Only administrative and
	technical addresses are used; all others are dropped.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	exclude-result-prefixes="md ds wayf">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/md:EntitiesDescriptor">
		<Addresses>
			<xsl:apply-templates select="md:EntityDescriptor/md:ContactPerson"/>
		</Addresses>
	</xsl:template>
	
	<xsl:template match="md:ContactPerson[@contactType='support']">
		<!-- do nothing -->
	</xsl:template>
	
	<xsl:template match="md:ContactPerson">
		<xsl:apply-templates select="md:EmailAddress"/>
	</xsl:template>
	
	<xsl:template match="md:EmailAddress">
		<EmailAddress><xsl:value-of select="."/></EmailAddress>
	</xsl:template>
	<!--By default, copy text blocks, comments and attributes unchanged.-->
	<xsl:template match="text()|@*">
		<xsl:copy/>
	</xsl:template>
	
</xsl:stylesheet>
