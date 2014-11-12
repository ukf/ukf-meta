<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_uk_mdattr.xsl
	
    UKf-specific check for appropriate entity attributes in fragment files.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
	
	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>


	<!--
		UKf doesn't register entity attributes using assertions.
	-->
	<xsl:template match="mdattr:EntityAttributes/saml:Assertion">
		<xsl:call-template name="error">
			<xsl:with-param name="m">Assertion not permitted within EntityAttributes</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
		All entity attributes should have the standard SAML 2.0 URI name format.
	-->
	<xsl:template match="mdattr:EntityAttributes/saml:Attribute[not(@NameFormat)]">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>entity attribute </xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text> has no NameFormat attribute</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="mdattr:EntityAttributes/saml:Attribute
		[@NameFormat != 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri']">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>entity attribute </xsl:text>
				<xsl:value-of select="@Name"/>
				<xsl:text> has wrong NameFormat value </xsl:text>
				<xsl:value-of select="@NameFormat"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!--
		Validate attribute name. Each @Name permitted here should have a
		corresponding attribute value validator below.
	-->
	<xsl:template match="mdattr:EntityAttributes/saml:Attribute
		[@Name != 'http://macedir.org/entity-category']
		[@Name != 'http://macedir.org/entity-category-support']
		">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>unknown entity attribute name </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
		Validate entity category values.
	-->
	<xsl:template match="mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category']
		/saml:AttributeValue
		[. != 'http://refeds.org/category/hide-from-discovery']
		[. != 'http://www.geant.net/uri/dataprotection-code-of-conduct/v1']
		">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>unknown entity category URI </xsl:text>
				<xsl:value-of select="."/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!--
        Validate entity category support values.
    -->
	<xsl:template match="mdattr:EntityAttributes/saml:Attribute[@Name='http://macedir.org/entity-category-support']
		/saml:AttributeValue
		">
		<xsl:call-template name="error">
			<xsl:with-param name="m">
				<xsl:text>unknown entity category support URI </xsl:text>
				<xsl:value-of select="."/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
