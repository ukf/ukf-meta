<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_ukreg.xsl
	
	Checking ruleset containing rules that only apply to metadata registered
	by the UK federation's registrar function.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:mdxMail="xalan://uk.ac.sdss.xalan.md.Mail"
	xmlns:ukfxMembers="xalan://uk.org.ukfederation.members.Members"
	extension-element-prefixes="mdxMail ukfxMembers"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>

	
	<!--
		Parameters.
	-->
	<xsl:param name="members"/>
	
	
	<!--
		Check EntityDescriptor elements.
	-->
	<xsl:template match="md:EntityDescriptor">
		
		<!-- tests on OrganizationName -->
		<xsl:choose>

			<!--
				Check for entities which do not have an OrganizationName at all.
			-->
			<xsl:when test="not(md:Organization/md:OrganizationName)">
				<xsl:call-template name="error">
					<xsl:with-param name="m">entity lacks OrganizationName</xsl:with-param>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<!--
					Check for entities with OrganizationName elements which don't correspond to
					a canonical owner name.
				-->
				<xsl:if test="not(ukfxMembers:isOwnerName($members, md:Organization/md:OrganizationName))">
					<xsl:call-template name="error">
						<xsl:with-param name="m">unknown owner name: <xsl:value-of select="md:Organization/md:OrganizationName"/></xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>

		</xsl:choose>

		<!-- apply tests to child elements -->
		<xsl:apply-templates/>
	</xsl:template>


	<!--
		Check for badly formatted e-mail addresses.
	-->
	<xsl:template match="md:EmailAddress[mdxMail:dodgyAddress(.)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">badly formatted e-mail address: '<xsl:value-of select='.'/>'</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for https:// locations that use an explicit but redundant port specifier.
	-->
	<xsl:template match="*[@Location and starts-with(@Location, 'https://')
		and contains(@Location,':443/')]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:value-of select='local-name()'/>
				<xsl:text> Location </xsl:text>
				<xsl:value-of select="@Location"/>
				<xsl:text> not in standard form</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for entities which are both opted in to and opted out from export.
	-->
	<xsl:template match="md:EntityDescriptor/md:Extensions[ukfedlabel:ExportOptIn][ukfedlabel:ExportOptOut]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>entity cannot be both opted in to and opted out from export</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
