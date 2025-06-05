<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_mdui.xsl

    UKf-specific check for mdui in Extensions elements.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <xsl:template match="md:Extensions/mdui:UIInfo[not(mdui:DisplayName)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">mdui has UIInfo without DisplayName</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
