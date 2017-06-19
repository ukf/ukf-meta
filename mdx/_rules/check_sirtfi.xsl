<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_sirtfi.xsl

    Checking ruleset containing rules associated with the SIRTFI specification,
    as described here:

        https://refeds.org/wp-content/uploads/2016/11/Sirtfi-certification-v1.0.pdf

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:remd="http://refeds.org/metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"

    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Process only entities claiming SIRTFI compliance.
    -->
    <xsl:template match="md:EntityDescriptor[
            md:Extensions/mdattr:EntityAttributes/saml:Attribute[@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                [@Name='urn:oasis:names:tc:SAML:attribute:assurance-certification']
            /saml:AttributeValue[.='https://refeds.org/sirtfi']
        ]">

        <!--
            Collect the REFEDS security contacts for this entity.
        -->
        <xsl:variable name="securityContacts"
            select="md:ContactPerson
            [@contactType='other']
            [@remd:contactType='http://refeds.org/metadata/contactType/security']"/>

        <!--
            There must be at least one REFEDS security contact.
        -->
        <xsl:if test="count($securityContacts) = 0">
            <xsl:call-template name="error">
                <xsl:with-param name="m">SIRTFI requires a REFEDS security contact</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!--
            REFEDS security contacts used in SIRTFI compliant entities need to have
            GivenName and EmailAddress attributes.
        -->
        <xsl:for-each select="$securityContacts">
            <xsl:if test="not(md:GivenName)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">SIRTFI requires a REFEDS security contact with a GivenName</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(md:EmailAddress)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">SIRTFI requires a REFEDS security contact with an EmailAddress</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
