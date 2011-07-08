<?xml version="1.0" encoding="UTF-8"?>
<!--

	fixups.xsl
	
	XSL stylesheet to perform any fixups required to an EntityDescriptor prior to
	publication to the UK federation membership.
	
-->
<xsl:stylesheet version="1.0"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="xsi xsl">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	
	<!--
		Patch any @use-less KeyName descriptors in IdP roles
		for the benefit of Shib SPs pre-1.3.1.
	-->
	<xsl:template match="md:IDPSSODescriptor/md:KeyDescriptor[not(@use)] |
		md:AttributeAuthorityDescriptor/md:KeyDescriptor[not(@use)]">
		<xsl:copy>
			<xsl:attribute name="use">signing</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	
	<!--
		Remove any EncryptionMethod elements within KeyDescriptor elements
		to avoid triggering a problem in OpenSAML-C 2.0.
		
		See https://wiki.shibboleth.net/confluence/display/SHIB2/MetadataCorrectness#MetadataCorrectness-Version2.0
	-->
	<xsl:template match="md:KeyDescriptor/md:EncryptionMethod"/>
	
		
	<!--
        *********************************************
        ***                                       ***
        ***   D E F A U L T   T E M P L A T E S   ***
        ***                                       ***
        *********************************************
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
