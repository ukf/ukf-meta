<?xml version="1.0" encoding="UTF-8"?>
<!--
	
	strip-comments.xsl
	
	Remove all comment nodes from a document.
	
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!-- Force UTF-8 encoding for the output. -->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!-- Copy text blocks and attributes unchanged. -->
	<xsl:template match="text()|@*">
		<xsl:copy/>
	</xsl:template>
	
	<!-- Copy all elements from the input to the output, along with their attributes and contents. -->
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
