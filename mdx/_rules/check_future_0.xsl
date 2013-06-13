<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_future_0.xsl
	
	Checking ruleset containing rules that we don't currently implement,
	but which we may implement in the future.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
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
		If an IdP has both an OrganizationDisplayName in English, and an
		mdui:DisplayName in English, they must be identical.
		
		UKFTS 1.4 section 3.3
	-->
	<xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor]">
		<xsl:variable name="mdui" select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']"/>
		<xsl:variable name="odn" select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/>
		<xsl:if test="$mdui and $odn and $mdui != $odn">
			<xsl:call-template name="error">
				<xsl:with-param name="m">
					<xsl:text>mismatched xml:lang='en' DisplayNames: '</xsl:text>
					<xsl:value-of select="$mdui"/>
					<xsl:text>' in mdui vs. '</xsl:text>
					<xsl:value-of select="$odn"/>
					<xsl:text>' in ODN</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
