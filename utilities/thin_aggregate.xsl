<?xml version="1.0" encoding="UTF-8"?>
<!--
    thin_aggregate.xsl

    Thins the input aggregate so that only 1% of the entities remain.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:math="http://exslt.org/math">

    <!--
        Force UTF-8 encoding for the output.
    -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>

    <!-- Discard most entities. -->
    <xsl:template match="md:EntityDescriptor[math:random()>0.01]">
        <!-- discard -->
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
