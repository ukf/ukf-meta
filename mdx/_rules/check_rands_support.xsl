<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_rands_support.xsl

    Checking ruleset containing rules associated with the REFEDS
    Research and Scholarship entity support category, see:

        https://refeds.org/category/research-and-scholarship/

    This ruleset reflects v1.3, 8-Sep-2016.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Process entity support category.
    -->
    <xsl:template match="md:EntityDescriptor
        [md:Extensions/mdattr:EntityAttributes/saml:Attribute
        [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
        [@Name='http://macedir.org/entity-category-support']
        /saml:AttributeValue[.='http://refeds.org/category/research-and-scholarship']
        ]">
        <xsl:choose>
            <!--
                (Implicit) applies only to identity providers.
            -->
            <xsl:when test="not(md:IDPSSODescriptor)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S support only applies to identity provider entities</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
