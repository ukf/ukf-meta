<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_ukreg.xsl
	
	Checking ruleset containing rules that only apply to metadata registered
	by the UK federation's registrar function.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	
	<!--
		Check for entities which do not have an OrganizationName at all.
	-->
	<xsl:template match="md:EntityDescriptor[not(md:Organization/md:OrganizationName)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">entity lacks OrganizationName</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!--
		Check for https:// locations that use an explicit but redundant port specifier.
	-->
	<xsl:template match="*[@Location and starts-with(@Location, 'https://')
		and contains(@Location,':443/')]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:value-of select='local-name()'/>
				<xsl:text> Location </xsl:text>
				<xsl:value-of select="@Location"/>
				<xsl:text> not in standard form</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
