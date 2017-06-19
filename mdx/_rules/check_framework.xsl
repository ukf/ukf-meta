<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_framework.xsl

    XSL stylesheet providing a framework for use by rule checking files.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <!--
        The stylesheet output will be a text file, which will probably be thrown
        away in any case.  The real output from the check is sent using the
        xsl:message element.
    -->
    <xsl:output method="text"/>


    <!--
        Common template to call to report an error on some element within an entity.
    -->
    <xsl:template name="error">
        <xsl:param name="m"/>
        <xsl:variable name="entity" select="ancestor-or-self::md:EntityDescriptor"/>
        <xsl:message terminate='no'>
            <xsl:text>[ERROR] </xsl:text>
            <!--
                If we're processing an aggregate, we need to indicate which
                individual entity we're dealing with.
            -->
            <xsl:if test="ancestor-or-self::md:EntitiesDescriptor">
                <!--
                    Use an ID if available, otherwise the entityID.
                -->
                <xsl:choose>
                    <xsl:when test="$entity/@ID">
                        <xsl:value-of select="$entity/@ID"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$entity/@entityID"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:value-of select="$m"/>
        </xsl:message>
    </xsl:template>


    <!--
        Common template to call to report a warning on some element within an entity.
    -->
    <xsl:template name="warning">
        <xsl:param name="m"/>
        <xsl:variable name="entity" select="ancestor-or-self::md:EntityDescriptor"/>
        <xsl:message terminate='no'>
            <xsl:text>[WARN] </xsl:text>
            <!--
                If we're processing an aggregate, we need to indicate which
                individual entity we're dealing with.
            -->
            <xsl:if test="ancestor-or-self::md:EntitiesDescriptor">
                <!--
                    Use an ID if available, otherwise the entityID.
                -->
                <xsl:choose>
                    <xsl:when test="$entity/@ID">
                        <xsl:value-of select="$entity/@ID"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$entity/@entityID"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:value-of select="$m"/>
        </xsl:message>
    </xsl:template>


    <!--
        Common template to call to report an informational message on some element within an entity.
    -->
    <xsl:template name="info">
        <xsl:param name="m"/>
        <xsl:variable name="entity" select="ancestor-or-self::md:EntityDescriptor"/>
        <xsl:message terminate='no'>
            <xsl:text>[INFO] </xsl:text>
            <!--
                If we're processing an aggregate, we need to indicate which
                individual entity we're dealing with.
            -->
            <xsl:if test="ancestor-or-self::md:EntitiesDescriptor">
                <!--
                    Use an ID if available, otherwise the entityID.
                -->
                <xsl:choose>
                    <xsl:when test="$entity/@ID">
                        <xsl:value-of select="$entity/@ID"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$entity/@entityID"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:value-of select="$m"/>
        </xsl:message>
    </xsl:template>


    <!-- Recurse down through all elements by default. -->
    <xsl:template match="*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>


    <!-- Discard text blocks, comments and attributes by default. -->
    <xsl:template match="text()|comment()|@*">
        <!-- do nothing -->
    </xsl:template>

</xsl:stylesheet>
