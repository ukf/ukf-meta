<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdattr.xsl

    Checking ruleset containing rules associated with the SAML V2.0 Metadata
    Extension for Entity Attributes Version 1.0, see:

        https://wiki.oasis-open.org/security/SAML2MetadataAttr

    This ruleset reflects Committee Specification 01, 04-Aug-2009.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"

    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Section 2.3

        The specification only defines the meaning of EntityAttributes within the Extensions of either
        EntitiesDescriptor or EntityDescriptor.
    -->
    <xsl:template match="mdattr:EntityAttributes[not(parent::md:Extensions)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">EntityAttributes must only appear within an Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:Extensions[mdattr:EntityAttributes]
        [not(parent::md:EntityDescriptor or parent::md:EntitiesDescriptor)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">EntityAttributes must only appear within Extensions of EntityDescriptor or EntitiesDescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.3 line 176.

        Assertions not permitted in the context of an EntitiesDescriptor.
    -->
    <xsl:template match="md:EntitiesDescriptor/md:Extensions/mdattr:EntityAttributes/saml:Assertion">
        <xsl:call-template name="error">
            <xsl:with-param name="m">Assertion may not appear in the EntityAttributes for an EntitiesDescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.3 line 182.

        EntityAttributes MUST NOT appear more than once within a given <md:Extensions> element.
    -->
    <xsl:template match="md:Extensions/mdattr:EntityAttributes[position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one EntityAttributes element in an Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
