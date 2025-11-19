<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_coco_v1_support.xsl

    Checking ruleset containing rules associated with the GEANT
    Data Protection Code of Conduct Entity Category category support, see:

    http://www.geant.net/uri/dataprotection-code-of-conduct/v1

    This ruleset reflects v1.1 published 24th October 2014

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
        Entity support category applies only to identity providers.
    -->
    <xsl:template match="md:EntityDescriptor
        [
            md:Extensions/mdattr:EntityAttributes/saml:Attribute
                [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                [@Name='http://macedir.org/entity-category-support']
                /saml:AttributeValue[.='http://www.geant.net/uri/dataprotection-code-of-conduct/v1']
        ]
        [not(md:IDPSSODescriptor)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">GEANT Data Protection Code of Conduct support only applies to identity provider entities</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
