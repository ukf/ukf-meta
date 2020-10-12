<?xml version="1.0" encoding="UTF-8"?>
<!--

    Checking ruleset for elements with duplicate xml:lang

    Originally reported in https://issues.shibboleth.net/jira/browse/IDP-1647
    "Error with duplicate <ServiceDescription> with same xml:lang in the metadata"

    This set of checks is for all appropriate elements in the namespace
    urn:oasis:names:tc:SAML:2.0:metadata

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Check for uniqueness within an AttributeConsumingService element
    -->
    <xsl:template match="md:AttributeConsumingService">
        <!-- unique xml:lang over ServiceName elements -->
        <xsl:call-template name="uniqueLang">
            <xsl:with-param name="e" select="md:ServiceName"/>
        </xsl:call-template>

        <!-- unique xml:lang over ServiceDescription elements -->
        <xsl:call-template name="uniqueLang">
            <xsl:with-param name="e" select="md:ServiceDescription"/>
        </xsl:call-template>

        <!-- handle individual elements -->
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!--
        Check for uniqueness within an Organization element
    -->
    <xsl:template match="md:Organization">
        <!-- unique xml:lang over OrganizationName elements -->
        <xsl:call-template name="uniqueLang">
            <xsl:with-param name="e" select="md:OrganizationName"/>
        </xsl:call-template>

        <!-- unique xml:lang over OrganizationDisplayName elements -->
        <xsl:call-template name="uniqueLang">
            <xsl:with-param name="e" select="md:OrganizationDisplayName"/>
        </xsl:call-template>

        <!-- handle individual elements -->
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template name="uniqueLang">
        <xsl:param name="e"/>
        <xsl:variable name="l" select="$e/@xml:lang"></xsl:variable>
        <xsl:variable name="u" select="set:distinct($l)"/>
        <xsl:if test="count($l) != count($u)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>non-unique lang values on </xsl:text>
                    <xsl:value-of select="name($e)"/>
                    <xsl:text> elements</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
