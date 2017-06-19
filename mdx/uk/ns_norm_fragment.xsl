<?xml version="1.0" encoding="UTF-8"?>
<!--

    ns_norm_fragment.xsl

    Normalise the namespaces in a fragment file.

    The only difference between this and full normalisation is the selection of prefixes which are
    included on the document element by default.  We can therefore import the standard templates
    and just override the ones for the document element as long as an appropriate exclude-result-prefixes
    is in effect.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:remd="http://refeds.org/metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

    exclude-result-prefixes="md"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">


    <!--
        Import templates for basic normalisation.
    -->
    <xsl:import href="../ns_norm.xsl"/>


    <!--
        Force UTF-8 encoding for the output.
    -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"/>


    <!--
        *******************************************
        ***                                     ***
        ***   D O C U M E N T   E L E M E N T   ***
        ***                                     ***
        *******************************************
    -->


    <!--
        We need to handle the document element specially in order to arrange
        for all appropriate namespace prefix definitions to appear on it.

        There are only two possible document elements in SAML metadata.
    -->


    <!--
        Document element is <EntityDescriptor>.
    -->
    <xsl:template match="/md:EntityDescriptor">
        <EntityDescriptor>
            <xsl:apply-templates select="node()|@*"/>
        </EntityDescriptor>
    </xsl:template>

    <!--
        Document element is <EntitiesDescriptor>.
    -->
    <xsl:template match="/md:EntitiesDescriptor">
        <EntitiesDescriptor>
            <xsl:apply-templates select="node()|@*"/>
        </EntitiesDescriptor>
    </xsl:template>


</xsl:stylesheet>
