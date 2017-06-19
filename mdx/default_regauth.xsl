<?xml version="1.0" encoding="UTF-8"?>
<!--

    default_regauth.xsl

    Apply a default registrationAuthority to entities which don't have one already.

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        defaultAuthority

        Set this parameter from the calling context.
    -->
    <xsl:param name="defaultAuthority">(value not set)</xsl:param>

    <!--
        EntityDescriptor with no Extensions doesn't have a RegistrationInfo,
        by definition.
    -->
    <xsl:template match="md:EntityDescriptor[not(md:Extensions)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>    </xsl:text>
            <xsl:element name="Extensions" namespace="urn:oasis:names:tc:SAML:2.0:metadata">
                <xsl:call-template name="default_regauth"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    </xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!--
        EntityDescriptor with Extensions but without RegistrationInfo needs to have one
        injected into the existing Extensions.
    -->
    <xsl:template match="md:EntityDescriptor/md:Extensions[not(mdrpi:RegistrationInfo)]">
        <xsl:copy>
            <xsl:call-template name="default_regauth"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!--
        Default RegistrationInfo element, with associated white space.
    -->
    <xsl:template name="default_regauth">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>        </xsl:text>
        <xsl:element name="mdrpi:RegistrationInfo">
            <xsl:attribute name="registrationAuthority">
                <xsl:value-of select="$defaultAuthority"/>
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
