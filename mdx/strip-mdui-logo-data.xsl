<?xml version="1.0" encoding="UTF-8"?>
<!--

	strip-mdui-logo-data.xsl

	Remove all mdui:Logo elements containing data: URLs.

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
	    Remove all mdui:Logo elements containing data: URLs.
	-->
	<xsl:template match="mdui:Logo[starts-with(., 'data:')]"/>

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
