<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_future_1.xsl
	
	Checking ruleset containing rules that we don't currently implement,
	but which we may implement in the future.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:set="http://exslt.org/sets"
	xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"

	xmlns:mdxURL="xalan://uk.ac.sdss.xalan.md.URLchecker"

	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../build/check_framework.xsl"/>

	
	<!--
        Section 6.
        
        Check for SAML 2.0 SPs which exclude both transient and persistent SAML 2 name identifier formats.
    -->
    <xsl:template match="md:SPSSODescriptor
        [contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
        [md:NameIDFormat]
        [not(md:NameIDFormat[.='urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'])]
        [not(md:NameIDFormat[.='urn:oasis:names:tc:SAML:2.0:nameid-format:transient'])]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">saml2int: SP excludes both SAML 2 name identifier formats</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
	
</xsl:stylesheet>
