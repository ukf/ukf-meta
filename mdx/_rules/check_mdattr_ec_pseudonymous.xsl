<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdattr_ec_pseudonymous.xsl

    Checks for RC3.1 and RC3.2 of https://refeds.org/category/pseudonymous.

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
        SPs which assert pseudonymous entity category must include one or more md:ContactPerson (RC3.2).
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/pseudonymous']
			[not(md:ContactPerson)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts pseudonymous entity category but has no ContactPerson element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 

    <!--
	    SPs which assert the pseudonymous entity category must include an explicit mdui:DisplayName (RC3.1). 
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/pseudonymous']
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts pseudonymous entity category but has no DisplayName element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
	    SPs which assert the pseudonymous entity category must include an explicit mdui:InformationURL (RC3.1). 
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/pseudonymous']
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts pseudonymous entity category but has no InformationURL element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
	    SPs which assert the pseudonymous entity category must include an explicit mdui:PrivacyStatementURL (RC3.1). 
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/pseudonymous']
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts pseudonymous entity category but has no PrivacyStatementURL element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
