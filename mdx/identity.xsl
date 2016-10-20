<?xml version="1.0" encoding="UTF-8"?>
<!--

	identity.xsl

	Identity transform.

	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Force UTF-8 encoding for the output.
	-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>

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
