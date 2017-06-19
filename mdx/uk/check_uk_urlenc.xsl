<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_urlenc.xsl

    UKf-specific check for endpoint locations that include a '%' character,
    which is symptomatic of their being URL-encoded instead of entity-encoded.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <xsl:template match="@Location[contains(., '%')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">URL-encoded Location attribute; should be entity-encoded</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
