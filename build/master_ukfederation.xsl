<?xml version="1.0" encoding="UTF-8"?>
<!--

	master_ukfederation.xsl
	
	XSL stylesheet that takes a SAML 2.0 metadata master file containing
	a trust fabric and optional entities, and makes a UK federation
	master file by tweaking appropriately and inserting the combined
	entities file.  The entities from the combined entities file are
	also transformed in various ways here.
	
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
	xmlns:members="http://ukfederation.org.uk/2007/01/members"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	exclude-result-prefixes="wayf members">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Pick up "members" document and extract outsourced scope lists from it.
    -->
    <xsl:variable name="memberDocument" select="document('../xml/members.xml')"/>
    <xsl:variable name="outsourcedScopes"
        select="$memberDocument//members:Member/members:Scopes[members:Entity]"/>

    <!--
		Root EntitiesDescriptor element.
		
		Copy all attributes and nested elements to the output, then
		insert the entities from the entities file at the end.
	-->
	<xsl:template match="/md:EntitiesDescriptor">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
			<xsl:apply-templates select="document('../xml/entities.xml')/*/md:EntityDescriptor"/>
		</xsl:copy>
	</xsl:template>

    <!--
        Extend the scope list contained within an IdP's entity-level Extensions element
        with any outsourced scopes provided by the member list. 
    -->
    <xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor]/md:Extensions">
        <xsl:copy>
            <!-- copy everything from within the original element -->
            <xsl:apply-templates select="node()"/>
            <!-- copy scopes from member outsource records -->
            <xsl:variable name="entityID" select="ancestor::md:EntityDescriptor/@entityID"/>
            <xsl:for-each select="$outsourcedScopes[members:Entity = $entityID]/members:Scope">
                <xsl:text>    </xsl:text>
                <xsl:element name="shibmeta:Scope">
                    <xsl:attribute name="regexp">false</xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
                <xsl:text>&#10;    </xsl:text>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!--
        If an IdP's SSO or AA roles are missing Extensions (and Scope extensions in
        particular) then manufacture them as a combination of the EntityDescriptor's
        overall scope extensions and any outsourced scopes provided by the member list.
    -->
    <xsl:template match="md:IDPSSODescriptor[not(md:Extensions)] |
                         md:AttributeAuthorityDescriptor[not(md:Extensions)]">
		<xsl:copy>
		    <xsl:variable name="entityID" select="ancestor::md:EntityDescriptor/@entityID"/>
		    <xsl:apply-templates select="@*"/>
			<xsl:text>&#10;        </xsl:text><Extensions>
			    <!-- copy scopes from EntityDescriptor extensions -->
			    <xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmeta:Scope">
					<xsl:text>&#10;            </xsl:text>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			    <!-- copy scopes from member outsource records -->
			    <xsl:for-each select="$outsourcedScopes[members:Entity = $entityID]/members:Scope">
			        <xsl:text>&#10;            </xsl:text>
			        <shibmeta:Scope regexp="false"><xsl:value-of select="."/></shibmeta:Scope>
			    </xsl:for-each>
			    <xsl:text>&#10;        </xsl:text></Extensions>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
		Drop any explicit xsi:schemaLocation attributes from imported entity fragments.
	-->
	<xsl:template match="@xsi:schemaLocation[parent::md:EntityDescriptor]">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop any dummy entities.
	-->
	<xsl:template match="md:EntityDescriptor[@entityID='dummy']">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop any deleted entities.
	-->
	<xsl:template match="md:EntityDescriptor[md:Extensions/uklabel:DeletedEntity]">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop comments from SDSSPolicy elements.
	-->
	<xsl:template match="uklabel:SDSSPolicy/comment()">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop text nodes from SDSSPolicy elements.
	-->
	<xsl:template match="uklabel:SDSSPolicy/text()">
		<!-- nothing -->
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
