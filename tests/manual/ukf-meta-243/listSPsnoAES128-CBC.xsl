<?xml version="1.0" encoding="UTF-8"?>
<!--

	Lists entityIDs of SPs with no AES128-CBC

-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
        xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

        <xsl:output method="text" encoding="UTF-8"/>

        <xsl:template match="md:EntityDescriptor
			[md:SPSSODescriptor]
			[not(md:SPSSODescriptor/md:KeyDescriptor/md:EncryptionMethod[@Algorithm='http://www.w3.org/2001/04/xmlenc#aes128-cbc'])]">
                <xsl:value-of select="@entityID"/>
                <xsl:text>&#10;</xsl:text>
        </xsl:template>

        <xsl:template match="text()">
                <!-- do nothing -->
        </xsl:template>

</xsl:stylesheet>
