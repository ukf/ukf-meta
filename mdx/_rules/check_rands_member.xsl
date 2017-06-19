<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_rands_member.xsl

    Checking ruleset containing rules associated with membership of the REFEDS
    Research and Scholarship entity category, see:

        https://refeds.org/category/research-and-scholarship/

    This ruleset reflects v1.3, 8-Sep-2016.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Process entity category.
    -->
    <xsl:template match="md:EntityDescriptor
        [md:Extensions/mdattr:EntityAttributes/saml:Attribute
        [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
        [@Name='http://macedir.org/entity-category']
        /saml:AttributeValue[.='http://refeds.org/category/research-and-scholarship']
        ]">
        <xsl:choose>
            <!--
                (Implicit) applies only to service providers.
            -->
            <xsl:when test="not(md:SPSSODescriptor)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S only applies to service provider entities</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!--
                4.3.1

                The Service Provider [...] supports SAML V2.0 HTTP-POST binding.
            -->
            <xsl:when test="not(md:SPSSODescriptor/md:AssertionConsumerService
                [@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'])">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S requires SAML 2.0 POST support</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!--
                4.3.3

                The Service Provider provides an mdui:DisplayName and mdui:InformationURL in metadata.
            -->
            <xsl:when test="not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S requires mdui:DisplayName</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S requires mdui:InformationURL</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!--
                4.3.4

                The Service Provider provides one or more technical contacts in metadata.
            -->
            <xsl:when test="not(md:ContactPerson[@contactType='technical'])">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">REFEDS R+S requires one or more technical contacts</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
