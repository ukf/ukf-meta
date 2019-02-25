<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="members:Member">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@ID"/>
            <xsl:text>","</xsl:text>
            <xsl:value-of select="members:Name"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>
</xsl:stylesheet>
