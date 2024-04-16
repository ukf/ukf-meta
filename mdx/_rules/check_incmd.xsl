<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_incmd.xsl

    Checking ruleset for the InCommon Federation metadata extensions,
    the schema for which can be found here:

        https://spaces.internet2.edu/x/iIuVAQ

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:incmd="http://id.incommon.org/metadata"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Checks for the contactType attribute.
    -->

    <xsl:template match="@incmd:contactType[not(parent::md:ContactPerson)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">incmd:contactType should only appear on md:ContactPerson</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:ContactPerson[@incmd:contactType][@contactType != 'other']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>incmd:contactType requires contactType='other', found '</xsl:text>
                <xsl:value-of select="@contactType"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template priority="2" match="@incmd:contactType[not((starts-with(.,'http://')) or (starts-with(.,'https://')))]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">incmd:contactType must be an absolute URI</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for specific values.  This test is probably over-specific in the long term.
    -->
    <xsl:template priority="1" match="@incmd:contactType
        [not(. = 'http://id.incommon.org/metadata/contactType/security')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown value '</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>' for incmd:contactType</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="@incmd:contactType">
        <!-- otherwise, fine -->
    </xsl:template>

    <!--
        Additional schema checks.

        The schema itself doesn't help very much as most contexts in which the incmd
        namespace is used are subject to "lax" checking.  These checks duplicate some
        aspects of XML Schema checking as we'd like it to behave.
    -->

    <xsl:template match="incmd:*">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown element incmd:</xsl:text>
                <xsl:value-of select="local-name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="@incmd:*">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown attribute incmd:</xsl:text>
                <xsl:value-of select="local-name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
