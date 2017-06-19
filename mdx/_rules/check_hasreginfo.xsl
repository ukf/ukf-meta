<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_hasreginfo.xsl

    Check that an entity has a RegistrationInfo element.

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <xsl:template match="md:EntityDescriptor[not(md:Extensions/mdrpi:RegistrationInfo)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">entity does not have an mdrpi:RegistrationInfo element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
