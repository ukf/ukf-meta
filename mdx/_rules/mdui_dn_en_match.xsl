<?xml version="1.0" encoding="UTF-8"?>
<!--

    mdui_dn_en_match.xsl

    If an IdP has both an OrganizationDisplayName in English, and an
    mdui:DisplayName in English, they must be identical.

    UKFTS 1.4 section 3.3

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor]">
        <xsl:variable name="mdui" select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']"/>
        <xsl:variable name="odn" select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/>
        <xsl:if test="$mdui and $odn and $mdui != $odn">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>mismatched xml:lang='en' DisplayNames: '</xsl:text>
                    <xsl:value-of select="$mdui"/>
                    <xsl:text>' in mdui vs. '</xsl:text>
                    <xsl:value-of select="$odn"/>
                    <xsl:text>' in ODN</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
