<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_entityid_prefix.xsl

    Checking that entityID attributes start with one of a whitelist of prefixes.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        Entity IDs should start with one of "http://", "https://" or "urn:mace:".
    -->
    <xsl:template match="md:EntityDescriptor[
        not(starts-with(@entityID, 'urn:mace:')) and
        not(starts-with(@entityID, 'http://')) and
        not(starts-with(@entityID, 'https://'))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">entity ID <xsl:value-of select="@entityID"/> does not start with acceptable prefix</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
