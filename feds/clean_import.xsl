<?xml version="1.0" encoding="UTF-8"?>
<!--
	
	clean_import.xsl
	
	Clean up imported metadata from a metadata exchange channel.
	
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:elab="http://eduserv.org.uk/labels"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	exclude-result-prefixes="elab ukfedlabel wayf">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!-- strip everything from certain namespaces -->
	<xsl:template match="elab:*"/>
	<xsl:template match="ukfedlabel:*"/>
	<xsl:template match="wayf:*"/>
	
	<!-- strip redundant attributes from EntityDescriptor elements -->
	<xsl:template match="md:EntityDescriptor/@ID"/>
	<xsl:template match="md:EntityDescriptor/@cacheDuration"/>
	<xsl:template match="md:EntityDescriptor/@validUntil"/>
	
	<!-- strip xml:base entirely -->
	<xsl:template match="@xml:base"/>
	
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
