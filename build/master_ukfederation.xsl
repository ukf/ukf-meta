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
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
	xmlns:shibmeta="urn:mace:shibboleth:metadata:1.0"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="alg members">

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
			<xsl:text>&#10;        </xsl:text>
			<xsl:element name="Extensions" namespace="urn:oasis:names:tc:SAML:2.0:metadata">
				<!-- copy scopes from EntityDescriptor extensions -->
			    <xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmeta:Scope">
					<xsl:text>&#10;            </xsl:text>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			    <!-- copy scopes from member outsource records -->
			    <xsl:for-each select="$outsourcedScopes[members:Entity = $entityID]/members:Scope">
			        <xsl:text>&#10;            </xsl:text>
			    	<xsl:element name="shibmeta:Scope">
			    		<xsl:attribute name="regexp">false</xsl:attribute>
			    		<xsl:value-of select="."/>
			    	</xsl:element>
			    </xsl:for-each>
			    <xsl:text>&#10;        </xsl:text>
			</xsl:element>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
		If an IdP's SSO or AA roles already includes an Extensions element, this may
		already contain extensions other than scopes.  We need to make sure that
		if it does not also contain scopes, then any scopes declared at the entity
		level are copied down, and any outsourced scopes provided by the member
        list are imported.
	-->
	<xsl:template match="md:IDPSSODescriptor/md:Extensions |
						 md:AttributeAuthorityDescriptor/md:Extensions">
		<xsl:copy>
            <xsl:variable name="entityID" select="ancestor::md:EntityDescriptor/@entityID"/>
			<xsl:apply-templates select="node()"/>
			<xsl:if test="not(shibmeta:Scope)">
				<!-- copy scopes from EntityDescriptor extensions -->
				<xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmeta:Scope">
					<xsl:text>    </xsl:text>
					<xsl:copy-of select="."/>
					<xsl:text>&#10;        </xsl:text>
				</xsl:for-each>
                <!-- copy scopes from member outsource records -->
                <xsl:for-each select="$outsourcedScopes[members:Entity = $entityID]/members:Scope">
                    <xsl:text>    </xsl:text>
                    <xsl:element name="shibmeta:Scope">
                        <xsl:attribute name="regexp">false</xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                    <xsl:text>&#10;        </xsl:text>
                </xsl:for-each>
			</xsl:if>			
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
        ***************************************************
        ***                                             ***
        ***   U K F E D L A B E L   N A M E S P A C E   ***
        ***                                             ***
        ***************************************************
    -->
    

	<!--
		Drop any deleted entities.
	-->
	<xsl:template match="md:EntityDescriptor[md:Extensions/ukfedlabel:DeletedEntity]">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop comments from SDSSPolicy elements.
	-->
	<xsl:template match="ukfedlabel:SDSSPolicy/comment()">
		<!-- nothing -->
	</xsl:template>
	
	<!--
		Drop text nodes from SDSSPolicy elements.
	-->
	<xsl:template match="ukfedlabel:SDSSPolicy/text()">
		<!-- nothing -->
	</xsl:template>
	

    <!--
        *************************************
        ***                               ***
        ***   A L G   N A M E S P A C E   ***
        ***                               ***
        *************************************
    -->
    

    <!--
        alg:*
        
        Normalise namespace to not use a prefix.
    -->
    <xsl:template match="alg:*">
        <xsl:element name="{local-name()}" namespace="urn:oasis:names:tc:SAML:metadata:algsupport">
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
