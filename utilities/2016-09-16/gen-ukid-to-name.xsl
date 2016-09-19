<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="text" encoding="UTF-8"/>

	<xsl:template match="md:EntityDescriptor">
		<xsl:value-of select="@ID"/>
		<xsl:text>&#9;</xsl:text>
		<xsl:value-of select="md:Organization/md:OrganizationName"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="text()">
		<!-- do nothing -->
	</xsl:template>
</xsl:stylesheet>
