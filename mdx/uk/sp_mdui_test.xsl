<?xml version="1.0" encoding="UTF-8"?>
<!--

    sp_mdui_test.xsl

    XSL stylesheet taking a UK Federation metadata aggregate and resulting in an HTML document
    giving discovery links for each mdui-supporting SP entity.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
    xmlns:math="http://exslt.org/math"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    exclude-result-prefixes="xsl ds md mdui xsi members math date dyn set idpdisc"
    version="1.0">

    <xsl:output method="html" omit-xml-declaration="yes"/>

    <xsl:template match="md:EntitiesDescriptor">

        <xsl:variable name="entities" select="//md:EntityDescriptor"/>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor/md:Extensions/mdui:UIInfo]"/>

        <html>
            <head>
                <title>UK Federation SP discovery UI test</title>
            </head>
            <body>
                <h1>UK Federation SP discovery UI test</h1>

                <ul>
                    <xsl:for-each select="$sps">
                        <xsl:variable name="acs"
                            select="md:SPSSODescriptor/md:AssertionConsumerService[@Binding='urn:oasis:names:tc:SAML:1.0:profiles:browser-post']/@Location"/>
                        <li>
                            <xsl:value-of select="@ID"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="@entityID"/>

                            <ul>

                                <li>
                                    <xsl:choose>
                                        <xsl:when test="descendant::mdui:DisplayName">
                                            <xsl:text>DisplayName: "</xsl:text>
                                            <xsl:value-of select="descendant::mdui:DisplayName"/>
                                            <xsl:text>"</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            No DisplayName
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>

                                <li>
                                    <xsl:choose>
                                        <xsl:when test="descendant::mdui:Description">
                                            <xsl:text>Description supplied</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            No Description
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>

                                <li>
                                    <xsl:choose>
                                        <xsl:when test="descendant::mdui:Logo">
                                            <xsl:text>Logo supplied</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            No Logo
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>

                                <xsl:variable name="parms" select="concat('?shire=',
                                    $acs, '&amp;providerId=', @entityID, '&amp;target=cookie')"/>

                                <li>
                                    <xsl:variable name="prod" select="concat(
                                        'https://wayf.ukfederation.org.uk/WAYF',
                                        $parms)"/>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$prod"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">_blank</xsl:attribute>
                                        Production DS (as WAYF)
                                    </xsl:element>
                                </li>

                                <li>
                                    <xsl:variable name="rod" select="concat(
                                        'https://dlib-adidp.ucs.ed.ac.uk/discovery/ukfull.wayf',
                                        $parms)"/>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$rod"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">_blank</xsl:attribute>
                                        Rod's DS (as WAYF)
                                    </xsl:element>
                                </li>

                                <li>
                                    <xsl:variable name="ukfed4" select="concat(
                                        'https://ukfed4.ukfederation.org.uk/WAYF',
                                        $parms)"/>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$ukfed4"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">_blank</xsl:attribute>
                                        Test DS (ukfed4, as WAYF)
                                    </xsl:element>
                                </li>

                            </ul>
                        </li>
                    </xsl:for-each>
                </ul>

            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
