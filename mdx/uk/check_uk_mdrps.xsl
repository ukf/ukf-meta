<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_mdrps.xsl

    UKf-specific check for appropriate RegistrationPolicy values.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <!--
        If a UK-registered entity is opted in to the export aggregate, it MUST
        have a registrationInstant.
    -->
    <xsl:template match="md:EntityDescriptor
        [descendant::mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']]
        [md:Extensions/ukfedlabel:ExportOptIn]
        [not(descendant::mdrpi:RegistrationInfo/@registrationInstant)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>exported entity lacks a registrationInstant value</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Restrict registrationAuthority values for UK federation entities, if present,
        to previously used MDRPS document URLs.
    -->
    <xsl:template match="mdrpi:RegistrationInfo[@registrationAuthority='http://ukfederation.org.uk']
        /mdrpi:RegistrationPolicy
            [.!='http://ukfederation.org.uk/doc/mdrps-20130902']
        ">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>invalid RegistrationPolicy value </xsl:text>
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
