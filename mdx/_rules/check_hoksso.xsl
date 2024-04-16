<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_hoksso.xsl

    Checking ruleset for the SAML V2.0 Holder-of-Key Web Browser SSO
    Profile Version 1.0, which can be found here:

        https://wiki.oasis-open.org/security/SamlHoKWebSSOProfile

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:hoksso="urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Schema checks.

        The schema itself doesn't help very much as most contexts in which the hoksso
        namespace is used are subject to "lax" checking.  These checks duplicate some
        aspects of XML Schema checking as we'd like it to behave.
    -->

    <xsl:template match="hoksso:*">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown element hoksso:</xsl:text>
                <xsl:value-of select="local-name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="@hoksso:*[local-name() != 'ProtocolBinding']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown attribute hoksso:</xsl:text>
                <xsl:value-of select="local-name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        hoksso:ProtocolBinding should only appear on md:SingleSignOnService
        or on md:AssertionConsumerService.
    -->
    <xsl:template match="@hoksso:ProtocolBinding
        [not(parent::md:SingleSignOnService or parent::md:AssertionConsumerService)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>hoksso:ProtocolBinding may not appear on </xsl:text>
                <xsl:value-of select="name(parent::*)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        If hoksso:ProtocolBinding appears, there must be a sibling Binding attribute
        with the appropriate value.
    -->
    <xsl:template match="@hoksso:ProtocolBinding
        [parent::*/@Binding != 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>hoksso:ProtocolBinding requires @Binding of </xsl:text>
                <xsl:text>urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser</xsl:text>
                <xsl:text>, saw </xsl:text>
                <xsl:value-of select="parent::*/@Binding"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        If the HoK SSO @Binding appears, hoksso:ProtocolBinding must appear with one of
        the valid values.
    -->

    <xsl:template match="md:*
        [@Binding = 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']
        [not(@hoksso:ProtocolBinding)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>holder of key SSO @Binding on </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> also requires hoksso:ProtocolBinding</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleSignOnService
        [@Binding = 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']
        [@hoksso:ProtocolBinding]
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>holder of key SSO requires appropriate hoksso:ProtocolBinding</xsl:text>
                <xsl:if test="@hoksso:ProtocolBinding">
                    <xsl:text>, saw </xsl:text>
                    <xsl:value-of select="@hoksso:ProtocolBinding"/>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:AssertionConsumerService
        [@Binding = 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']
        [@hoksso:ProtocolBinding]
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@hoksso:ProtocolBinding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>holder of key SSO requires appropriate hoksso:ProtocolBinding</xsl:text>
                <xsl:if test="@hoksso:ProtocolBinding">
                    <xsl:text>, saw </xsl:text>
                    <xsl:value-of select="@hoksso:ProtocolBinding"/>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Use of SAML 2.0 HoK binding requires SAML 2.0 in protocolSupportEnumeration.
    -->

    <xsl:template match="md:IDPSSODescriptor
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')) and 
        md:*/@Binding = 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>holder of key binding requires SAML 2.0 token in AttributeAuthorityDescriptor/@protocolSupportEnumeration</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SPSSODescriptor
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')) and 
        md:*/@Binding = 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>holder of key binding requires SAML 2.0 token in SPSSODescriptor/@protocolSupportEnumeration</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
