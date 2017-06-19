<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_vhosts.xsl

    Checking ruleset that makes sure that an IdP's SSO endpoints and SOAP
    endpoints are on distinct virtual host.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:dyn="http://exslt.org/dynamic"
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
        Check IdPs only.
    -->
    <xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor]">
        <!--
            Look for IdPs which have either attribute authority or artifact resolution locations
            on the same host:port combination as any of the SSO locations.
        -->

        <!-- XPath expression to evaluate to extract host:port strings from locations -->
        <xsl:variable name="extract">substring-before(substring-after(concat(., '/'), 'https://'), '/')</xsl:variable>

        <!-- Collect all of the SSO locations -->
        <xsl:variable name="ssoLocations" select="descendant::md:SingleSignOnService/@Location"/>
        <!-- convert to set of unique host:port strings -->
        <xsl:variable name="ssoHosts" select="set:distinct(dyn:map($ssoLocations, $extract))"/>

        <!-- Collect all of the attribute authority and artifact resolution locations -->
        <xsl:variable name="soapLocations"
            select="descendant::md:AttributeService/@Location |
            descendant::md:ArtifactResolutionService/@Location"/>
        <!-- convert to set of unique host:port strings -->
        <xsl:variable name="soapHosts" select="set:distinct(dyn:map($soapLocations, $extract))"/>

        <!-- we expect these two sets to be disjoint -->
        <xsl:variable name="bothHosts" select="set:distinct($ssoHosts | $soapHosts)"/>
        <xsl:if test="count($bothHosts) != count($ssoHosts) + count($soapHosts)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">at least one SOAP location on same vhost as an SSO location</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
