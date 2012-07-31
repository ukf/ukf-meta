<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    report_owners.xsl
    
    XSL stylesheet taking a metadata aggregate and giving a brief report on the
    entities and their owners (contacts).
    
    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:math="http://exslt.org/math"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    exclude-result-prefixes="xsl md mdui xsi math date dyn set"
    version="1.0">

    <xsl:output method="text" omit-xml-declaration="yes"/>
    
    <xsl:template match="md:EntityDescriptor">
        <xsl:value-of select="@entityID"/>
        <xsl:text>:</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="md:ContactPerson"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="md:ContactPerson">
        <xsl:text>   </xsl:text>
        <xsl:value-of select="@contactType"/>
        <xsl:text>:</xsl:text>
        <xsl:if test="md:GivenName">
            <xsl:text> </xsl:text>
            <xsl:value-of select="md:GivenName"/>
        </xsl:if>
        <xsl:if test="md:SurName">
            <xsl:text> </xsl:text>
            <xsl:value-of select="md:SurName"/>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="md:EmailAddress"/>
    </xsl:template>
    
    <xsl:template match="md:EmailAddress">
        <xsl:if test="
            not(contains(., '@idp.protectnetwork.org')) and
            not(contains(., '@openidp.org'))">
            <xsl:text>      </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()">
        <!-- nothing -->
    </xsl:template>
    
</xsl:stylesheet>
