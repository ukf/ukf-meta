<?xml version="1.0" encoding="UTF-8"?>
<!--

	master_to_wayf.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata file and filters out
	entities marked as hidden from the WAYF.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	exclude-result-prefixes="md wayf">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!--
		The WAYF does not need the key authority information for the federation.
		
		We assume, for now, that this is the only extension on the EntitiesDescriptor
		and just omit that entirely.  If we ever start putting other extensions in at
		that level, this would need to be revised.
	-->
	<xsl:template match="md:EntitiesDescriptor/md:Extensions">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Any entity which has an entity-level extension element wayf:HideFromWAYF
		is omitted from the output.
	-->
	<xsl:template match="md:EntityDescriptor[md:Extensions/wayf:HideFromWAYF]">
		<!-- do nothing -->	
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
