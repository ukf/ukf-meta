<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_future_2.xsl
	
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
		Check for entities which have both PKIX-only KeyDescriptors (i.e.,
		ones with a KeyName but no embedded X.509 certificate) and also
		non-PKIX KeyDescriptors (i.e., ones with no KeyName).
		
		This combination seems unlikely to be intentional, and most
		likely the result of an incomplete transition to embedded key
		material.
	-->
	<xsl:template match="md:EntityDescriptor
		[descendant::md:KeyDescriptor[not(descendant::ds:X509Data)]]
		[descendant::md:KeyDescriptor[not(descendant::ds:KeyName)]]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">has both PKIX-only and no-PKIX KeyDescriptors</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
