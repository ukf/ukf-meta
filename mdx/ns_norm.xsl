<?xml version="1.0" encoding="UTF-8"?>
<!--

	ns_norm.xsl
	
	XSL stylesheet that takes a SAML 2 metadata file and normalises
	the namespaces used.  In general, this means assigning a standard
	prefix to each known namespace and ensuring that those namespaces
	are declared on the document element.
	
	The exception is the SAML 2.0 metadata namespace, which is established
	as the default namespace for the document and therefore does not
	require a prefix.
	
	The stylesheet operates by matching every element node in the document
	and rebuilding it from scratch.  This has the side-effect of discarding
	any unwanted namespace definitions from intermediate nodes.
	
	The result is a document with a large number of namespaces declared
	with associated prefixes on the document element, and with few
	(hopefully no) namespace prefix declarations elsewhere.  For any
	particular document, this normalised form may define some namespaces
	which are never used, and define some at the document level which
	would be better defined on the elements on which they are actually
	used (with or without prefixes).  For example, a bug in one of the
	libraries underlying the xmlsectool application means that it cannot
	verify the signature on a document where more than about ten prefixes
	are in scope on any given element.  In practice this may mean that
	after normalisation, some *de*normalisation will be required or at
	least desirable prior to publication.  The responsibility for this
	lies further down the processing pipeline.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
	xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
	xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	
	exclude-result-prefixes="md"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Force UTF-8 encoding for the output.
	-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>


	<!--
		*******************************************
		***                                     ***
		***   D O C U M E N T   E L E M E N T   ***
		***                                     ***
		*******************************************
	-->
	
	
	<!--
		We need to handle the document element specially in order to arrange
		for all appropriate namespace prefix definitions to appear on it.
		
		There are only two possible document elements in SAML metadata.
	-->
	
	
	<!--
		Document element is <EntityDescriptor>.
	-->
	<xsl:template match="/md:EntityDescriptor">
		<EntityDescriptor>
			<xsl:apply-templates select="node()|@*"/>
		</EntityDescriptor>
	</xsl:template>
	
	<!--
		Document element is <EntitiesDescriptor>.
	-->
	<xsl:template match="/md:EntitiesDescriptor">
		<EntitiesDescriptor>
			<xsl:apply-templates select="node()|@*"/>
		</EntitiesDescriptor>
	</xsl:template>
	
	
	<!--
		*********************************************
		***                                       ***
		***   D E F A U L T   N A M E S P A C E   ***
		***                                       ***
		*********************************************
	-->
	
	
	<xsl:template match="md:*">
		<xsl:element name="{local-name()}" namespace="urn:oasis:names:tc:SAML:2.0:metadata">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	
	<!--
		*************************************************************
		***                                                       ***
		***   K N O W N   P R E F I X E D   N A M E S P A C E S   ***
		***                                                       ***
		*************************************************************
	-->
	

	<xsl:template match="alg:*">
		<xsl:element name="alg:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ds:*">
		<xsl:element name="ds:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="idpdisc:*">
		<xsl:element name="idpdisc:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="init:*">
		<xsl:element name="init:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="mdattr:*">
		<xsl:element name="mdattr:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="mdrpi:*">
		<xsl:element name="mdrpi:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="mdui:*">
		<xsl:element name="mdui:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="saml:*">
		<xsl:element name="saml:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="shibmd:*">
		<xsl:element name="shibmd:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ukfedlabel:*">
		<xsl:element name="ukfedlabel:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="wayf:*">
		<xsl:element name="wayf:{local-name()}">
			<xsl:apply-templates select="node()|@*"/>
		</xsl:element>
	</xsl:template>
	
		
	<!--
		*********************************************
		***                                       ***
		***   D E F A U L T   T E M P L A T E S   ***
		***                                       ***
		*********************************************
	-->
	
	
	<!--
		Copy text blocks, comments and attributes unchanged.
	-->
	<xsl:template match="text()|comment()|@*">
		<xsl:copy/>
	</xsl:template>
	
	
	<!--
		Copy all other elements from the input to the output, along with their
		attributes and contents.
		
		Note that this will also copy across their namespaces and namespace prefix
		declarations, which can result in denormalised output.  If that turns out
		to be a problem in practice, this should be changed to reconstruct the
		nodes in question using xsl:element with name="{local-name()}" along
		with the original node's namespace but probably not prefix.
	-->
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
