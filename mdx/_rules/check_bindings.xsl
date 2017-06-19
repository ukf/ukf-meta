<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_bindings.xsl

    Checking ruleset that checks SAML 2.0 metadata Binding values.

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

    <xsl:template match="md:ArtifactResolutionService
        [@Binding != 'urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:AssertionConsumerService
        [@Binding != 'http://schemas.xmlsoap.org/ws/2003/07/secext']
        [@Binding != 'urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']
        [@Binding != 'urn:oasis:names:tc:SAML:1.0:profiles:browser-post']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:PAOS']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:AssertionIDRequestService
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:URI']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:AttributeService
        [@Binding != 'urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:ManageNameIDService
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:NameIDMappingService
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleLogoutService
        [@Binding != 'http://schemas.xmlsoap.org/ws/2003/07/secext']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleSignOnService
        [@Binding != 'urn:mace:shibboleth:1.0:profiles:AuthnRequest']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP']
        [@Binding != 'urn:oasis:names:tc:SAML:2.0:profiles:holder-of-key:SSO:browser']
        [@Binding != 'http://schemas.xmlsoap.org/ws/2003/07/secext']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Issue warnings for all Bindings on elements other than the ones
        called out above, as they may well be accurate but need additional
        checks researched.
    -->
    <xsl:template match="md:*
        [@Binding]
        [local-name() != 'ArtifactResolutionService']
        [local-name() != 'AssertionConsumerService']
        [local-name() != 'AssertionIDRequestService']
        [local-name() != 'AttributeService']
        [local-name() != 'ManageNameIDService']
        [local-name() != 'NameIDMappingService']
        [local-name() != 'SingleLogoutService']
        [local-name() != 'SingleSignOnService']
        ">
        <xsl:call-template name="warning">
            <xsl:with-param name="m">
                <xsl:text>unknown binding '</xsl:text>
                <xsl:value-of select="@Binding"/>
                <xsl:text>' on </xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
