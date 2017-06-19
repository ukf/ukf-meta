<?xml version="1.0" encoding="UTF-8"?>
<!--

    saml2.xsl

    XSL stylesheet that takes a SAML 2.0 metadata file and extracts
    statistics about the level of SAML 2 protocol support within the
    included entities.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="md mdrpi">

    <!-- Output is plain text -->
    <xsl:output method="text"/>

    <xsl:template match="md:EntitiesDescriptor">
        <xsl:variable name="entities" select="//md:EntityDescriptor
        [descendant::mdrpi:RegistrationInfo/@registrationAuthority='http://ukfederation.org.uk']"/>
        <xsl:value-of select="count($entities)"/><xsl:text> </xsl:text>
        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:value-of select="count($idps)"/><xsl:text> </xsl:text>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
        <xsl:value-of select="count($sps)"/><xsl:text> </xsl:text>

        <xsl:variable name="entities.saml2"
            select="$entities[
            md:IDPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')] |
            md:SPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
            ]"/>
        <xsl:value-of select="count($entities.saml2)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="count($entities[
            md:IDPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
            ])"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="count($entities[
            md:SPSSODescriptor[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
            ])"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>
</xsl:stylesheet>
