<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdui_logo_length.xsl

    Checking ruleset to generate warnings for mdui:Logo elements with
    lengths longer than a provided threshold.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        maxLength

        This parameter determines the maximum allowable mdui:Logo length
        before we issue a warning.
    -->
    <xsl:param name="maxLength"/>

    <!--
        Match mdui:Logo elements whose string length is greater than the
        threshold value; issue a warning for them.

        Template match expressions can't include parameter references, so
        match all mdui:Logo elements then dig in with a conditional.
    -->
    <xsl:template match="mdui:Logo">
        <xsl:if test="string-length(.) > $maxLength">
            <xsl:call-template name="warning">
                <xsl:with-param name="m">
                    <xsl:text>mdui:Logo has long contents: </xsl:text>
                    <xsl:value-of select="string-length(.)"/>
                    <xsl:text> > </xsl:text>
                    <xsl:value-of select="$maxLength"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
