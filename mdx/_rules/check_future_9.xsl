<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_future_9.xsl

    Checking ruleset containing rules that we don't currently implement,
    but which we may implement in the future.

    This is to warn if an SP suggests that it wants signed assertions.
    Typically, it is the response that should be signed.

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:set="http://exslt.org/sets"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:template match="md:EntityDescriptor[md:SPSSODescriptor[@WantAssertionsSigned='true']]">
        <xsl:call-template name="warning">
            <xsl:with-param name="m">SP sets WantAssertionsSigned, although typically you would want Responses signed not Assertions</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
