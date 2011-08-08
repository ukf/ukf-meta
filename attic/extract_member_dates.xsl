<?xml version="1.0" encoding="UTF-8"?>
<!--

	extract_member_dates.xsl
	
	XSL stylesheet that takes the UK federation members.xml file ane extracts
	member names and joining dates in a format suitable for updating.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:ukfm="http://ukfederation.org.uk/2007/01/members">

	<!-- Output is plain text -->
	<xsl:output method="text"/>
	
	<xsl:template match="ukfm:Member">
		<xsl:value-of select="ukfm:JoinDate"/>
		<xsl:text>,"</xsl:text>
		<xsl:value-of select="md:OrganizationName"/>
		<xsl:text>"&#x0a;</xsl:text>
	</xsl:template>

	<!--
		Junk any extraneous text nodes.
	-->
	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
	
</xsl:stylesheet>
