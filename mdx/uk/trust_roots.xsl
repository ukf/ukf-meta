<?xml version="1.0" encoding="UTF-8"?>
<!--

	trust_roots.xsl
	
	XSL stylesheet that adds the UK federation's trust roots in to an
	EntitiesDescriptor aggregate.
	
-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        The key authorities document is passed in as a parmeter.  This is an EntitiesDescriptor
        with the KeyAuthority list as a child Extensions element.
    -->
    <xsl:param name="trustRootsDocument"/>

	<!--
		Inject the key authorities into the document EntitiesDescriptor element.
	-->
	<xsl:template match="/md:EntitiesDescriptor">
		<xsl:copy>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates select="$trustRootsDocument//md:Extensions"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	
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
