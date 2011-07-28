<?xml version="1.0" encoding="UTF-8"?>
<!--

	final_tweak.xsl

	Final tweaks required for UK federation aggregates.
	
-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"

	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:mdxDates="xalan://uk.ac.sdss.xalan.md.Dates"
	extension-element-prefixes="date mdxDates"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!--
		extraText
		
		This parameter, if present, provides additional text to be put in the
		document comment.
	-->
	<xsl:param name="extraText"/>
	
	<!--
		validityDays
		
		This parameter determines the number of days between the aggregation instant and the
		end of validity of the signed metadata.
	-->
	<xsl:param name="validityDays" select="14"/>
	
	<xsl:variable name="now" select="date:date-time()"/>
	<xsl:variable name="validUntil" select="mdxDates:dateAdd($now, $validityDays)"/>
	
	<!--
		documentID
		
		This value is generated from a normalised version of the aggregation instant,
		transformed so that it can be used as an XML ID value.
		
		Strict conformance to the SAML 2.0 metadata specification (section 3.1.2) requires
		that the signature explicitly references an identifier attribute in the element
		being signed, in this case the document element.
	-->
	<xsl:variable name="normalisedNow" select="mdxDates:dateAdd($now, 0)"/>
	<xsl:variable name="documentID"
		select="concat('uk', translate($normalisedNow, ':-', ''))"/>

	<!--
		Document root.
	-->
	<xsl:template match="/">
		<xsl:call-template name="document.comment"/>
		<xsl:apply-templates/>
	</xsl:template>
	
	<!--
		Document element.
	-->
	<xsl:template match="/md:EntitiesDescriptor">
		<EntitiesDescriptor>
			<xsl:attribute name="validUntil">
				<xsl:value-of select="$validUntil"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$documentID"/>
			</xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="document.comment"/>
			<xsl:apply-templates select="node()"/>
		</EntitiesDescriptor>
	</xsl:template>

	<!--
		Comment to be added to the top of the document, and just inside the document element.
	-->
	<xsl:template name="document.comment">
        <xsl:text>&#10;</xsl:text>
		<xsl:comment>
			<xsl:text>&#10;&#9;U K   F E D E R A T I O N   M E T A D A T A&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:if test="$extraText">
				<xsl:text>&#9;*** </xsl:text>
				<xsl:value-of select="$extraText"/>
				<xsl:text> ***&#10;</xsl:text>
				<xsl:text>&#10;</xsl:text>
			</xsl:if>
			<xsl:text>&#9;Aggregate built </xsl:text>
			<xsl:value-of select="$now"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#9;Aggregate valid for </xsl:text>
			<xsl:value-of select="$validityDays"/>
			<xsl:text> days, until </xsl:text>
			<xsl:value-of select="$validUntil"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:comment>
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
