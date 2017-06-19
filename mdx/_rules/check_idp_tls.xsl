<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_idp_tls.xsl

    Checking that all IdP endpoints are TLS-protected.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        Check for IdP endpoints that don't start with https://
    -->
    <xsl:template match="md:IDPSSODescriptor//*[@Location and not(starts-with(@Location,'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m"><xsl:value-of select='local-name()'/> Location does not start with https://</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:IDPSSODescriptor//*[@ResponseLocation and not(starts-with(@ResponseLocation,'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m"><xsl:value-of select='local-name()'/> ResponseLocation does not start with https://</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:AttributeAuthorityDescriptor//*[@Location and not(starts-with(@Location,'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m"><xsl:value-of select='local-name()'/> Location does not start with https://</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:AttributeAuthorityDescriptor//*[@ResponseLocation and not(starts-with(@ResponseLocation,'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m"><xsl:value-of select='local-name()'/> ResponseLocation does not start with https://</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
