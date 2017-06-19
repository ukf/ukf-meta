<?xml version="1.0" encoding="UTF-8"?>
<!--

    extract_locs.xsl

    XSL stylesheet that takes a SAML 2.0 metadata file and extracts
    a list of service locations that will have TLS certificates.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="md ds">

    <!-- Output is plain text -->
    <xsl:output method="text"/>

    <xsl:template match="//md:AttributeService">
        <xsl:value-of select="@Location"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>

    <xsl:template match="//md:ArtifactResolutionService">
        <xsl:value-of select="@Location"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>

    <xsl:template match="//md:SingleSignOnService">
        <xsl:value-of select="@Location"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>

    <xsl:template match="//md:AssertionConsumerService">
        <xsl:value-of select="@Location"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>
</xsl:stylesheet>
