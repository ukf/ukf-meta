<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_algsupport.xsl

    Checking ruleset for the SAML V2.0 Metadata Profile for Algorithm Support.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        2.3 md:EncryptionMethod should appear only in md:KeyDescriptor elements
        whose @use is omitted or set to "encryption", i.e., not "signing".
    -->
    <xsl:template match="md:EncryptionMethod[../@use='signing']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">EncryptionMethod should not be present on 'signing' KeyDescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for duplicate SigningMethod or DigestMethod algorithms in any given list.
    -->
    <xsl:template match="md:Extensions[alg:*]">

        <!-- check individual alg:SigningMethod and alg:DigestMethod elements -->
        <xsl:apply-templates/>
    </xsl:template>

    <!--
        2.4 Check for misplaced SigningMethod or DigestMethod elements.
    -->
    <xsl:template match="alg:*[count(parent::md:Extensions)=0]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>alg:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text> must only appear within an Extensions element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for duplicate EncryptionMethod elements in any given list.
    -->
    <xsl:template match="md:KeyDescriptor[md:EncryptionMethod]">

        <!-- check individual md:EncryptionMethod elements -->
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
