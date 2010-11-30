<?xml version="1.0" encoding="UTF-8"?>
<!--

	members_domains.xsl
	
	Update members.xml to use Domain and PrimaryScope instead of
	Scopes and isPrimary.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:members="http://ukfederation.org.uk/2007/01/members"
	xmlns:xalan="http://xml.apache.org/xalan"
	
	exclude-result-prefixes="members xalan"
	xmlns="http://ukfederation.org.uk/2007/01/members"
	>

	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"
		indent="yes" xalan:indent-amount="4"
	/>
	
	<!--
		If a Scopes element has an isPrimary Scope, extract that
		as the domain and primary scope for the member.
		
		The result may not be schema-valid if the Scopes element is not
		the first one belonging to the member: duplicate Domains elements
		need to be removed, and misplaced Domains elements may need
		to be moved around manually.
	-->
	<xsl:template match="members:Scopes[members:Scope/@isPrimary='true']">
		<xsl:variable name="prdom" select="members:Scope[@isPrimary='true']"/>
		<xsl:element name="Domains">
			<xsl:text>&#10;            </xsl:text>
			<xsl:element name="Domain"><xsl:value-of select="$prdom"/></xsl:element>
			<xsl:text>&#10;        </xsl:text>
		</xsl:element>
		<xsl:text>&#10;        </xsl:text>
		<xsl:element name="PrimaryScope"><xsl:value-of select="$prdom"/></xsl:element>
		<!--
			Delete the Scopes element entirely if:
				* it contains only one Scope, and
				* it contains no Entity elements
				
			In other words, retain it if:
				* it contains more than one Scope, or
				* it contains any Entity elements
		-->
		<xsl:if test="count(members:Scope)>1 or count(members:Entity)!=0">
			<xsl:text>&#10;        </xsl:text>
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<!--
		Remove any remaining isPrimary attributes.
	-->
	<xsl:template match="@isPrimary">
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
