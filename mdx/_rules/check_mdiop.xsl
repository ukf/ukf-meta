<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdiop.xsl

    Checking ruleset containing rules associated with the SAML V2.0 Metadata
    Interoperability Profile, see:

        http://wiki.oasis-open.org/security/SAML2MetadataIOP

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Section 2.5.1: at least one representation must appear.
    -->
    <xsl:template match="md:KeyDescriptor
        [not((ds:KeyInfo/ds:KeyValue) or (ds:KeyInfo/ds:X509Data/ds:X509Certificate))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">KeyDescriptor does not contain a key representation</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.5.1: only one X.509 certificate may appear in any KeyDescriptor.
    -->
    <xsl:template match="md:KeyDescriptor[count(ds:KeyInfo/ds:X509Data/ds:X509Certificate)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">KeyDescriptor contains more than one X509Certificate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
