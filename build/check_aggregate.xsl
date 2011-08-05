<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_aggregate.xsl
	
	Checking ruleset containing aggregate-level checks.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:set="http://exslt.org/sets"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	<xsl:variable name="entities" select="//md:EntityDescriptor"/>
	<xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>

	<!--
		Checks across the whole of the document are defined here.
		
		The match expression here works with version 0.6 of the metadata aggregator.
		Once MDA-45 is fixed, it should be replaced with "/":
		
		https://issues.shibboleth.net/jira/browse/MDA-45
		
		This will make the transform more robust in the presence of nested
		EntitiesDescriptor elements.
	-->
	<xsl:template match="md:EntitiesDescriptor">
		
		<!-- check for duplicate entityID values -->
		<xsl:variable name="distinct.entityIDs" select="set:distinct($entities/@entityID)"/>
		<xsl:variable name="dup.entityIDs"
			select="set:distinct(set:difference($entities/@entityID, $distinct.entityIDs))"/>
		<xsl:for-each select="$dup.entityIDs">
			<xsl:variable name="dup.entityID" select="."/>
			<xsl:for-each select="$entities[@entityID = $dup.entityID]">
				<xsl:call-template name="error">
					<xsl:with-param name="m">duplicate entityID: <xsl:value-of select='$dup.entityID'/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>
		
		<!-- check for duplicate OrganisationDisplayName values -->
		<xsl:variable name="distinct.ODNs"
			select="set:distinct($idps/md:Organization/md:OrganizationDisplayName)"/>
		<xsl:variable name="dup.ODNs"
			select="set:distinct(set:difference($idps/md:Organization/md:OrganizationDisplayName, $distinct.ODNs))"/>
		<xsl:for-each select="$dup.ODNs">
			<xsl:variable name="dup.ODN" select="."/>
			<xsl:for-each select="$idps[md:Organization/md:OrganizationDisplayName = $dup.ODN]">
				<xsl:call-template name="error">
					<xsl:with-param name="m">duplicate OrganisationDisplayName: <xsl:value-of select='$dup.ODN'/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
