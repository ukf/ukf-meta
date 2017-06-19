<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_shibboleth.xsl

    Checking ruleset containing rules associated with:

    * the Shibboleth profile specifications

    * known problems with Shibboleth implementations

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        OrganizationURL elements should contain actual URLs, or some software
        will reject the metadata.  This is known to be true for at least the Shibboleth
        1.3 IdP and the accompanying metadatatool application, because they pass the
        string to the java.net.URL class.

        We perform a very cursory test for this by insisting that they start with
        either "http://" or "https://".
    -->
    <xsl:template match="md:OrganizationURL[not(starts-with(., 'http://'))]
        [not(starts-with(., 'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">OrganizationURL '<xsl:value-of select="."/>' does not start with acceptable prefix</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        If an IDPSSODescriptor contains a SingleSignOnService with the Shibboleth 1.x
        authentication request binding, the role descriptor's protocolSupportEnumeration
        must include both of the following:

            urn:oasis:names:tc:SAML:1.1:protocol
            urn:mace:shibboleth:1.0

        See the Shibboleth Protocols and Profiles document, section 3.4.3, for details.
    -->
    <xsl:template match="md:IDPSSODescriptor[md:SingleSignOnService[@Binding='urn:mace:shibboleth:1.0:profiles:AuthnRequest']]
        [not(contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Shibboleth 1.x auth request needs urn:oasis:names:tc:SAML:1.1:protocol in IDPSSODescriptor/@protocolSupportEnumeration</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:IDPSSODescriptor[md:SingleSignOnService[@Binding='urn:mace:shibboleth:1.0:profiles:AuthnRequest']]
        [not(contains(@protocolSupportEnumeration, 'urn:mace:shibboleth:1.0'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Shibboleth 1.x auth request needs urn:mace:shibboleth:1.0 in IDPSSODescriptor/@protocolSupportEnumeration</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        If an IDPSSODescriptor indicates support for Shibboleth by including
        urn:mace:shibboleth:1.0 in its protocolSupportEnumeration, it must contain at
        least one appropriate SingleSignOnService.

        This is theoretically too severe, as in principle additional profiles could be invented
        in the future which exist in the same protocolSupportEnumeration "family".  However,
        at present there are no such uses of the value, so we can be more restrictive.
    -->
    <xsl:template match="md:IDPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:mace:shibboleth:1.0')]
        [not(md:SingleSignOnService[@Binding='urn:mace:shibboleth:1.0:profiles:AuthnRequest'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Shibboleth 1.x support claimed but no appropriate SSO service binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        It does not make sense for an IdP to have more than one SingleSignOnService
        with the Shibboleth authentication request binding, because this is a
        front-channel binding.
    -->
    <xsl:template match="md:SingleSignOnService[@Binding='urn:mace:shibboleth:1.0:profiles:AuthnRequest'][position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one SingleSignOnService with Shibboleth binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Check for SAML 1.1 SPs which exclude the Shibboleth transient name identifier format.

        An SP which has no NameIDFormat elements is fine, but if any are mentioned in a
        SAML 1.1 SP then the Shibboleth transient must be included in the list as otherwise
        there will be no name identifier sent to the SP and no attribute query can be
        performed.
    -->
    <xsl:template match="md:SPSSODescriptor
        [contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol')]
        [md:NameIDFormat]
        [not(md:NameIDFormat[.='urn:mace:shibboleth:1.0:nameIdentifier'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">SAML 1.1 SP excludes Shibboleth transient name identifier format</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Check for a construct which is known to cause the Shibboleth 1.3 SP to dump core.

            <md:KeyDescriptor use="signing">
                <ds:KeyInfo>
                    <KeyName>blabla<KeyName>
                </ds:KeyInfo>
            </md:KeyDescriptor>

        The issue here is that the KeyName does not have the ds: namespace.
    -->
    <xsl:template match="ds:KeyInfo/*[namespace-uri() != 'http://www.w3.org/2000/09/xmldsig#']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ds:KeyInfo child element not in ds namespace</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Check for IDP role descriptors containing (at any level of nesting)
        SAML 2.0 attribute elements that do not include a NameFormat XML attribute.

        This combination causes the Shibboleth 1.3 and related code (such as metadatatool)
        to reject the metadata.

        See https://bugs.internet2.edu/jira/browse/SIDPO-34
    -->
    <xsl:template match="md:IDPSSODescriptor[descendant::saml:Attribute[not(@NameFormat)]]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">SIDPO-34: Attribute lacking NameFormat in IDPSSODescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Scope elements should not contain space characters.

        This isn't part of the specification, but is assumed by some software.
    -->
    <xsl:template match="shibmd:Scope[contains(., ' ')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Scope value contains space character</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Scope elements should not contain line breaks.

        This isn't part of the specification, but is assumed by some software,
        including the Shibboleth 2.4.3 SP.
    -->
    <xsl:template match="shibmd:Scope[contains(., '&#10;')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Scope value contains line break</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        The Shibboleth 1.3f SP, probably along with other software, has
        problems with comments inside certificate representations.
    -->
    <xsl:template match="ds:X509Certificate[comment()]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">X509Certificate contains XML comment</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
