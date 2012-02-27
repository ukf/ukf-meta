<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_saml1.xsl

	Checking ruleset containing rules associated with the SAML 1.x specification.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	<!--
		A service provider claiming to support SAML 1.1 should include an appropriate POST AssertionConsumerService.
	-->
	<xsl:template match="md:EntityDescriptor/md:SPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol')]
		[not(md:AssertionConsumerService[@Binding = 'urn:oasis:names:tc:SAML:1.0:profiles:browser-post'])]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">no POST support on SAML 1.1 SP</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
		
</xsl:stylesheet>
