<?xml version="1.0" encoding="UTF-8"?>
<!--

    strip-mdui-logo-http.xsl

    Remove mdui:Logo elements whose value starts with http://, as these
    may cause mixed content errors in browser-based discovery interfaces.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="_rules/check_framework.xsl"/>

    <!-- Force UTF-8 encoding for the output. -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!-- Match the pattern we want to remove. -->
    <xsl:template match="mdui:Logo[starts-with(., 'http://')]">
        <xsl:call-template name="warning">
            <xsl:with-param name="m">
                <xsl:text>mdui:Logo from non-TLS location removed: '</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <!-- ... and don't copy the element to the output, so that it is removed ... -->
    </xsl:template>

    <!--By default, copy text blocks, comments and attributes unchanged.-->
    <xsl:template match="text()|comment()|@*">
        <xsl:copy/>
    </xsl:template>

    <!-- Copy all elements from the input to the output, along with their attributes and contents. -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
