<?xml version="1.0" encoding="UTF-8"?>
<!--

	just_ours.xsl

	Remove SAML entities registered other than by the UK federation.

	Leave in entities without registrationAuthority so that this still does
	the right thing with older aggregates which don't have MDRPI metadata.

	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Force UTF-8 encoding for the output.
	-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>

	<!--
		Discard entities not registered by the UK federation.
	-->
	<xsl:template match="md:EntityDescriptor
		[not(descendant::mdrpi:RegistrationInfo/@registrationAuthority='http://ukfederation.org.uk')]">
		<!-- do nothing -->
	</xsl:template>

	<!--By default, copy text blocks, comments and attributes unchanged.-->
	<xsl:template match="text()|comment()|@*">
		<xsl:copy/>
	</xsl:template>

	<!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
