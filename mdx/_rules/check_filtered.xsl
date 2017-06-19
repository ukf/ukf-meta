<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_filtered.xsl

    This checking ruleset verifies that certain constructs have been removed from the
    metadata before it is published.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <xsl:template match="ds:X509SerialNumber">
        <xsl:call-template name="error">
            <xsl:with-param name="m">ds:X509SerialNumber should have been filtered out</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
