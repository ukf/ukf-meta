<?xml version="1.0" encoding="UTF-8"?>
<!--
	
	clean-import.xsl
	
	Clean up imported metadata from a metadata exchange channel.
	
-->
<xsl:stylesheet version="1.0"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:elab="http://eduserv.org.uk/labels"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdxTextUtils="xalan://uk.ac.sdss.xalan.md.TextUtils"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	extension-element-prefixes="mdxTextUtils"
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
	
	<!-- remove KeyDescriptor elements which lack embedded key material -->
	<xsl:template match="md:KeyDescriptor[not(descendant::ds:X509Certificate)]"/>
	
	<!-- Remove KeyName elements; they refer to an inaccessable trust fabric -->
	<xsl:template match="ds:KeyName"/>
	
	<!-- Remove <ds:X509SubjectName> elements; long ones cause problems. -->
	<xsl:template match="ds:X509SubjectName"/>
	
	<!--
		Normalise whitespace in X509Certificate elements.
	-->
	<!--
	<xsl:template match="ds:X509Certificate">
		<xsl:element name="ds:X509Certificate">
			<xsl:text>&#10;</xsl:text>
			<xsl:value-of select="mdxTextUtils:wrapBase64(.)"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:element>
	</xsl:template>
	-->
	
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
