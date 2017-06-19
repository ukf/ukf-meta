<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_shib_noregscope.xsl

    Check for Shibboleth Scope elements lacking a regexp attribute, which can cause
    problems with signature generation and validation because the schema includes
    a default value.

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

    <xsl:template match="shibmd:Scope[not(@regexp)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Scope <xsl:value-of select="."/> lacks @regexp</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
