<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
    exclude-result-prefixes="xsl xsi members"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:variable name="memberCount" select="count(//members:Member)" />

    <xsl:template match="members:Members">
        <h1>UK federation member organisations (<xsl:value-of select="$memberCount" />)</h1>
        <xsl:text>&#10;</xsl:text>
        <table width="80%" cellpadding="4" cellspacing="0" border="1" class="tiger">
        <tr valign="top"><th align="left">Member Organisation</th></tr>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates />
        </table>
    </xsl:template>

    <xsl:template match="members:Member">
            <tr class="ind1" valign="top">
            <xsl:text>&#10;</xsl:text>
            <td align="left">
            <xsl:text>&#10;</xsl:text>
            <xsl:value-of select="members:Name"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:choose>
                <xsl:when test="members:NameComment">
                    <br />
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="members:NameComment"/>
                    <xsl:text>)&#10;</xsl:text>
                </xsl:when>
            </xsl:choose>
            </td>
            </tr>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>
</xsl:stylesheet>
