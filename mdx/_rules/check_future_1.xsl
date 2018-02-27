<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_future_1.xsl

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

        It does not make sense for an IdP to have more than one SingleLogoutService
        with any of a list of SAML 2.0 front-channel bindings.

        See ukf/ukf-meta#155

    -->
    <xsl:template match="md:SingleLogoutService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleLogoutService with SAML 2.0 HTTP-POST binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleLogoutService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleLogoutService with SAML 2.0 HTTP-POST-SimpleSign binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleLogoutService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleLogoutService with SAML 2.0 HTTP-Redirect binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
