<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_uk_algorithms.xsl

    Checking ruleset for cryptographic algorithms. This is named as a UK
    ruleset because the division between acceptable and unacceptable algorithms
    is sometimes a judgement call; however, it should be generally
    applicable.

    The best reference for *all* URIs used as algorithm identifiers is the
    XML Security Algorithm Cross-Reference at http://www.w3.org/TR/xmlsec-algorithms/
    Algorithm lists here are in the same order as in that document.

    Author: Ian A. Young <ian@iay.org.uk>
-->
<xsl:stylesheet version="1.0"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        *************************************
        ***                               ***
        ***   S I G N I N G M E T H O D   ***
        ***                               ***
        *************************************
    -->

    <!--
        Check for known BAD SigningMethod algorithms.
    -->
    <xsl:template match="alg:SigningMethod[
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-md5'
        ]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>insecure algorithm in SigningMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for known GOOD SigningMethod algorithms.
    -->
    <xsl:template match="alg:SigningMethod[
        @Algorithm = 'http://www.w3.org/2000/09/xmldsig#dsa-sha1' or
        @Algorithm = 'http://www.w3.org/2009/xmldsig11#dsa-sha256' or
        @Algorithm = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha224' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha384' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha512' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#rsa-ripemd160' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha1' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha224' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha384' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha512'
        ]">
        <!-- do nothing -->
    </xsl:template>

    <!--
        Misspelled or otherwise not known SigningMethod algorithms.
    -->
    <xsl:template match="alg:SigningMethod">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown algorithm in SigningMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        ***********************************
        ***                             ***
        ***   D I G E S T M E T H O D   ***
        ***                             ***
        ***********************************
    -->

    <!--
        Check for known BAD DigestMethod algorithms.
    -->
    <xsl:template match="alg:DigestMethod[
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#md5'
        ]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>insecure algorithm in DigestMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for known GOOD DigestMethod algorithms.
    -->
    <xsl:template match="alg:DigestMethod[
        @Algorithm = 'http://www.w3.org/2000/09/xmldsig#sha1' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#sha224' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#sha256' or
        @Algorithm = 'http://www.w3.org/2001/04/xmldsig-more#sha384' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#sha512' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#ripemd160'
        ]">
        <!-- do nothing -->
    </xsl:template>

    <!--
        Misspelled or otherwise not known DigestMethod algorithms.
    -->
    <xsl:template match="alg:DigestMethod">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown algorithm in DigestMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        *******************************************
        ***                                     ***
        ***   E N C R Y P T I O N M E T H O D   ***
        ***                                     ***
        *******************************************
    -->

    <!--
        Check for known BAD EncryptionMethod algorithms.

        This list is of symmetric key encryption algorithms *and*
        key transport algorithms.
    -->
    <xsl:template match="md:EncryptionMethod[
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#rsa-1_5'
        ]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>insecure algorithm in EncryptionMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Check for known GOOD EncryptionMethod algorithms.

        This list is of symmetric key encryption algorithms *and*
        key transport algorithms.
    -->
    <xsl:template match="md:EncryptionMethod[
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#tripledes-cbc' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#aes128-cbc' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#aes192-cbc' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#aes256-cbc' or
        @Algorithm = 'http://www.w3.org/2009/xmlenc11#aes128-gcm' or
        @Algorithm = 'http://www.w3.org/2009/xmlenc11#aes192-gcm' or
        @Algorithm = 'http://www.w3.org/2009/xmlenc11#aes256-gcm' or
        @Algorithm = 'http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p' or
        @Algorithm = 'http://www.w3.org/2009/xmlenc11#rsa-oaep'
        ]">
        <!-- do nothing -->
    </xsl:template>

    <!--
        Misspelled or otherwise not known EncryptionMethod algorithms.
    -->
    <xsl:template match="md:EncryptionMethod">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>unknown algorithm in EncryptionMethod: '</xsl:text>
                <xsl:value-of select="@Algorithm"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
