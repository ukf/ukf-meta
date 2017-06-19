<?xml version="1.0" encoding="UTF-8"?>
<!--

    fragment.xsl

    XSL stylesheet to perform any required clean-up on a UK federation fragment file
    before it is passed along to other processes.

-->
<xsl:stylesheet version="1.0"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsi xsl">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>


    <!--
        Remove any xsi:schemaLocation attributes.
    -->
    <xsl:template match="@xsi:schemaLocation"/>


    <!--
        Discard various ds:X509 elements.  Several of these are known to
        cause problems with software systems, and they don't affect trust
        establishment so are safe to remove.
    -->
    <xsl:template match="ds:X509SerialNumber"/><!-- libxml2 has problems with long ones -->
    <xsl:template match="ds:X509IssuerSerial"/><!-- must remove this if we remove SerialNumber -->


    <!--
        Retain only certain comments.
    -->

    <xsl:template match="md:EntityDescriptor/comment()">
        <xsl:copy/>
    </xsl:template>

    <!--
        All other comments are stripped by the default templates.
    -->


    <!--
        *********************************************
        ***                                       ***
        ***   D E F A U L T   T E M P L A T E S   ***
        ***                                       ***
        *********************************************
    -->


    <!--By default, copy text blocks and attributes unchanged.-->
    <xsl:template match="text()|@*">
        <xsl:copy/>
    </xsl:template>

    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
