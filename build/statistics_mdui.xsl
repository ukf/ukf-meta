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
        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>

        <xsl:call-template name="entities.category">
            <xsl:with-param name="category">Total entities</xsl:with-param>
            <xsl:with-param name="entities" select="$entities"/>
        </xsl:call-template>
        
        <xsl:call-template name="entities.category">
            <xsl:with-param name="category">Identity providers</xsl:with-param>
            <xsl:with-param name="entities" select="$idps"/>
        </xsl:call-template>
        
        <xsl:call-template name="entities.category">
            <xsl:with-param name="category">Service providers</xsl:with-param>
            <xsl:with-param name="entities" select="$sps"/>
        </xsl:call-template>
        
    </xsl:template>

    <xsl:template name="entities.category">
        <xsl:param name="entities"/>
        <xsl:param name="category"/>
        <xsl:variable name="entities.count" select="count($entities)"/>
        
        <xsl:value-of select="$category"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="$entities.count"/>
        <xsl:text>&#10;</xsl:text>
        
        <xsl:if test="$entities.count > 0">
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:UIInfo</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:UIInfo]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:Logo</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:Logo]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:Description</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:Description]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:DisplayName</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:DisplayName]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:Keywords</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:Keywords]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:InformationURL</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:InformationURL]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:PrivacyStatementURL</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:PrivacyStatementURL]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
                        
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:DiscoHints</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:DiscoHints]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:IPHint</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:IPHint]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:DomainHint</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:DomainHint]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
            <xsl:call-template name="mdui.element">
                <xsl:with-param name="element">mdui:GeolocationHint</xsl:with-param>
                <xsl:with-param name="has" select="$entities[descendant::mdui:GeolocationHint]"/>
                <xsl:with-param name="total.count" select="$entities.count"/>
            </xsl:call-template>
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="mdui.element">
        <xsl:param name="element"/>
        <xsl:param name="has"/>
        <xsl:param name="total.count"/>
        <xsl:variable name="has.count" select="count($has)"/>
        <xsl:if test="$has.count > 0">
            <xsl:text>   </xsl:text>
            <xsl:value-of select="$element"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$has.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($has.count div $total.count, '0.0%')"/>
            <xsl:text>)&#10;</xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
