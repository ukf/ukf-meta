<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_keydesc_key.xsl

    UKf-specific check that all KeyDescriptor elements contain an embedded key.

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


	<xsl:template match="md:KeyDescriptor[not(descendant::ds:X509Data)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>KeyDescriptor lacks embedded key material</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
