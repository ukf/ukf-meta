<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_wayf.xsl
	
	Checking ruleset for the SDSS/UK federation WAYF namespace.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	<!--
		Check for misspelled elements.
		
		This covers the case where elements from this namespace are used in a context
		where lax validation applies.
	-->
	<xsl:template match="wayf:*[local-name()!='HideFromWAYF']">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>unknown element name wayf:</xsl:text>
				<xsl:value-of select="local-name()"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!--
		Check for misplaced HideFromWAYF elements.
	-->
	<xsl:template match="wayf:HideFromWAYF[not(parent::md:Extensions) or not(parent::*/parent::md:EntityDescriptor)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">misplaced wayf:HideFromWAYF element</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
