<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_imported.xsl
	
	XSL stylesheet that takes an imported metadata document destined for
	the UK federation and checks it against local conventions.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
	xmlns:set="http://exslt.org/sets"
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
		Check for entities which do not have an OrganizationName at all.
	-->
	<xsl:template match="md:EntityDescriptor[not(md:Organization/md:OrganizationName)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">entity lacks OrganizationName</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!--
		OrganizationURL elements should contain actual URLs, or some software
		will reject the metadata.  This is known to be true for at least the Shibboleth
		1.3 IdP and the accompanying metadatatool application, because they pass the
		string to the java.net.URL class.
		
		We perform a very cursory test for this by insisting that they start with
		either "http://" or "https://".
	-->
	<xsl:template match="md:OrganizationURL[not(starts-with(., 'http://'))]
		[not(starts-with(., 'https://'))]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">OrganizationURL '<xsl:value-of select="."/>' does not start with acceptable prefix</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Checks for an IdP whose KeyDescriptor elements do not include a @use attribute.
		This causes problems with the Shibboleth 1.3 SP prior to V1.3.1, which
		interprets this as "no use permitted" rather than "either signing or encryption use
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
		Check for role descriptors with missing KeyDescriptor elements.
	-->
	
	<xsl:template match="md:IDPSSODescriptor[not(md:KeyDescriptor)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">IdP SSO Descriptor lacking KeyDescriptor</xsl:with-param>
		</xsl:call-template>	
	</xsl:template>
	
	<xsl:template match="md:SPSSODescriptor[not(md:KeyDescriptor)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">SP SSO Descriptor lacking KeyDescriptor</xsl:with-param>
		</xsl:call-template>	
	</xsl:template>
	
	<xsl:template match="md:AttributeAuthorityDescriptor[not(md:KeyDescriptor)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">IdP AA Descriptor lacking KeyDescriptor</xsl:with-param>
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
		Check for IDP role descriptors containing (at any level of nesting)
		SAML 2.0 attribute elements that do not include a NameFormat XML attribute.
		
		This combination causes the Shibboleth 1.3 and related code (such as metadatatool)
		to reject the metadata.
		
		See https://bugs.internet2.edu/jira/browse/SIDPO-34
	-->
	<xsl:template match="md:IDPSSODescriptor[descendant::saml:Attribute[not(@NameFormat)]]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">SIDPO-34: Attribute lacking NameFormat in IDPSSODescriptor</xsl:with-param>
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
		Entity IDs should start with one of "http://", "https://" or "urn:mace:".
	-->
	<xsl:template match="md:EntityDescriptor[not(starts-with(@entityID, 'urn:mace:'))]
		[not(starts-with(@entityID, 'http://'))]
		[not(starts-with(@entityID, 'https://'))]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">entity ID <xsl:value-of select="@entityID"/> does not start with acceptable prefix</xsl:with-param>
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
		Check for Locations that don't start with https://
		
		This may be a little strict, and might be better confined to md:* elements.
		In addition, we might at some point require more complex rules: whitelisting certain
		entities, or permitting http:// to Locations associated with certain bindngs.
		
		At present, however, this simpler rule produces no false positives.
	-->
	<xsl:template match="*[@Location and not(starts-with(@Location,'https://'))]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m"><xsl:value-of select='local-name()'/> Location does not start with https://</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for Shibboleth Scope elements that don't include a regexp attribute.
		This has a default in the schema so omitting it can cause signing brittleness.
	-->
	<xsl:template match="shibmd:Scope[not(@regexp)]">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">Scope <xsl:value-of select="."/> lacks @regexp</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Check for empty xml:lang elements, automatically generated by OIOSAML.
		
		This is not schema-valid so would be caught further down the line anyway,
		but it's nice to have a clear error message earlier in the process.
	-->
	<xsl:template match="@xml:lang[.='']">
		<xsl:call-template name="fatal">
			<xsl:with-param name="m">empty xml:lang attribute</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!--
		Common template to call to report a fatal error on some element within an entity.
	-->
	<xsl:template name="fatal">
		<xsl:param name="m"/>
		<xsl:message terminate='no'>
			<xsl:text>*** </xsl:text>
			<xsl:value-of select="ancestor-or-self::md:EntityDescriptor/@entityID"/>
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
