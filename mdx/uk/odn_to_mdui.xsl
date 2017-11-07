<?xml version="1.0" encoding="UTF-8"?>
<!--

    odn_to_mdui.xsl

    If an identity provider does not have at least one MDUI-based discovery
    name, give it mdui:DisplayName and mdui:Description by copying data from
    its md:OrganizationDisplayName.

    This transform will only be applied to UKf-registered entities.

    This allows us to assume:

    * The entity will have an md:Organization and therefore (by schema)
      at least one md:OrganizationDisplayName

    * It will either not have an mdui:UIInfo at all, or will have one
      with at least one mdui:DisplayName. This means we don't need to
      handle the case of filling in a partial mdui:UIInfo container,
      and can always create one from scratch.

    * The entity's md:IDPSSODescriptor has an md:Extensions element,
      because UKf-registered IdPs are required to have
      at least one shibmd:Scope element.

-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>


    <!--
        Match the md:IDPSSODescriptor/md:Extensions element of an identity provider
        which does not have mdui:UIInfo.

        We must fabricate the mdui:UIInfo as well as the mdui:DisplayName and
        mdui:Description elements.
    -->
    <xsl:template match="/md:EntityDescriptor/md:IDPSSODescriptor/md:Extensions[not(mdui:UIInfo)]">
        <xsl:variable name="odns" select="../../md:Organization/md:OrganizationDisplayName"/>
        <xsl:copy>
            <xsl:text>&#10;&#9;&#9;&#9;</xsl:text>
            <mdui:UIInfo>
                <xsl:call-template name="generateDisplayNames">
                    <xsl:with-param name="odns" select="$odns"/>
                </xsl:call-template>
                <xsl:text>&#10;&#9;&#9;&#9;</xsl:text>
            </mdui:UIInfo>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!--
        Make a new mdui:DisplayName and mdui:Description for each of the
        md:OrganizationDisplayName elements in the $odns parameter.

        Each of the new elements copies the value and xml:lang attribute of
        the md:OrganizationDisplayName, and is indented appropriately to
        appearing at the start of the enclosing mdui:UIInfo.
    -->
    <xsl:template name="generateDisplayNames">
        <xsl:param name="odns"/>
        <!-- Generate mdui:DisplayName elements. -->
        <xsl:for-each select="$odns">
            <xsl:text>&#10;&#9;&#9;&#9;&#9;</xsl:text>
            <mdui:DisplayName>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </mdui:DisplayName>
        </xsl:for-each>
        <!-- Generate mdui:Description elements. -->
        <xsl:for-each select="$odns">
            <xsl:text>&#10;&#9;&#9;&#9;&#9;</xsl:text>
            <mdui:Description>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </mdui:Description>
        </xsl:for-each>
    </xsl:template>


    <!--
        *********************************************
        ***                                       ***
        ***   D E F A U L T   T E M P L A T E S   ***
        ***                                       ***
        *********************************************
    -->


    <!--By default, copy text blocks, comments and attributes unchanged.-->
    <xsl:template match="text()|comment()|@*">
        <xsl:copy/>
    </xsl:template>

    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
