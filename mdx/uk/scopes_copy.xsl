<?xml version="1.0" encoding="UTF-8"?>
<!--

	scopes_copy.xsl

	Make all three potential scope lists equivalent (on the entity, on
	the IDPSSODescriptor and on the AttributeAuthority).

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        If an IdP's SSO or AA roles are missing Extensions (and Scope extensions in
        particular) then copy down the EntityDescriptor's overall scope extensions.
    -->
    <xsl:template match="md:IDPSSODescriptor[not(md:Extensions)] |
                         md:AttributeAuthorityDescriptor[not(md:Extensions)]">
		<xsl:copy>
		    <xsl:apply-templates select="@*"/>
			<xsl:text>&#10;        </xsl:text>
			<xsl:element name="Extensions" namespace="urn:oasis:names:tc:SAML:2.0:metadata">
				<!-- copy scopes from EntityDescriptor extensions -->
			    <xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmd:Scope">
					<xsl:text>&#10;            </xsl:text>
					<xsl:copy-of select="."/>
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
		level are copied down.
	-->
	<xsl:template match="md:IDPSSODescriptor/md:Extensions |
						 md:AttributeAuthorityDescriptor/md:Extensions">
		<xsl:copy>
			<xsl:apply-templates select="node()"/>
			<xsl:if test="not(shibmd:Scope)">
				<!-- copy scopes from EntityDescriptor extensions -->
				<xsl:for-each select="ancestor::md:EntityDescriptor/md:Extensions/shibmd:Scope">
					<xsl:text>    </xsl:text>
					<xsl:copy-of select="."/>
					<xsl:text>&#10;        </xsl:text>
				</xsl:for-each>
			</xsl:if>
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
