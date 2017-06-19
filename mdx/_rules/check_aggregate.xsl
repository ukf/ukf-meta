<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_aggregate.xsl

    Checking ruleset containing aggregate-level checks.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:set="http://exslt.org/sets"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:variable name="entities" select="//md:EntityDescriptor"/>
    <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>

    <!--
        Checks across the whole of the document are defined here.
    -->
    <xsl:template match="/">

        <!-- check for duplicate entityID values -->
        <xsl:variable name="distinct.entityIDs" select="set:distinct($entities/@entityID)"/>
        <xsl:variable name="dup.entityIDs"
            select="set:distinct(set:difference($entities/@entityID, $distinct.entityIDs))"/>
        <xsl:for-each select="$dup.entityIDs">
            <xsl:variable name="dup.entityID" select="."/>
            <xsl:for-each select="$entities[@entityID = $dup.entityID]">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">duplicate entityID: <xsl:value-of select='$dup.entityID'/></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
