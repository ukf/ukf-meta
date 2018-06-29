<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_future_5.xsl

    Checking ruleset containing rules that we don't currently implement,
    but which we may implement in the future.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:mdxURL="xalan://uk.ac.sdss.xalan.md.URLchecker"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:set="http://exslt.org/sets"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:template match="md:IDPSSODescriptor/@errorURL[mdxURL:invalidURL(.)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:value-of select='local-name()'/>
                <xsl:text> '</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>' is not a valid URL: </xsl:text>
                <xsl:value-of select="mdxURL:whyInvalid(.)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
