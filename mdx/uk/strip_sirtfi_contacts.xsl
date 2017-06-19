<?xml version="1.0" encoding="UTF-8"?>
<!--
	strip_sirtfi_contacts.xsl

	Strip out any UK federation-registered ContactPerson elements associated with SIRTFI.
-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
	xmlns:remd="http://refeds.org/metadata"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<xsl:template match="md:EntityDescriptor[md:Extensions/mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']]
		/md:ContactPerson[@contactType='other'][@remd:contactType='http://refeds.org/metadata/contactType/security']">
		<!-- remove -->
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
