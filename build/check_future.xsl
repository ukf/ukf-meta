<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_future.xsl
	
	Checking ruleset containing rules that we don't currently implement,
	but which we may implement in the future.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:set="http://exslt.org/sets"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"

	xmlns:mdxURL="xalan://uk.ac.sdss.xalan.md.URLchecker"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	
	<!--
		Check for SAML 2.0 SPs which lack an encryption key.
	-->
	
	<xsl:template match="md:SPSSODescriptor
		[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
		[not(md:KeyDescriptor[descendant::ds:X509Data][@use='encryption'])]
		[not(md:KeyDescriptor[descendant::ds:X509Data][not(@use)])]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">SAML 2 SP has no encryption key</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
		Check for SAML 2.0 SPs which exclude the SAML 2 name identifier format.
	-->
	
	<xsl:template match="md:SPSSODescriptor
		[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
		[md:NameIDFormat]
		[not(md:NameIDFormat[.='urn:oasis:names:tc:SAML:2.0:nameid-format:transient'])]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">SAML 2 SP excludes SAML 2 name identifier format</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
		Check for endpoint locations that include a '%' character,
		which is symptomatic of their being URL-encoded instead of entity-encoded.
	-->
	
	<xsl:template match="@Location[contains(., '%')]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">URL-encoded Location attribute; should be entity-encoded</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!--
		Check for IdPs which have no KeyName; this indicates an IdP which can't interoperate
		with certain versions of OpenAthens SP.
	-->
	
	<xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor][not(descendant::ds:KeyName)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">
				<xsl:if test="descendant::md:Extensions/wayf:HideFromWAYF">
					<xsl:text>(hidden) </xsl:text>
				</xsl:if>
				<xsl:text>identity provider lacks PKIX validatable credential</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">
				<xsl:value-of select="descendant::md:OrganizationDisplayName"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="@entityID"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
