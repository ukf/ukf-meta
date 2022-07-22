<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_sirtfi2.xsl

    Checking ruleset containing rules associated with the Sirtfi version 2.0 specification,
    as described on the REFEDS page https://refeds.org/sirtfi and with specifcation at:

        https://refeds.org/wp-content/uploads/2022/08/Sirtfi-v2.pdf

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
        Process only entities claiming Sirtfi version 2 compliance.
    -->
    <xsl:template match="md:EntityDescriptor[
            md:Extensions/mdattr:EntityAttributes/saml:Attribute[@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                [@Name='urn:oasis:names:tc:SAML:attribute:assurance-certification']
            /saml:AttributeValue[.='https://refeds.org/sirtfi2']
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
                <xsl:with-param name="m">Sirtfi version 2 requires a REFEDS security contact</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!--
            REFEDS security contacts used in Sirtfi version 2 compliant entities need to have
            GivenName and EmailAddress attributes.
        -->
        <xsl:for-each select="$securityContacts">
            <xsl:if test="not(md:GivenName)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">Sirtfi version 2 requires a REFEDS security contact to have a GivenName</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(md:EmailAddress)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">Sirtfi version 2 requires a REFEDS security contact to have an EmailAddress</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>

        <!--
            Sirtfi version 2 requires that the entity also asserts the original Sirtfi entity attribute
        -->
        <xsl:if test="not(
                ./md:Extensions/mdattr:EntityAttributes/saml:Attribute
                [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                [@Name='urn:oasis:names:tc:SAML:attribute:assurance-certification']
                /saml:AttributeValue[.='https://refeds.org/sirtfi'])
            ">
            <xsl:call-template name="error">
                <xsl:with-param name="m">Sirtfi version 2 requires the entity to also support the original Sirtfi entity attribute</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
