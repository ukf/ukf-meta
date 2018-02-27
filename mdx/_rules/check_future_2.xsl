<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_future_2.xsl

    Checking ruleset containing rules that we don't currently implement,
    but which we may implement in the future.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--

        Check whether md:OrganizationDisplayname matches mdui:DisplayName for SPs

        See ukf/ukf-data#325

    -->
    <xsl:template match="md:EntityDescriptor[md:SPSSODescriptor]">
        <xsl:variable name="mdui" select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']"/>
        <xsl:variable name="odn" select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/>
        <xsl:if test="$mdui and $odn and $mdui != $odn">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>mismatched xml:lang='en' DisplayNames: '</xsl:text>
                    <xsl:value-of select="$mdui"/>
                    <xsl:text>' in mdui vs. '</xsl:text>
                    <xsl:value-of select="$odn"/>
                    <xsl:text>' in ODN</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
