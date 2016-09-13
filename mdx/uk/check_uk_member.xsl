<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_member.xsl
	
    UKf-specific check that an entity has a UKFederationMember label.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>


	<xsl:template match="md:EntityDescriptor/md:Extensions[not(ukfedlabel:UKFederationMember)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">entity does not have a UKFederationMember label</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
