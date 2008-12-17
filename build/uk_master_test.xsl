<?xml version="1.0" encoding="UTF-8"?>
<!--

	uk_master_test.xsl
	
	XSL stylesheet that takes the UK federation master file containing all information
	about UK federation entities and processes them for the "test" metadata stream.
	
	This is normally the same as the production metadata stream, except when we are
	testing some modification and wish to publish alternate metadata.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:shibmeta="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:uklabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	exclude-result-prefixes="wayf">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:variable name="now" select="date:date-time()"/>
	
	<!--
		Add a comment to the start of the output file.
	-->
	<xsl:template match="/">
		<xsl:comment>
			<xsl:text>&#10;&#9;U K   F E D E R A T I O N   M E T A D A T A&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#9;*** Feature test metadata; not for production use ***&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#9;Aggregate built </xsl:text>
			<xsl:value-of select="$now"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:comment>
		<xsl:apply-templates/>
	</xsl:template>
	
	<!--
		Strip uklabel:Software elements entirely.
	-->
	<xsl:template match="uklabel:Software|uklabel:Software">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Remove administrative contacts.
	-->
	<xsl:template match="md:ContactPerson[@contactType='administrative']">
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
