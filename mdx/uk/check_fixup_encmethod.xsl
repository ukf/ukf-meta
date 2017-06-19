<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_fixup_encmethod.xsl

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="../_rules/check_framework.xsl"/>


    <!--
        Use of EncryptionMethod within KeyDescriptor causes metadata loading problems
        for OpenSAML-C 2.0.

        See https://wiki.shibboleth.net/confluence/display/SHIB2/MetadataCorrectness#MetadataCorrectness-Version2.0
    -->
    <xsl:template match="md:KeyDescriptor/md:EncryptionMethod">
        <xsl:call-template name="error">
            <xsl:with-param name="m">KeyDescriptor contains EncryptionMethod: OpenSAML-C 2.0 problem</xsl:with-param>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
