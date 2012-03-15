<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_future_6.xsl
	
    Checking ruleset containing rules that we don't currently implement,
    but which we may implement in the future.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns:set="http://exslt.org/sets"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../build/check_framework.xsl"/>

	<xsl:template match="md:AssertionConsumerService
		[@Binding != 'http://schemas.xmlsoap.org/ws/2003/07/secext']
		[@Binding != 'urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']
		[@Binding != 'urn:oasis:names:tc:SAML:1.0:profiles:browser-post']
		[@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
		[@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
		[@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
		[@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:PAOS']
		">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>invalid binding '</xsl:text>
				<xsl:value-of select="@Binding"/>
				<xsl:text>' on </xsl:text>
				<xsl:value-of select="name()"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
