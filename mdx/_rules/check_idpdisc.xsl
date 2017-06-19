<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_idpdisc.xsl

    Checking ruleset containing rules associated with the SAML IdP Discovery Protocol.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:set="http://exslt.org/sets"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        "index" attributes on DiscoveryResponse elements should all be different
        for any given entity.
    -->

    <xsl:template match="md:EntityDescriptor[descendant::idpdisc:DiscoveryResponse]">
        <xsl:variable name="indices" select="descendant::idpdisc:DiscoveryResponse/@index"/>
        <xsl:variable name="distinct.indices" select="set:distinct($indices)"/>
        <xsl:if test="count($indices) != count($distinct.indices)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">DiscoveryResponse index values not all different</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <!-- check individual DiscoveryResponse elements for correctness as well -->
        <xsl:apply-templates/>
    </xsl:template>

    <!--
        Checks on the DiscoveryResponse extension.
    -->

    <xsl:template match="idpdisc:DiscoveryResponse[not(@index)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">missing index attribute on DiscoveryResponse</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="idpdisc:DiscoveryResponse[not(@Binding)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">missing Binding attribute on DiscoveryResponse</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="idpdisc:DiscoveryResponse[@Binding]
        [@Binding!='urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">incorrect Binding value on DiscoveryResponse</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
