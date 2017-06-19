<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_shib_regscope.xsl

    Check for the presence of Shibboleth Scope elements containing regular expressions.

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:template match="shibmd:Scope[@regexp='true']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>regular expression in scope '</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
