<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_saml2.xsl

	Checking ruleset containing rules associated with the SAML 2.0 specification.
	
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
		It does not make sense for an IdP to have more than one SingleSignOnService
		with any of a list of SAML 2.0 front-channel bindings.
	-->
	<xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'][position()>1]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-POST binding</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign'][position()>1]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-POST-SimpleSign binding</xsl:with-param>
		</xsl:call-template>
	</xsl:template> 

	<xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'][position()>1]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-Redirect binding</xsl:with-param>
		</xsl:call-template>
	</xsl:template> 

</xsl:stylesheet>
