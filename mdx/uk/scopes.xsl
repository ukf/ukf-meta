<?xml version="1.0" encoding="UTF-8"?>
<!--

	scopes.xsl
	
	XSL stylesheet that handles the UK federation's approach to Shibboleth
	scope extensions.
	
-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"

	xmlns:ukfxMembers="xalan://uk.org.ukfederation.members.Members"
	extension-element-prefixes="ukfxMembers"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="members">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!--
		Parameters.
	-->
	<xsl:param name="members"/>

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
        	<xsl:for-each select="ukfxMembers:scopesForEntity($members, $entityID)/shibmd:Scope">
        		<xsl:text>    </xsl:text>
                <xsl:element name="shibmd:Scope">
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
			    <xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmd:Scope">
					<xsl:text>&#10;            </xsl:text>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			    <!-- copy scopes from member outsource records -->
				<xsl:for-each select="ukfxMembers:scopesForEntity($members, $entityID)/shibmd:Scope">
					<xsl:text>&#10;            </xsl:text>
			    	<xsl:element name="shibmd:Scope">
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
			<xsl:if test="not(shibmd:Scope)">
				<!-- copy scopes from EntityDescriptor extensions -->
				<xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmd:Scope">
					<xsl:text>    </xsl:text>
					<xsl:copy-of select="."/>
					<xsl:text>&#10;        </xsl:text>
				</xsl:for-each>
			</xsl:if>			
			<!-- copy scopes from member outsource records -->
			<xsl:for-each select="ukfxMembers:scopesForEntity($members, $entityID)/shibmd:Scope">
				<xsl:text>    </xsl:text>
				<xsl:element name="shibmd:Scope">
					<xsl:attribute name="regexp">false</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
				<xsl:text>&#10;        </xsl:text>
			</xsl:for-each>
		</xsl:copy>
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
