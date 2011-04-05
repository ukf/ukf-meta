<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_nokeyname.xsl
	
	Checking ruleset for IdPs which have no KeyName; this indicates an IdP which can't interoperate
	with certain versions of OpenAthens SP.

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
