<?xml version="1.0" encoding="UTF-8"?>
<!--

	check.xsl
	
	XSL stylesheet that takes a file full of metadata for the UK federation
	and checks it against local conventions.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:set="http://exslt.org/sets"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns:mdxMail="xalan://uk.ac.sdss.xalan.md.Mail"
	xmlns:ukfxMembers="xalan://uk.org.ukfederation.members.Members"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="check_framework.xsl"/>

	
	<!--
		Pick up the members.xml document, and create a Members class instance.
	-->
	<xsl:variable name="memberDocument" select="document('../xml/members.xml')"/>
	<xsl:variable name="members" select="ukfxMembers:new($memberDocument)"/>

	
	<!--
		Check for entities with OrganizationName elements which don't correspond to
		a canonical owner name.
	-->
	<xsl:template match="md:EntityDescriptor[md:Organization/md:OrganizationName]
		[not(ukfxMembers:isOwnerName($members, md:Organization/md:OrganizationName))]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">unknown owner name: <xsl:value-of select="md:Organization/md:OrganizationName"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for badly formatted e-mail addresses.
	-->
	<xsl:template match="md:EmailAddress[mdxMail:dodgyAddress(.)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">badly formatted e-mail address: '<xsl:value-of select='.'/>'</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
