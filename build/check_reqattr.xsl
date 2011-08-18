<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_reqattr.xsl
	
	Checking ruleset for RequestedAttribute elements in SAML 2.0 metadata.
	
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
	<xsl:import href="check_framework.xsl"/>


	<!--
		Lack of NameFormat is equivalent to an explicit NameFormat of
		'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified',
		see http://tools.oasis-open.org/issues/browse/SECURITY-11
		
		This is almost certainly not correct, as an implicit
		NameFormat of 'unspecified' is not the same as saying that
		any NameFormat will match.
	-->
	<xsl:template match="md:RequestedAttribute[not(@NameFormat)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>RequestedAttribute </xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text> lacks NameFormat attribute</xsl:text>
				<xsl:text> (implicitly 'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified')</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!--
		MACE-Dir Attribute Profile for SAML 1.x
		
		2.2.1: Legacy names that are explicitly permitted.
		
		Taken from MACE-Dir SAML Attribute Profiles, April 2008
		
		with the following addition at the end:
		
		eduPersonAssurance (from eduPerson 2008)
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:mace:shibboleth:1.0:attributeNamespace:uri']
		[
		@Name='urn:mace:dir:attribute-def:eduPersonScopedAffiliation' or
		@Name='urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation' or
		@Name='urn:mace:dir:attribute-def:eduPersonAffiliation' or
		@Name='urn:mace:dir:attribute-def:eduPersonPrincipalName' or
		@Name='urn:mace:dir:attribute-def:eduPersonEntitlement' or
		@Name='urn:mace:dir:attribute-def:eduPersonTargetedID' or
		@Name='urn:mace:dir:attribute-def:eduPersonNickname' or
		@Name='urn:mace:dir:attribute-def:eduPersonPrimaryOrgUnitDN' or
		@Name='urn:mace:dir:attribute-def:eduPersonOrgUnitDN' or
		@Name='urn:mace:dir:attribute-def:eduPersonOrgDN' or
		@Name='urn:mace:dir:attribute-def:eduCourseMember' or
		@Name='urn:mace:dir:attribute-def:businessCategory' or
		@Name='urn:mace:dir:attribute-def:carLicense' or
		@Name='urn:mace:dir:attribute-def:cn' or
		@Name='urn:mace:dir:attribute-def:departmentNumber' or
		@Name='urn:mace:dir:attribute-def:description' or
		@Name='urn:mace:dir:attribute-def:displayName' or
		@Name='urn:mace:dir:attribute-def:employeeNumber' or
		@Name='urn:mace:dir:attribute-def:employeeType' or
		@Name='urn:mace:dir:attribute-def:facsimileTelephoneNumber' or
		@Name='urn:mace:dir:attribute-def:givenName' or
		@Name='urn:mace:dir:attribute-def:homePhone' or
		@Name='urn:mace:dir:attribute-def:homePostalAddress' or
		@Name='urn:mace:dir:attribute-def:initials' or
		@Name='urn:mace:dir:attribute-def:jpegPhoto' or
		@Name='urn:mace:dir:attribute-def:l' or
		@Name='urn:mace:dir:attribute-def:labeledURI' or
		@Name='urn:mace:dir:attribute-def:mail' or
		@Name='urn:mace:dir:attribute-def:manager' or
		@Name='urn:mace:dir:attribute-def:mobile' or
		@Name='urn:mace:dir:attribute-def:o' or
		@Name='urn:mace:dir:attribute-def:ou' or
		@Name='urn:mace:dir:attribute-def:pager' or
		@Name='urn:mace:dir:attribute-def:physicalDeliveryOfficeName' or
		@Name='urn:mace:dir:attribute-def:postalAddress' or
		@Name='urn:mace:dir:attribute-def:postalCode' or
		@Name='urn:mace:dir:attribute-def:postOfficeBox' or
		@Name='urn:mace:dir:attribute-def:preferredLanguage' or
		@Name='urn:mace:dir:attribute-def:roomNumber' or
		@Name='urn:mace:dir:attribute-def:seeAlso' or
		@Name='urn:mace:dir:attribute-def:sn' or
		@Name='urn:mace:dir:attribute-def:st' or
		@Name='urn:mace:dir:attribute-def:street' or
		@Name='urn:mace:dir:attribute-def:telephoneNumber' or
		@Name='urn:mace:dir:attribute-def:title' or
		@Name='urn:mace:dir:attribute-def:uid' or
		@Name='urn:mace:dir:attribute-def:userCertificate' or
		@Name='urn:mace:dir:attribute-def:userSMIMECertificate' or
		@Name='urn:mace:dir:attribute-def:eduPersonAssurance'
		]"/>


	<!--
		MACE-Dir Attribute Profile for SAML 1.x
		
		2.3.2.1.1: Recommended name and syntax for eduPersonTargetedID.
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:mace:shibboleth:1.0:attributeNamespace:uri']
		[@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.10']"/>


	<!--
		MACE-Dir Attribute Profile for SAML 1.x
		
		'urn:oid:' equivalents of legacy names should NOT appear.
		If they do, they are probably intended to be a SAML 2.0 mapping.
		
		The list is in same order as the list of legacy names above.
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:mace:shibboleth:1.0:attributeNamespace:uri']
		[
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.9' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.5' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.1' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.6' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.7' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.10' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.2' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.8' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.4' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.3' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.6.1.2' or
		@Name='urn:oid:2.5.4.15' or
		@Name='urn:oid:2.16.840.1.113730.3.1.1' or
		@Name='urn:oid:2.5.4.3' or
		@Name='urn:oid:2.16.840.1.113730.3.1.2' or
		@Name='urn:oid:2.5.4.13' or
		@Name='urn:oid:2.16.840.1.113730.3.1.241' or
		@Name='urn:oid:2.16.840.1.113730.3.1.3' or
		@Name='urn:oid:2.16.840.1.113730.3.1.4' or
		@Name='urn:oid:2.5.4.23' or
		@Name='urn:oid:2.5.4.42' or
		@Name='urn:oid:0.9.2342.19200300.100.1.20' or
		@Name='urn:oid:0.9.2342.19200300.100.1.39' or
		@Name='urn:oid:2.5.4.43' or
		@Name='urn:oid:0.9.2342.19200300.100.1.60' or
		@Name='urn:oid:2.5.4.7' or
		@Name='urn:oid:1.3.6.1.4.1.250.1.57' or
		@Name='urn:oid:0.9.2342.19200300.100.1.3' or
		@Name='urn:oid:0.9.2342.19200300.100.1.10' or
		@Name='urn:oid:0.9.2342.19200300.100.1.41' or
		@Name='urn:oid:2.5.4.10' or
		@Name='urn:oid:2.5.4.11' or
		@Name='urn:oid:0.9.2342.19200300.100.1.42' or
		@Name='urn:oid:2.5.4.19' or
		@Name='urn:oid:2.5.4.16' or
		@Name='urn:oid:2.5.4.17' or
		@Name='urn:oid:2.5.4.18' or
		@Name='urn:oid:2.16.840.1.113730.3.1.39' or
		@Name='urn:oid:0.9.2342.19200300.100.1.6' or
		@Name='urn:oid:2.5.4.34' or
		@Name='urn:oid:2.5.4.4' or
		@Name='urn:oid:2.5.4.8' or
		@Name='urn:oid:2.5.4.9' or
		@Name='urn:oid:2.5.4.20' or
		@Name='urn:oid:2.5.4.12' or
		@Name='urn:oid:0.9.2342.19200300.100.1.1' or
		@Name='urn:oid:2.5.4.36' or
		@Name='urn:oid:2.16.840.1.113730.3.1.40' or
		@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.11'
		]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>RequestedAttribute uses OID name </xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text> with SAML 1.x NameFormat: should use urn:mace name or SAML 2.0 NameFormat</xsl:text>
				<xsl:if test="@FriendlyName">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="@FriendlyName"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!--
		MACE-Dir Attribute Profile for SAML 1.x
		
		Forward-looking "urn:oid:" names are permitted, which is to say
		any "urn:oid" name which does not correspond to a legacy name.
		
		The list is in same order as the list of legacy names above.
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:mace:shibboleth:1.0:attributeNamespace:uri']
		[
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.9' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.5' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.1' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.6' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.7' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.10' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.2' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.8' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.4' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.3' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.6.1.2' and
		@Name!='urn:oid:2.5.4.15' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.1' and
		@Name!='urn:oid:2.5.4.3' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.2' and
		@Name!='urn:oid:2.5.4.13' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.241' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.3' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.4' and
		@Name!='urn:oid:2.5.4.23' and
		@Name!='urn:oid:2.5.4.42' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.20' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.39' and
		@Name!='urn:oid:2.5.4.43' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.60' and
		@Name!='urn:oid:2.5.4.7' and
		@Name!='urn:oid:1.3.6.1.4.1.250.1.57' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.3' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.10' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.41' and
		@Name!='urn:oid:2.5.4.10' and
		@Name!='urn:oid:2.5.4.11' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.42' and
		@Name!='urn:oid:2.5.4.19' and
		@Name!='urn:oid:2.5.4.16' and
		@Name!='urn:oid:2.5.4.17' and
		@Name!='urn:oid:2.5.4.18' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.39' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.6' and
		@Name!='urn:oid:2.5.4.34' and
		@Name!='urn:oid:2.5.4.4' and
		@Name!='urn:oid:2.5.4.8' and
		@Name!='urn:oid:2.5.4.9' and
		@Name!='urn:oid:2.5.4.20' and
		@Name!='urn:oid:2.5.4.12' and
		@Name!='urn:oid:0.9.2342.19200300.100.1.1' and
		@Name!='urn:oid:2.5.4.36' and
		@Name!='urn:oid:2.16.840.1.113730.3.1.40' and
		@Name!='urn:oid:1.3.6.1.4.1.5923.1.1.1.11'
		]
		[starts-with(@Name, 'urn:oid:')]"/>


	<!--
		Common error: using the legacy name with the SAML 2.0 NameFormat.
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
		[starts-with(@Name, 'urn:mace:dir:attribute-def:')]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>RequestedAttribute uses legacy name </xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text> with SAML 2.0 NameFormat: should use urn:oid name or SAML 1.x NameFormat</xsl:text>
				<xsl:if test="@FriendlyName">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="@FriendlyName"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!--
		MACE-Dir Attribute Profile for SAML 2.0
		
		Attributes are named per the X.500/LDAP attribute profile in [SAML2Prof].
	-->
	<xsl:template match="md:RequestedAttribute
		[@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
		[starts-with(@Name, 'urn:oid:')]"/>


	<!--
		Having eliminated all valid cases, all other Name/NameFormat combinations
		must be invalid.
	-->
	<xsl:template match="md:RequestedAttribute">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>invalid RequestedAttribute Name::NameFormat combination '</xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text>' :: '</xsl:text>
				<xsl:value-of select="@NameFormat"/>
				<xsl:text>'</xsl:text>
				<xsl:if test="@FriendlyName">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="@FriendlyName"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
