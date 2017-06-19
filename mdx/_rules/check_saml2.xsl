<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_saml2.xsl

    Checking ruleset containing rules associated with the SAML 2.0 specification.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        It does not make sense for an IdP to have more than one SingleSignOnService
        with any of a list of SAML 2.0 front-channel bindings.
    -->
    <xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-POST binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-POST-SimpleSign binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleSignOnService with SAML 2.0 HTTP-Redirect binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        A SAML 2.0 IdP with an AttributeAuthority needs an AttributeService with an appropriate Binding.
    -->
    <xsl:template match="md:AttributeAuthorityDescriptor
        [contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
        [not(md:AttributeService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:SOAP'])]
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">SAML 2.0 AttributeAuthority missing appropriately bound AttributeService</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Check for SAML 2.0 SPs which lack an encryption key.
    -->
    <xsl:template match="md:SPSSODescriptor
        [contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
        [not(md:KeyDescriptor[descendant::ds:X509Data][@use='encryption'])]
        [not(md:KeyDescriptor[descendant::ds:X509Data][not(@use)])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">SAML 2.0 SP has no encryption key</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Use of SAML 2.0 bindings requires SAML 2.0 in protocolSupportEnumeration.
    -->
    <xsl:template match="md:IDPSSODescriptor
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol'))]
        [md:*/@Binding[starts-with(., 'urn:oasis:names:tc:SAML:2.0:bindings:')]]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SAML 2.0 binding requires SAML 2.0 token in IDPSSODescriptor/@protocolSupportEnumeration</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Use of SAML 2.0 bindings requires SAML 2.0 in protocolSupportEnumeration.
    -->
    <xsl:template match="md:AttributeAuthorityDescriptor
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol'))]
        [md:*/@Binding[starts-with(., 'urn:oasis:names:tc:SAML:2.0:bindings:')]]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SAML 2.0 binding requires SAML 2.0 token in AttributeAuthorityDescriptor/@protocolSupportEnumeration</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Use of SAML 2.0 bindings requires SAML 2.0 in protocolSupportEnumeration.
    -->
    <xsl:template match="md:SPSSODescriptor
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol'))]
        [md:*/@Binding[starts-with(., 'urn:oasis:names:tc:SAML:2.0:bindings:')]]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SAML 2.0 binding requires SAML 2.0 token in SPSSODescriptor/@protocolSupportEnumeration</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
