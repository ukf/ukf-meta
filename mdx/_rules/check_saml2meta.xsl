<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_saml2meta.xsl

    Checking ruleset encapsulating rules from the SAML 2.0 metadata specification that
    are not completely encoded in the XML schema.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        Check for distinct index attributes on appropriate elements.
    -->

    <xsl:template match="md:SPSSODescriptor">

        <xsl:variable name="indices" select="md:ArtifactResolutionService/@index"/>
        <xsl:variable name="distinct.indices" select="set:distinct($indices)"/>
        <xsl:if test="count($indices) != count($distinct.indices)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">ArtifactResolutionService index values not all different</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:variable name="indices2" select="md:AssertionConsumerService/@index"/>
        <xsl:variable name="distinct.indices2" select="set:distinct($indices2)"/>
        <xsl:if test="count($indices2) != count($distinct.indices2)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">AssertionConsumerService index values not all different</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!--
            Perform checks on child elements.
        -->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="md:IDPSSODescriptor">
        <xsl:variable name="indices" select="md:ArtifactResolutionService/@index"/>
        <xsl:variable name="distinct.indices" select="set:distinct($indices)"/>
        <xsl:if test="count($indices) != count($distinct.indices)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">ArtifactResolutionService index values not all different</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!--
            Perform checks on child elements.
        -->
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
