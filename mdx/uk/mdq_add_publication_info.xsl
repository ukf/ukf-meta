<?xml version="1.0" encoding="UTF-8"?>
<!--

    mda_add_publication_info.xsl

    Operates on an aggregate, propagating the PublicationInfo from the
    EntitiesDescriptor down to each EntityDescriptor.

-->
<xsl:stylesheet version="1.0"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"

                xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="md">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        publisher

        This parameter, if present, prompts the generation of a PublicationInfo
        element on the EntitiesDescriptor.
    -->
    <xsl:param name="publisher"/>

    <!--
        now_ISO

        This parameter is an ISO8601 representation of the UTC instant
        at which the aggregate generation started.

        Example: 2019-10-23T10:25:11Z
    -->
    <xsl:param name="now_ISO"/>

    <!--
        Find the correct place to add PublicationInfo
    -->
    <xsl:template match="md:EntitiesDescriptor/md:EntityDescriptor/md:Extensions">
        <xsl:copy>
            <xsl:if test="$publisher">
                <xsl:call-template name="generate.publicationInfo"/>
            </xsl:if>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>


    <!--
        PublicationInfo generation.

        Assumption: called at the start of the document element's Extensions, at 4-space
        indentation, so the element itself requires 8-space indentation.
    -->
    <xsl:template name="generate.publicationInfo">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>        </xsl:text>
        <xsl:element name="mdrpi:PublicationInfo">
            <xsl:attribute name="publisher">
                <xsl:value-of select="$publisher"/>
            </xsl:attribute>
            <xsl:attribute name="creationInstant">
                <xsl:value-of select="$now_ISO"/>
            </xsl:attribute>
        </xsl:element>
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
