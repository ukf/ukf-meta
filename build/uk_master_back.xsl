<?xml version="1.0" encoding="UTF-8"?>
<!--

	uk_master_back.xsl
	
	XSL stylesheet that takes the UK federation master file containing all information
	about UK federation entities and processes them for the "fallback" metadata stream.
	
	This is normally the same as the production metadata stream, except when we have
	recently introduced a change to that, in which case the fallback stream contains
	the metadata without that latest change.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:exsl="http://exslt.org/common"
	xmlns:mdxDates="xalan://uk.ac.sdss.xalan.md.Dates"
	extension-element-prefixes="date exsl mdxDates"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

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
			<xsl:text>&#9;*** Feature fallback metadata; not for production use ***&#10;</xsl:text>
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
		ukfedlabel namespace) may cause the Extensions element to become empty, which is not
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
		Pass through certain ukfedlabel namespace elements.
	-->
	
	<xsl:template match="ukfedlabel:UKFederationMember | ukfedlabel:AccountableUsers">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
		Strip all other ukfedlabel namespace elements entirely.
	-->
	<xsl:template match="ukfedlabel:*">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Remove administrative contacts.
	-->
	<xsl:template match="md:ContactPerson[@contactType='administrative']">
		<!-- do nothing -->
	</xsl:template>
	
	<!--
		Retain only certain comments.
	-->
	
	<xsl:template match="md:EntityDescriptor/comment()">
		<xsl:copy/>
	</xsl:template>
	
	<xsl:template match="shibmd:KeyAuthority//comment()">
		<xsl:copy/>
	</xsl:template>
	
	<!--
		Strip all other comments.
	-->
	
	<!--By default, copy text blocks and attributes unchanged.-->
	<xsl:template match="text()|@*">
		<xsl:copy/>
	</xsl:template>
	
	<!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
