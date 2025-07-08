<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_saml2_sp_signedrequests.xsl

-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
	    Check if the SP with AuthnRequestsSigned='true' but with no KeyDescriptor for signing
    -->
    <xsl:template match="md:SPSSODescriptor[@AuthnRequestsSigned='true'] | md:SPSSODescriptor[@AuthnRequestsSigned='1']">
        <xsl:if test="(count(md:KeyDescriptor[@use='signing']) &lt; 1) and (count(md:KeyDescriptor[not(@use)]) &lt; 1)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>SP asserts AuthnRequestsSigned but has no KeyDescriptor for signing.</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
