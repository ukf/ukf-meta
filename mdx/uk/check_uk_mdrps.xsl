<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_mdrps.xsl
	
    UKf-specific check for appropriate RegistrationPolicy values.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>


	<xsl:template match="mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']
		/mdrpi:RegistrationPolicy
			[.!='http://ukfederation.org.uk/doc/mdrps-20130902']
		">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>invalid RegistrationPolicy value </xsl:text>
				<xsl:value-of select="."/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
