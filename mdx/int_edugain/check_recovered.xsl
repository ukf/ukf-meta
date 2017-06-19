<?xml version="1.0" encoding="UTF-8"?>
<!--

	check_recovered.xsl

	Checking ruleset which labels every entity as having recovered from a previous
	error condition.
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

	<!--
		Common support functions.
	-->
	<xsl:import href="../_rules/check_framework.xsl"/>

	<xsl:template match="md:EntityDescriptor">
		<xsl:call-template name="error">
			<xsl:with-param name="m">entity has recovered from a previous error condition</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
