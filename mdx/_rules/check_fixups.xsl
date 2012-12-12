<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_fixups.xsl

	This checking ruleset verifies that certain fixups have been performed on the
	metadata before it is published.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	
	<!--
		Checks for an IdP whose KeyDescriptor elements do not include a @use attribute.
		This causes problems with the Shibboleth 1.3 SP prior to V1.3.1, which
		interprets this as "no use permitted" rather than "either signing or encryption use
		permitted".
		
		Two checks are required, one for each of the IdP role descriptors.
	-->
	
	<xsl:template match="md:IDPSSODescriptor/md:KeyDescriptor[not(@use)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">IdP SSO KeyDescriptor lacking @use</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="md:AttributeAuthorityDescriptor/md:KeyDescriptor[not(@use)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">IdP AA KeyDescriptor lacking @use</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	

	<!--
		Use of EncryptionMethod within KeyDescriptor causes metadata loading problems
		for OpenSAML-C 2.0.
		
		See https://wiki.shibboleth.net/confluence/display/SHIB2/MetadataCorrectness#MetadataCorrectness-Version2.0
	-->
	<xsl:template match="md:KeyDescriptor/md:EncryptionMethod">
		<xsl:call-template name="error">
			<xsl:with-param name="m">KeyDescriptor contains EncryptionMethod: OpenSAML-C 2.0 problem</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
