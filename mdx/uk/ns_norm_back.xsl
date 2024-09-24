<?xml version="1.0" encoding="UTF-8"?>
<!--

    ns_norm_back.xsl

    Normalise the namespaces in the UK federation fallback aggregate.

    The main constraint on the output of this transform is that it should minimise the size
    of the output file while not having "too many" namespace prefix definitions in scope
    at any point in the document.  "Too many" is more than about ten, as a result of a bug
    in the metadatatool application used by Shibboleth 1.3 IdPs to download and verify
    metadata.

    The strategy is to define the most commonly-used prefixes in the document element.

    Prefixes which are less often used, but which may be used by container elements
    (e.g., mdui:) or for attributes are normalised to use a prefix, but not declared
    on the document element.

    Prefixes which are less often used and are only used for non-containers can be
    normalised to non-prefix use (i.e., to redefine the default namespace) if required
    to cut the numbers down.

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
    xmlns:xenc="http://www.w3.org/2001/04/xmlenc#"

    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="md"
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


    <!--
        ***************************************
        ***                                 ***
        ***   R E M D   N A M E S P A C E   ***
        ***                                 ***
        ***************************************
    -->


    <!--
        @remd:*

        Normalise namespace to not use a prefix. Applies to attributes only.
    -->
    <xsl:template match="@remd:*">
        <xsl:attribute name="remd:{local-name()}" namespace="http://refeds.org/metadata">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>


</xsl:stylesheet>
