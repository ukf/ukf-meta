<?xml version="1.0" encoding="UTF-8"?>
<!--

    mdq_validity.xsl

    Operates on an aggregate, propagating the validUntil attribute from the
    EntitiesDescriptor down to each EntityDescriptor.

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="md">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Copy validUntil down from the aggregate.

        Has no effect if the aggregate is not present.
    -->
    <xsl:template match="md:EntitiesDescriptor/md:EntityDescriptor">
        <xsl:copy>
            <xsl:attribute name="validUntil">
                <xsl:value-of select="../@validUntil"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!--By default, copy text blocks, comments and attributes unchanged.-->
    <xsl:template match="text()|comment()|@*">
        <xsl:copy/>
    </xsl:template>

    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
