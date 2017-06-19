<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_int.xsl

    Checking ruleset containing rules associated with the
    Service Provider Request Initiation Protocol and Profile Version 1.0.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Checks on the RequestInitiator extension.
    -->

    <xsl:template match="init:RequestInitiator[not(@Binding)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">missing Binding attribute on RequestInitiator</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="init:RequestInitiator[@Binding]
        [@Binding!='urn:oasis:names:tc:SAML:profiles:SSO:request-init']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">incorrect Binding value on RequestInitiator</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
