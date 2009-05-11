<?xml version="1.0" encoding="UTF-8"?>
<!--

	check.xsl
	
	XSL stylesheet that takes a file full of metadata for the UK federation
	and checks it against local conventions.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		The stylesheet output will be a text file, which will probably be thrown
		away in any case.  The real output from the check is sent using the
		xsl:message element.
	-->
	<xsl:output method="text"/>
	
	
	<!--
		Checks for an IdP whose KeyDescriptor elements do not include a @use attribute.
		This causes problems with certain versions of the Shibboleth 1.3 SP, which
		interpret this as "no use permitted" rather than "either signing or encryption use
		permitted".
		
		Two checks are required, one for each of the IdP role descriptors.
	-->
	
	<xsl:template match="md:IDPSSODescriptor/md:KeyDescriptor[not(@use)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">IdP SSO KeyDescriptor lacking @use</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="md:AttributeAuthorityDescriptor/md:KeyDescriptor[not(@use)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">IdP AA KeyDescriptor lacking @use</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for a construct which is known to cause the Shibboleth 1.3 SP to dump core.
		
			<md:KeyDescriptor use="signing">
				<ds:KeyInfo>
					<KeyName>blabla<KeyName>
				</ds:KeyInfo>
			</md:KeyDescriptor>
		
		The issue here is that the KeyName does not have the ds: namespace.
	-->
	<xsl:template match="ds:KeyInfo/*[namespace-uri() != 'http://www.w3.org/2000/09/xmldsig#']">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">ds:KeyInfo child element not in ds namespace</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Entity IDs should not contain space characters.
	-->
	<xsl:template match="md:EntityDescriptor[contains(@entityID, ' ')]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">entity ID contains space character</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		@Location attributes should not contain space characters.
		
		This may be a little strict, and might be better confined to md:* elements.
		At present, however, this produces no false positives.
	-->
	<xsl:template match="*[contains(@Location, ' ')]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m"><xsl:value-of select='local-name()'/> Location contains space character</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Checks on the DiscoveryResponse extension.
	-->
	
	<xsl:template match="idpdisc:DiscoveryResponse[not(@Binding)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">missing Binding attribute on DiscoveryResponse</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="idpdisc:DiscoveryResponse[@Binding]
		[@Binding!='urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol']">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">incorrect Binding value on DiscoveryResponse</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
		Common template to call to report a fatal error on some element within an entity.
	-->
	<xsl:template name="fatal">
		<xsl:param name="m"/>
		<xsl:message terminate='no'>
			<xsl:text>*** </xsl:text>
			<xsl:value-of select="ancestor-or-self::md:EntityDescriptor/@ID"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="$m"/>
		</xsl:message>
	</xsl:template>


	<!-- Recurse down through all elements by default. -->
	<xsl:template match="*">
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
	
	<!-- Discard text blocks, comments and attributes by default. -->
	<xsl:template match="text()|comment()|@*">
		<!-- do nothing -->
	</xsl:template>

</xsl:stylesheet>
