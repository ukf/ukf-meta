<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_coco_v2_ec.xsl

    Checks for RC3.1 and RC3.2 of https://refeds.org/category/code-of-conduct/v2.

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
	    5.1.2 SPs MUSTs provide at least one mdui:DisplayName value.
	    5.1.4 For all mdui elements, at least an English version of the element MUST be available, indicated by a xml:lang="en" attribute.
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
                /saml:AttributeValue[.='https://refeds.org/category/code-of-conduct/v2']]
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts CoCo V2 entity category but has no English language DisplayName element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
	    5.1.1. SPs MUST provide at least one mdui:PrivacyStatementURL value. The PrivacyStatementURL MUST resolve to a Privacy Notice which is available to browser users without requiring authentication of any kind.
	    5.1.4 For all mdui elements, at least an English version of the element MUST be available, indicated by an xml:lang="en" attribute.
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
                /saml:AttributeValue[.='https://refeds.org/category/code-of-conduct/v2']]
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL[@xml:lang='en'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts CoCo V2 entity category but has no English language PrivacyStatementURL element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
	    5.1.3 SPs MUST provide at least one mdui:Description value. It is RECOMMENDED that the length of the description is no longer than 140 characters.
 	    5.1.4 For all mdui elements, at least an English version of the element MUST be available, indicated by an xml:lang="en" attribute.
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
                /saml:AttributeValue[.='https://refeds.org/category/code-of-conduct/v2']]
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts CoCo V2 entity category but has no English language Description element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!--
        The Service Provider is responsible to define in metadata what user attributes are necessary for enabling access to the service.
        There are two different locations in metadata for requesting attributes;
        the subject-id:req entity attribute extension and RequestedAttribute elements.

        SPs with code-of-conduct/v2 must have EITHER the SAML subject identifier entity attribute OR an AttributeConsumingService (OR both)

        5.2.1. If the SP is using SAML Subject Identifier Attribute Profile for identifier attribute release,
        it MUST provide subject-id:req entity attribute extension to indicate
        which one of the identifiers pairwise-id or subject-id is necessary.

        5.2.2. If the SP is requesting other attributes than the identifiers above,
        it MUST provide RequestedAttribute elements describing the attributes relevant for the SP.
        The RequestedAttribute elements MUST include the optional isRequired="true" to indicate that the attribute is necessary.


        To simplify, we just check whether either the entity attribute exists or an AttributeConsumingService exists.
        We don't check the values within those elements.
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
                /saml:AttributeValue[.='https://refeds.org/category/code-of-conduct/v2']]
                [not(md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='urn:oasis:names:tc:SAML:profiles:subject-id:req']/saml:AttributeValue)
                    and not(md:SPSSODescriptor[md:AttributeConsumingService])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts CoCo V2 entity category but does not contain any subject-id:req entity attribute extension or AttributeConsumingService (RequestedAttribute) elements</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



</xsl:stylesheet>
