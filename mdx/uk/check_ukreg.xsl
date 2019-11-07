<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_ukreg.xsl

    Checking ruleset containing rules that only apply to metadata registered
    by the UK federation's registrar function.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <!--
        Check for https:// locations that use an explicit but redundant port specifier.
    -->
    <xsl:template match="*[@Location and starts-with(@Location, 'https://')
        and contains(@Location,':443/')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:value-of select='local-name()'/>
                <xsl:text> Location </xsl:text>
                <xsl:value-of select="@Location"/>
                <xsl:text> not in standard form</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
