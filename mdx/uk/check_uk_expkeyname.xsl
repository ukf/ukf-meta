<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_expkeyname.xsl
	
    UKf-specific check that no KeyName elements appear in entities opted
    in for inter-federation metadata exchange.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>


	<!--
		If a UK-registered entity is opted in to the export aggregate, it MUST
		NOT have any KeyName elements.
	-->
	<xsl:template match="md:EntityDescriptor
		[descendant::mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']]
		[md:Extensions/ukfedlabel:ExportOptIn]
		[descendant::ds:KeyName]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>exported entity must not have a KeyName</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
