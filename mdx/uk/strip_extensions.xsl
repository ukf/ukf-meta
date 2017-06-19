<?xml version="1.0" encoding="UTF-8"?>
<!--
	strip_extensions.xsl

	Strip out any ukfedlabel namespace extensions that we don't intend to publish.
	This may require removing now-empty md:Extensions elements.
-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<!--
		Pass through certain ukfedlabel namespace elements.
	-->
	<xsl:template match="ukfedlabel:UKFederationMember | ukfedlabel:AccountableUsers">
		<xsl:copy>
			<!--
				Copy nested text and comments, but not attributes.

				AccountableUsers does not have any attributes.

				UKFederationMember does not have any attributes intended for
				publication.
			-->
			<xsl:apply-templates select="text()|comment()"/>
		</xsl:copy>
	</xsl:template>

	<!--
		Strip all other ukfedlabel namespace elements entirely.
	-->
	<xsl:template match="ukfedlabel:*"/>


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
