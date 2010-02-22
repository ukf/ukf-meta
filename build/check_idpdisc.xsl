<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_imported.xsl
	
	Checking ruleset containing rules associated with the SAML IdP Discovery Protocol.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	
	<!--
		Checks on the DiscoveryResponse extension.
	-->
	
	<xsl:template match="idpdisc:DiscoveryResponse[not(@Binding)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">missing Binding attribute on DiscoveryResponse</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="idpdisc:DiscoveryResponse[@Binding]
		[@Binding!='urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol']">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">incorrect Binding value on DiscoveryResponse</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
