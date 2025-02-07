<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdattr_ec_anonymous.xsl

    Checks for RC1.1 and RC1.2 of https://refeds.org/category/anonymous.

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
        SPs which assert anonymous entity category must include one or more md:ContactPerson (RC1.2).
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/anonymous']
			[not(md:ContactPerson)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts anonymous entity category but has no ContactPerson element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template> 

    <!--
	    SPs which assert the anonymous entity category must include an explicit mdui:DisplayName (RC1.1).
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/anonymous']
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts anonymous entity category but has no DisplayName element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
	    SPs which assert the anonymous entity category must include an explicit mdui:InformationURL (RC1.1). 
    -->
    <xsl:template match="md:EntityDescriptor
			[md:Extensions/mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
				/saml:AttributeValue='https://refeds.org/category/anonymous']
			[not(md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>SP asserts anonymous entity category but has no InformationURL element.</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
