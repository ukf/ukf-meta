<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_extensions.xsl

    UKf-specific check for supported elements in Extensions elements.
-->
<xsl:stylesheet version="1.0"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>

    <!--
        The default is to treat all children of an md:Extensions element
        in any location as an error.

        This template matches *all* extension elements. It will be overridden
        by matches for specific whitelisted extension elements at a
        *higher priority*. It is an error for a node to match two templates
        with the same priority, so we set the priority of this rule to -1.
    -->
    <xsl:template match="md:Extensions/*" priority="-1">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>Unsupported extension element </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> within </xsl:text>
                <xsl:value-of select="name(../..)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Note: Algorithm Support metadata.

        The SAML v2.0 Metadata Profile for Algorithm Support Version 1.0
        specification allows the algorithm support metadata elements
        (alg:DigestMethod and alg:SigningMethod) to appear either in the
        md:EntityDescriptor's md:Extensions, or within the md:Extensions of
        any role descriptor (e.g., md:SPSSODescriptor, md:IDPSSODescriptor).

        The rule here, applied only to UK federation registrations, is more
        strict in that these elements are only permitted within the
        md:Extensions of an md:EntityDescriptor element. We have only ever seen
        one exception to this stricter rule, and that was a result of a
        registration mistake. We think it's therefore worth being less
        permissive than the specification allows in this case.

        See ukf/ukf-meta#180.
    -->

    <!--
        Permitted extensions within md:EntityDescriptor.
    -->
    <xsl:template match="md:EntityDescriptor/md:Extensions/alg:DigestMethod"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/alg:SigningMethod"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/mdattr:EntityAttributes"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/mdrpi:RegistrationInfo"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/shibmd:Scope"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:AccountableUsers"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:DisableFlow"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:EnableFlow"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:ExportOptIn"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:ExportOptOut"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:Software"/>
    <xsl:template match="md:EntityDescriptor/md:Extensions/ukfedlabel:UKFederationMember"/>

    <!--
        Permitted extensions within md:AttributeAuthorityDescriptor.
    -->
    <xsl:template match="md:AttributeAuthorityDescriptor/md:Extensions/shibmd:Scope"/>

    <!--
        Permitted extensions within md:IDPSSODescriptor.
    -->
    <xsl:template match="md:IDPSSODescriptor/md:Extensions/mdui:DiscoHints"/>
    <xsl:template match="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo"/>
    <xsl:template match="md:IDPSSODescriptor/md:Extensions/shibmd:Scope"/>

    <!--
        Permitted extensions within md:SPSSODescriptor.
    -->
    <xsl:template match="md:SPSSODescriptor/md:Extensions/idpdisc:DiscoveryResponse"/>
    <xsl:template match="md:SPSSODescriptor/md:Extensions/init:RequestInitiator"/>
    <xsl:template match="md:SPSSODescriptor/md:Extensions/mdui:UIInfo"/>

</xsl:stylesheet>
