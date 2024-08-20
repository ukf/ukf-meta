<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="//md:KeyDescriptor
        [parent::md:SPSSODescriptor and
          not(@use='signing') and
          not(
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2009/xmlenc11#aes128-gcm'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2009/xmlenc11#aes192-gcm'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2009/xmlenc11#aes256-gcm'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2001/04/xmlenc#aes128-cbc'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2001/04/xmlenc#aes192-cbc'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2001/04/xmlenc#aes256-cbc'] or
            md:EncryptionMethod[@Algorithm='http://www.w3.org/2001/04/xmlenc#tripledes-cbc']
        )]">



        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:text>    </xsl:text>
            <xsl:element name="EncryptionMethod"><xsl:attribute name="Algorithm">http://www.w3.org/2001/04/xmlenc#aes128-cbc</xsl:attribute></xsl:element>
            <xsl:text>&#10;        </xsl:text>
        </xsl:copy>
    </xsl:template>

    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
