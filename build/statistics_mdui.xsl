<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    statistics_mdui.xsl
    
    XSL stylesheet taking a metadata aggregate and giving some statistics about MDUI
    element use as textual output.
    
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
    
    <xsl:template match="/md:EntitiesDescriptor">
        
        <xsl:variable name="entities" select="//md:EntityDescriptor"/>
        <xsl:variable name="entityCount" select="count($entities)"/>

        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:variable name="idpCount" select="count($idps)"/>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
        <xsl:variable name="spCount" select="count($sps)"/>
        <xsl:variable name="dualEntities" select="$entities[md:IDPSSODescriptor][md:SPSSODescriptor]"/>
        <xsl:variable name="dualEntityCount" select="count($dualEntities)"/>

        <xsl:text>Total entities: </xsl:text>
        <xsl:value-of select="$entityCount"/>
        <xsl:text>&#10;</xsl:text>

        <xsl:if test="$entityCount > 0">
            <xsl:variable name="uiInfoEntities" select="$entities[descendant::mdui:UIInfo]"/>
            <xsl:variable name="uiInfoEntitiesCount" select="count($uiInfoEntities)"/>
            <xsl:text>   mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$uiInfoEntitiesCount"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($uiInfoEntitiesCount div $entityCount, '0.0%')"/>
            <xsl:text>)&#10;</xsl:text>
        </xsl:if>
        
        <xsl:text>Identity providers: </xsl:text>
        <xsl:value-of select="$idpCount"/>
        <xsl:text>&#10;</xsl:text>

        <xsl:if test="$idpCount > 0">
            <xsl:variable name="idp.uiinfo" select="$idps[descendant::mdui:UIInfo]"/>
            <xsl:variable name="idp.uiinfo.count" select="count($idp.uiinfo)"/>
            <xsl:text>   mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$idp.uiinfo.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($idp.uiinfo.count div $idpCount, '0.0%')"/>
            <xsl:text>)&#10;</xsl:text>
        </xsl:if>

        <xsl:text>Service providers: </xsl:text>
        <xsl:value-of select="$spCount"/>
        <xsl:text>&#10;</xsl:text>
                
        <xsl:if test="$spCount > 0">
            <xsl:variable name="sp.uiinfo" select="$sps[descendant::mdui:UIInfo]"/>
            <xsl:variable name="sp.uiinfo.count" select="count($sp.uiinfo)"/>
            <xsl:text>   mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$sp.uiinfo.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($sp.uiinfo.count div $spCount, '0.0%')"/>
            <xsl:text>)&#10;</xsl:text>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>