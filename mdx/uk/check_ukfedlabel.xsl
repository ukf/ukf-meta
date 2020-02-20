<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_ukfedlabel.xsl

    Checking ruleset for the ukfedlabel namespace.

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <!--
        Check for individual elements appearing more than once in
        a single entity.
    -->
    <xsl:template match="md:EntityDescriptor[count(descendant::ukfedlabel:AccountableUsers)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity must not have more than one ukfedlabel:AccountableUsers element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:EntityDescriptor[count(descendant::ukfedlabel:ExportOptIn)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity must not have more than one ukfedlabel:ExportOptIn element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:EntityDescriptor[count(descendant::ukfedlabel:ExportOptOut)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity must not have more than one ukfedlabel:ExportOptOut element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:EntityDescriptor[count(descendant::ukfedlabel:Software)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity must not have more than one ukfedlabel:Software element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:EntityDescriptor[count(descendant::ukfedlabel:UKFederationMember)>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity must not have more than one ukfedlabel:UKFederationMember element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Check for entities which are both opted in to and opted out from export.
    -->
    <xsl:template match="md:EntityDescriptor/md:Extensions[ukfedlabel:ExportOptIn][ukfedlabel:ExportOptOut]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity cannot be both opted in to and opted out from export</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for entities which have both kinds of flow constraint.
    -->
    <xsl:template match="md:EntityDescriptor/md:Extensions[ukfedlabel:DisableFlow][ukfedlabel:EnableFlow]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>entity cannot have both EnableFlow and DisableFlow constraints</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
