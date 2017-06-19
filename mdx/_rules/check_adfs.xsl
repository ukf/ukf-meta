<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_adfs.xsl

    Checking ruleset containing rules associated with the ADFS metadata profile,
    as described here:

        https://spaces.internet2.edu/display/SHIB/ADFSMetadataProfile

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        An IdP's SSO descriptor must contain a SingleSignOn element with
        the appropriate binding.
    -->
    <xsl:template match="md:IDPSSODescriptor
        [contains(@protocolSupportEnumeration, 'http://schemas.xmlsoap.org/ws/2003/07/secext')]
        [not(md:SingleSignOnService/@Binding = 'http://schemas.xmlsoap.org/ws/2003/07/secext')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ADFS IdP role lacks SSO service with appropriate Binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        An SP's SSO descriptor must contain an AssertionConsumerService element with
        the appropriate binding.
    -->
    <xsl:template match="md:SPSSODescriptor
        [contains(@protocolSupportEnumeration, 'http://schemas.xmlsoap.org/ws/2003/07/secext')]
        [not(md:AssertionConsumerService/@Binding = 'http://schemas.xmlsoap.org/ws/2003/07/secext')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ADFS SP role lacks SSO service with appropriate Binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        If the ADFS binding appears on any service, the parent role's protocol support
        enumeration must include the appropruate URI.
    -->
    <xsl:template match="md:SingleSignOnService
        [@Binding='http://schemas.xmlsoap.org/ws/2003/07/secext']
        [not(contains(../@protocolSupportEnumeration, 'http://schemas.xmlsoap.org/ws/2003/07/secext'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ADFS SingleSignOnService requires appropriate protocolSupportEnumeration</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:AssertionConsumerService
        [@Binding='http://schemas.xmlsoap.org/ws/2003/07/secext']
        [not(contains(../@protocolSupportEnumeration, 'http://schemas.xmlsoap.org/ws/2003/07/secext'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ADFS AssertionConsumerService requires appropriate protocolSupportEnumeration</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleLogoutService
        [@Binding='http://schemas.xmlsoap.org/ws/2003/07/secext']
        [not(contains(../@protocolSupportEnumeration, 'http://schemas.xmlsoap.org/ws/2003/07/secext'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ADFS SingleLogoutService requires appropriate protocolSupportEnumeration</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
