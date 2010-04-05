<?xml version="1.0" encoding="UTF-8"?>
<!--

	uk_master_export.xsl
	
	XSL stylesheet that takes the UK federation master file containing all information
	about UK federation entities and processes them for the "export" metadata stream.
	
	This is initially the same as the production metadata stream, and not for publication.
	
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
	xmlns:exsl="http://exslt.org/common"
	xmlns:mdxDates="xalan://uk.ac.sdss.xalan.md.Dates"
	extension-element-prefixes="date exsl mdxDates"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	exclude-result-prefixes="wayf">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!--
		validityDays
		
		This parameter determines the number of days between the aggregation instant and the
		end of validity of the signed metadata.
	-->
	<xsl:variable name="validityDays" select="14"/>
	
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
		<xsl:copy>
			<xsl:attribute name="validUntil">
				<xsl:value-of select="$validUntil"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$documentID"/>
			</xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="document.comment"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!--
		Comment to be added to the top of the document, and just inside the document element.
	-->
	<xsl:template name="document.comment">
		<xsl:text>&#10;</xsl:text>
		<xsl:comment>
			<xsl:text>&#10;&#9;U K   F E D E R A T I O N   M E T A D A T A&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#9;*** Prototype export metadata; not for production use ***&#10;</xsl:text>
			<xsl:text>&#10;</xsl:text>
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
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<!--
		Handle <md:Extensions> elements.
		
		In general, at this stage in the flow we pass through any Extensions unaltered.
		However, certain changes (such as the filtering we perform on extensions in the
		uklabel namespace) may cause the Extensions element to become empty, which is not
		permitted by the schema.  We therefore precompute the resulting Extensions element
		and suppress it entirely if it would have no child elements.
	-->
	<xsl:template match="md:Extensions">
		<!-- compute result -->
		<xsl:variable name="ext">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*"/>
			</xsl:copy>
		</xsl:variable>
		<!-- copy through only if schema-valid -->
		<xsl:if test="count(exsl:node-set($ext)/md:Extensions/*) != 0">
			<xsl:copy-of select="$ext"/>
		</xsl:if>
	</xsl:template>
	
	<!--
		Drop text nodes inside the document element.  There's one of these for each
		EntityDescriptor in the original document, so without this most of the output
		file is blank.
	-->
	<xsl:template match="md:EntitiesDescriptor/text()">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Drop the federation-specific key authority information.
		
		We assume, for now, that this is the only extension on the EntitiesDescriptor
		and just omit that entirely.  If we ever start putting other extensions in at
		that level, this would need to be revised.
	-->
	<xsl:template match="md:EntitiesDescriptor/md:Extensions">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Only include explicitly opted-in entities by discarding
		everything else.
		
		There must be at least one of these, or the output will
		not be schema-valid.
	-->
	<xsl:template match="md:EntityDescriptor[not(md:Extensions/uklabel:ExportOptIn)]">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Pass through certain uklabel namespace elements.
	-->
	<xsl:template match="uklabel:UKFederationMember |
		uklabel:AccountableUsers">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
		Strip all other uklabel namespace elements entirely.
	-->
	<xsl:template match="uklabel:*">
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
