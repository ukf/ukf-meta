<?xml version="1.0" encoding="UTF-8"?>
<!--

    extract_embedded.xsl

    XSL stylesheet that takes a SAML 2.0 metadata file and extracts
    all embedded certificates on entities in the form of a series of
    PEM certificate blocks.

    A descriptive comment is added to indicate the entity in question and
    the KeyName used (if any) so that later processing can distinguish.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mdxTextUtils="xalan://uk.ac.sdss.xalan.md.TextUtils">

    <!-- Output is plain text -->
    <xsl:output method="text"/>

    <xsl:template match="md:EntityDescriptor">
        <xsl:variable name="entity" select="."/>
        <xsl:for-each select="descendant::md:KeyDescriptor">
            <xsl:variable name="keydesc" select="."/>
            <xsl:variable name="keyinfo" select="$keydesc/ds:KeyInfo"/>
            <xsl:variable name="keyname" select="$keyinfo/ds:KeyName"/>
            <xsl:variable name="cert" select="$keyinfo/ds:X509Data/ds:X509Certificate"/>
            <xsl:if test="$cert">
                <xsl:text>Entity: </xsl:text>
                <xsl:if test="$entity/@ID">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select='$entity/@ID'/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:value-of select="$entity/@entityID"/>
                <xsl:text> KeyName: </xsl:text>
                <xsl:choose>
                    <xsl:when test="$keyname">
                        <xsl:value-of select="$keyname"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>(none)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#x0a;</xsl:text>
                <xsl:text>-----BEGIN CERTIFICATE-----&#x0a;</xsl:text>
                <xsl:value-of select="mdxTextUtils:wrapBase64($cert)"/>
                <xsl:text>&#x0a;</xsl:text>
                <xsl:text>-----END CERTIFICATE-----&#x0a;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>
</xsl:stylesheet>
