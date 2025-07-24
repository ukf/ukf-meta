<?xml version="1.0" encoding="UTF-8"?>
<!--

    fix_geolocationHint.xsl

    Remove spaces from the interior of mdui:GeolocationHint values

-->
<xsl:stylesheet version="1.0"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"

                xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="md">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!-- All tabs, newlines and whitespaces are collapsed to single spaces and then all spaces are removed -->
    <xsl:template match="mdui:GeolocationHint">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="translate(normalize-space(.), ' ','')"/>
        </xsl:copy>
    </xsl:template>

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
