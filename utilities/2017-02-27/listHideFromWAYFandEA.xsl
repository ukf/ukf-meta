<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
        xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
        xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

        <xsl:output method="text" encoding="UTF-8"/>

        <xsl:template match="md:EntityDescriptor
		                    [md:Extensions/mdattr:EntityAttributes]
		                    [md:Extensions/wayf:HideFromWAYF]">
                <xsl:value-of select="@entityID"/>
                <xsl:text>&#10;</xsl:text>
        </xsl:template>

        <xsl:template match="text()">
                <!-- do nothing -->
        </xsl:template>
</xsl:stylesheet>
