<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_regauth.xsl

    Check that the registration authority on an entity is the expected one.

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

    <!--
        expectedAuthority

        Set this parameter from the calling context.
    -->
    <xsl:param name="expectedAuthority">(value not set)</xsl:param>

    <xsl:template match="mdrpi:RegistrationInfo">
        <xsl:if test="@registrationAuthority != $expectedAuthority">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>unexpected registration authority '</xsl:text>
                    <xsl:value-of select="@registrationAuthority"/>
                    <xsl:text>'; expected '</xsl:text>
                    <xsl:value-of select="$expectedAuthority"/>
                    <xsl:text>' for this channel</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
