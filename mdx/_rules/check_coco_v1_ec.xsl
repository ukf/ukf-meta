<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_coco_v1_ec.xsl

    Checks for SAML Metadata Requirements for SP Entities of http://www.geant.net/uri/dataprotection-code-of-conduct/v1.

    This ruleset reflects v1.1 published 24th October 2014
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
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
                /saml:AttributeValue[.='http://www.geant.net/uri/dataprotection-code-of-conduct/v1']]">

        <xsl:choose>
            <!--
                (Implicit) applies only to service providers.
            -->
            <xsl:when test="not(md:SPSSODescriptor)">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">CoCo V1 entity category only applies to service provider entities</xsl:with-param>
                </xsl:call-template>
            </xsl:when>


            <!--
                1.1. SPs MUST provide at least one mdui:PrivacyStatementURLvalue.
                1.4. For all mdui elements, at least an English version of the element MUST be available,
                     indicated by an xml:lang="en"attribute.
            -->
            <xsl:when test="md:SPSSODescriptor/md:Extensions[not(mdui:UIInfo/mdui:PrivacyStatementURL[@xml:lang='en'])]">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>SP asserts CoCo V1 entity category but has no English language PrivacyStatementURL element.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--OK
                1.2. It is RECOMMENDED that SPs provide at least one mdui:DisplayName value.
                1.4. For all mdui elements, at least an English version of the element MUST be available,
                     indicated by an xml:lang="en"attribute.
            -->
            <xsl:when test="md:SPSSODescriptor/md:Extensions[not(mdui:UIInfo/mdui:DisplayName[@xml:lang='en'])]">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>SP asserts CoCo V1 entity category but has no English language DisplayName element.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>


            <!--
                1.3. It is RECOMMENDED that SPs provide at least one mdui:Description value.
                1.4. For all mdui elements, at least an English version of the element MUST be available,
                     indicated by an xml:lang="en"attribute.
            -->
            <xsl:when test="md:SPSSODescriptor/md:Extensions[not(mdui:UIInfo/mdui:Description[@xml:lang='en'])]">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>SP asserts CoCo V1 entity category but has no English language Description element.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>



            <!--
                2.1. SPs MUST provide RequestedAttribute elements describing attributes (and, optionally, requested values) relevant for the SP.
                The RequestedAttribute elements MUST include the optional isRequired="true" to indicate that the attribute is necessary.

                2.2. If the SP requires just one or some particular value(s) of an attribute(such as, eduPersonAffiliation="member"),
                the SP MUST use the saml:AttributeValue element to indicate that value(s).
            -->
            <xsl:when test="md:SPSSODescriptor[not(md:AttributeConsumingService/md:RequestedAttribute)]">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>SP asserts CoCo V1 entity category but does not contain any RequestedAttribute elements</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>


        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
