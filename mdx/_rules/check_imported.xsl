<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_imported.xsl

    Checking ruleset containing rules associated with imported metadata.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Checks for IdPs.
    -->
    <xsl:template match="md:EntityDescriptor[md:IDPSSODescriptor]">
        <!--
            IdPs registered with the UK federation are expected to have at least one scope.
        -->
        <xsl:if test="not(descendant::shibmd:Scope)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">this IdP does not have any Scope elements</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
