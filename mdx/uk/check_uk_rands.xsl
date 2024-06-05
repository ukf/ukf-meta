<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_rands.xsl

    UKf-specific checks for SPs asserting R&S entity category
    or for IdPs supporting the entity category.

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <!--
	SPs which assert the R&S entity category must include an explicit RegistrationPolicy.

	Note that there is a different UK-specific check to ensure that RegistrationPolicy
	contains valid values, so we don't need to repeat ourselves here.

	Note also that check_rands_member ensures that entities asserting the entity category
	are SPs.
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='http://refeds.org/category/research-and-scholarship']
			[not(md:Extensions/mdrpi:RegistrationInfo/mdrpi:RegistrationPolicy)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts Research and Scholarship entity category but has no RegistrationPolicy element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        IdPs which support the R&S entity category must include an explicit RegistrationPolicy.

        Note that there is a different UK-specific check to ensure that RegistrationPolicy
        contains valid values, so we don't need to repeat ourselves here.

        Note also that check_rands_support ensures that entities asserting the entity category
        are IdPs.
    -->
    <xsl:template match="md:EntityDescriptor
                        [md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category-support']
                                /saml:AttributeValue='http://refeds.org/category/research-and-scholarship']
                        [not(md:Extensions/mdrpi:RegistrationInfo/mdrpi:RegistrationPolicy)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>IdP supports Research and Scholarship entity category but has no RegistrationPolicy element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
