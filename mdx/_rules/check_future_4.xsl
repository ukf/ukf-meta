<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_future_4.xsl

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
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--

        If an entity has algorithmic agility metadata, check whether it has the algorithms
        which are listed in the 2018 SAML V2.0 Interoperability Deployment Profile

        See section 3.3 of https://kantarainitiative.github.io/SAMLprofiles/saml2int.html
        and ukf/ukf-meta#157

    -->
    <xsl:template match="md:KeyDescriptor[count(md:EncryptionMethod) > 0]">

        <xsl:variable name="gcm"
            select="md:EncryptionMethod[
            @Algorithm='http://www.w3.org/2009/xmlenc11#aes128-gcm' or
            @Algorithm='http://www.w3.org/2009/xmlenc11#aes192-gcm' or
            @Algorithm='http://www.w3.org/2009/xmlenc11#aes256-gcm'
            ]"/>

        <xsl:variable name="keytransport"
            select="md:EncryptionMethod[
            @Algorithm='http://www.w3.org/2009/xmlenc11#rsa-oaep' or
            @Algorithm='http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p'
            ]"/>

        <xsl:if test="count($gcm) = 0">
            <xsl:call-template name="warning">
                <xsl:with-param name="m">Does not contain a GCM EncryptionMethod specified in new saml2int</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="count($keytransport) = 0">
            <xsl:call-template name="warning">
                <xsl:with-param name="m">Does not contain a Key Transport EncryptionMethod specified in new saml2int</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template match="md:Extensions
        [
        count(alg:DigestMethod) > 0 or
        count(alg:SigningMethod) > 0
        ]">

        <xsl:variable name="signing"
            select="alg:SigningMethod[
            @Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha256' or
            @Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256'
            ]"/>

        <xsl:variable name="digest"
            select="alg:DigestMethod[
            @Algorithm='http://www.w3.org/2001/04/xmlenc#sha256'
            ]"/>

        <xsl:if test="count($signing) = 0">
            <xsl:call-template name="warning">
                <xsl:with-param name="m">Does not contain a SigningMethod specified in new saml2int</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="count($digest) = 0">
            <xsl:call-template name="warning">
                <xsl:with-param name="m">Does not contain a DigestMethod specified in new saml2int</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
