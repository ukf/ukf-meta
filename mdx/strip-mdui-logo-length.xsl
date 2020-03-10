<?xml version="1.0" encoding="UTF-8"?>
<!--

    strip-mdui-logo-length.xsl

    Filters out mdui:Logo elements with lengths longer than a
    provided threshold, and warns that this has been done.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:mdxURL="xalan://uk.ac.sdss.xalan.md.URLchecker"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="_rules/check_framework.xsl"/>

    <!--
        maxLength

        This parameter determines the maximum allowable mdui:Logo length
        before taking action.
    -->
    <xsl:param name="maxLength"/>

    <!-- Force UTF-8 encoding for the output. -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>
    
    <!--
        Match mdui:Logo elements whose string length is greater than the
        threshold value; issue a warning for them.

        Template match expressions can't include parameter references, so
        match all mdui:Logo elements then dig in with a conditional.
    -->
    <xsl:template match="mdui:Logo">
        <xsl:choose>
            <xsl:when test="string-length(.) > $maxLength">
                <xsl:call-template name="warning">
                    <xsl:with-param name="m">
                        <xsl:text>removed mdui:Logo with long contents: </xsl:text>
                        <xsl:value-of select="string-length(.)"/>
                        <xsl:text> > </xsl:text>
                        <xsl:value-of select="$maxLength"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
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
