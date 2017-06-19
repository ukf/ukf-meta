<?xml version="1.0" encoding="UTF-8"?>
<!--

    mdui_dn_en_present.xsl

    If an entity has mdui:UIInfo, then that must include at least an
    mdui:DisplayName with an English name.

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

    <xsl:template match="mdui:UIInfo[not(mdui:DisplayName[@xml:lang='en'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>mdui:UIInfo with no xml:lang='en' DisplayName</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
