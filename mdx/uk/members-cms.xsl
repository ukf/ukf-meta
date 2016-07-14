<?xml version="1.0" encoding="UTF-8"?>
<!--
	members-cms.xsl
	
	Tweak the members.xml document so that it can be consumed by the legacy CMS.
-->
<xsl:stylesheet version="1.0"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:members="http://ukfederation.org.uk/2007/01/members"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="members">

	<!--
        Force UTF-8 encoding for the output.
    -->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>
	
	<!--
		Remove ID attributes from Member and DomainOwner elements.
	-->
	<xsl:template match="members:Member/@ID">
		<!-- nothing -->
	</xsl:template>
	<xsl:template match="members:DomainOwner/@ID">
		<!-- nothing -->
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
